#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>
#include <Servo.h> 

// INPUTS
#define PIN_SONAR 2

// OUTPUTS
#define PIN_LAMP 5
#define PIN_MIST 6
#define PIN_HORN 7

// DURATIONS
#define LAMP_ON_TIME 500  // milliseconds
#define MIST_ON_TIME 800   // milliseconds
#define HORN_ON_TIME 1000   // milliseconds
#define SONAR_CHECK_INTERVAL 350 // milliseconds - DON'T POLL TOO MUCH---MESSES UP TIMING BIG TIME
#define SONAR_DOWN_TIME 2000 // milliseconds

// SERVO PARAMETERS
#define SERVO_SQUEEZED_POSITION 0   // degrees
#define SERVO_RELEASED_POSITION 130  // degrees

// TIMERS
unsigned long lamp_start_time = 0;
unsigned long mist_start_time = 0;
unsigned long horn_start_time = 0;

unsigned long lamp_end_time = 0;
unsigned long mist_end_time = 0;

// FLAGS
boolean lamp = false;
boolean lamp_on = false;
boolean mist_on = false;
boolean horn_on = false;

// COUNTS

int lamp_count = 0;
int mist_count = 0;

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
  pinMode(PIN_HORN, OUTPUT);
  // sonar pin mode is set later on
  mist_servo.attach(PIN_MIST);
  mist_servo.write(servo_position);
}

void loop()
{
  process_bluetooth_buffer();
  ble_do_events();
  lamp_do_events();
  mist_do_events();
  horn_do_events();
  check_sonar();
  lamp_flick();
}

// reads all bytes in the serial input buffer, sets flags and timers accordingly
void process_bluetooth_buffer() 
{
  while (ble_available())
  {
    char command = (char)ble_read();
    switch (command)
    {
      case 'O': //lamp on
        lamp = true;
      case 'L': // lamp flicker
        lamp = false;
        lamp_on = true;
        lamp_count = 5;
        lamp_start_time = millis();
        break;
      case 'S': // spray
        mist_on = true;
        mist_count = 5;
        mist_start_time = millis();
        break;
      case 'H': // horn
        horn_on = true;
        horn_start_time = millis();
        break;
      case 'B':
        lamp = false;
        lamp_count = 0;
        mist_count = 0;
      case 'C':
        lamp_count = 5;
        mist_count = 5;
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
    delayMicroseconds(1);
    digitalWrite(PIN_SONAR, HIGH);
    delayMicroseconds(3);
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

void lamp_flick()
{
  if (!lamp) return;
  digitalWrite(PIN_LAMP, HIGH);
}

// reads flag and timer, turns lamp on/off accordingly
void lamp_do_events()
{
  if (!lamp_on && lamp_count == 0) return;
  
  else if (!lamp_on && lamp_count > 0)
  {
    if (millis() - lamp_end_time > LAMP_ON_TIME)
    {
      lamp_on = true;
      //lamp_count--;
      lamp_start_time = millis();
    }
  }
  
  else
  { 
    if (millis() - lamp_start_time < LAMP_ON_TIME) {
      digitalWrite(PIN_LAMP, HIGH);
    } else {
      digitalWrite(PIN_LAMP, LOW);
      lamp_on = false;
      lamp_end_time = millis();
    }
  }
  
 }

  
// reads flag and timer, moves the mister sevo accordingly
void mist_do_events()
{
  if (!mist_on && mist_count == 0) return;
  
  else if (!mist_on && mist_count > 0)
  {
     if (millis() - mist_end_time > MIST_ON_TIME)
    {
      mist_on = true;
      //mist_count--;
      mist_start_time = millis();
    }
  }
  
  if (millis() - mist_start_time < MIST_ON_TIME) {
    float proportion = float(millis() - mist_start_time) / float(MIST_ON_TIME); // 0.0 to 1.0
    float range_motion = float(SERVO_RELEASED_POSITION - SERVO_SQUEEZED_POSITION);
    servo_position = int(range_motion * proportion + SERVO_SQUEEZED_POSITION);
  } else {
    servo_position = SERVO_RELEASED_POSITION;
    mist_on = false;
  }
  mist_servo.write(servo_position);
}

// reads flag and timer, turns horn on/off accordingly
void horn_do_events()
{
  if (!horn_on) return;
  if (millis() - horn_start_time < HORN_ON_TIME) {
    digitalWrite(PIN_HORN, HIGH);
  } else {
    digitalWrite(PIN_HORN, LOW);
    horn_on = false;
  }
}

