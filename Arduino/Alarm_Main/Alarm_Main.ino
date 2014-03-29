#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
#include <Servo.h> 

// INPUTS
#define PIN_SONAR 2

// OUTPUTS
#define PIN_LAMP 17
#define PIN_MIST 19
#define PIN_HORNA 5
#define PIN_HORNB 6

// DURATIONS
#define LAMP_ON_TIME 100  // milliseconds, duration of a flash
#define MIST_ON_TIME 800   // milliseconds, servo travel time
#define HORN_ON_TIME 1000   // milliseconds, total honk duration
#define SONAR_CHECK_INTERVAL 50 // milliseconds - DON'T POLL TOO MUCH---MESSES UP TIMING BIG TIME
#define SONAR_DOWN_TIME 2000 // milliseconds

// SERVO PARAMETERS
#define SERVO_SQUEEZED_POSITION 0   // degrees
#define SERVO_RELEASED_POSITION 130  // degrees

// TIMERS
unsigned long lamp_start_time = 0;
unsigned long mist_start_time = 0;

// FLAGS
boolean lamp_continuous = false;
boolean lamp_flashing = false;
boolean mist_on = false;
boolean horn_on = false;

// SERVO
Servo mist_servo;
int servo_position = SERVO_RELEASED_POSITION;

// SONAR
unsigned long last_check_time = 0;
unsigned long last_detection_time = 0;
boolean hand_detected = false;
boolean prev_hand_detected = false;

void setup() {
  ble_begin();
  pinMode(PIN_LAMP, OUTPUT);
  pinMode(PIN_HORNA, OUTPUT);
  pinMode(PIN_HORNB, OUTPUT);
  // sonar pin mode is set later on
  mist_servo.attach(PIN_MIST);
  mist_servo.write(servo_position);
}

void loop()
{
  process_bluetooth_buffer();
  lamp_do_events();
  mist_do_events();
  horn_do_events();
  check_sonar();
  ble_do_events();
}

// reads all bytes in the serial input buffer, sets flags and timers accordingly
void process_bluetooth_buffer() 
{
  while (ble_available())
  {
    char command = (char)ble_read();
    switch (command)
    {
    case 'O': // lamp on
      lamp_continuous = true;
      lamp_flashing = false;
      break;
    case 'L': // lamp flicker
      lamp_continuous = false;
      lamp_flashing = true;
      lamp_start_time = millis();
      break;
    case 'S': // spray
      mist_on = true;
      mist_start_time = millis();
      break;
    case 'H': // horn
      lamp_continuous = false;
      lamp_flashing = false;
      mist_on = false;
      horn_on = true;
      break;
    case 'B':
      lamp_continuous = false;
      lamp_flashing = false;
      mist_on = false;
      horn_on = false;
    default:
      break;
    }
  }
}

// reads the sonar sensor, sends a byte over bluetooth if hand is detected
void check_sonar()
{
  if (millis() - last_check_time > SONAR_CHECK_INTERVAL) { // it's time to check the sonar again! :D
    last_check_time = millis();
    // send a pulse
    pinMode(PIN_SONAR, OUTPUT);
    digitalWrite(PIN_SONAR, LOW);
    delayMicroseconds(2);
    digitalWrite(PIN_SONAR, HIGH);
    delayMicroseconds(5);
    digitalWrite(PIN_SONAR, LOW);

    // read the output pulse
    pinMode(PIN_SONAR, INPUT);
    long duration = pulseIn(PIN_SONAR, 200000); // timeout after 0.2 seconds

    // accomodate for the speed of sound (no big deal)
    long cm = duration / 29 / 2;

    prev_hand_detected = hand_detected;
    if (cm < 40){
      hand_detected = true;
    }
    else {
      hand_detected = false;
    }
    if (hand_detected && !prev_hand_detected){
      ble_write('W'); // wave
    }
  }
}

// reads flag and timer, turns lamp on/off accordingly
void lamp_do_events()
{
  if (lamp_continuous) {
    digitalWrite(PIN_LAMP, HIGH);
  } 
  else if (lamp_flashing) {
    if (millis() - lamp_start_time >= 2 * LAMP_ON_TIME) {
      lamp_start_time = millis(); // reset the cycle when two LAMP_ON_TIMEs have gone by
    }
    if (millis() - lamp_start_time < LAMP_ON_TIME) {
      digitalWrite(PIN_LAMP, HIGH);
    } 
    else {
      digitalWrite(PIN_LAMP, LOW);
    }
  } 
  else {
    digitalWrite(PIN_LAMP, LOW);
  }
}


// reads flag and timer, moves the mister sevo accordingly
void mist_do_events()
{
  if (!mist_on) {
    mist_servo.write(SERVO_RELEASED_POSITION);
    return;
  }
  if (millis() - mist_start_time >= int(1.3 * float(MIST_ON_TIME))) {
    mist_start_time = millis();
  }
  if (millis() - mist_start_time < MIST_ON_TIME) {
    float proportion = float(millis() - mist_start_time) / float(MIST_ON_TIME); // 0.0 to 1.0
    float range_motion = float(SERVO_RELEASED_POSITION - SERVO_SQUEEZED_POSITION);
    servo_position = int(range_motion * proportion + SERVO_SQUEEZED_POSITION);
  } 
  else {
    servo_position = SERVO_RELEASED_POSITION;
  }
  mist_servo.write(servo_position);
}

// reads flag and timer, turns horn on/off accordingly
void horn_do_events()
{
  if (horn_on) {
    mist_servo.write(SERVO_RELEASED_POSITION);
    digitalWrite(PIN_HORNA, HIGH);
    digitalWrite(PIN_HORNB, HIGH);
    delay(HORN_ON_TIME);
    digitalWrite(PIN_HORNA, LOW);
    digitalWrite(PIN_HORNB, LOW);
    horn_on = false;
  }
}


