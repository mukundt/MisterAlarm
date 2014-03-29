#include <Servo.h> 

// INPUTS
#define PIN_SONAR 2

// OUTPUTS
#define PIN_LAMP 5
#define PIN_MIST 6
#define PIN_HORN 7

// DURATIONS
#define LAMP_ON_TIME 10000  // milliseconds
#define MIST_ON_TIME 500   // milliseconds
#define HORN_ON_TIME 1000   // milliseconds
#define SONAR_CHECK_INTERVAL 50 // milliseconds
#define SONAR_DOWN_TIME 2000 // milliseconds

// SERVO PARAMETERS
#define SERVO_SQUEEZED_POSITION 0   // degrees
#define SERVO_RELEASED_POSITION 130  // degrees

// TIMERS
unsigned long lamp_start_time = 0;
unsigned long mist_start_time = 0;
unsigned long horn_start_time = 0;

// FLAGS
boolean lamp_on = false;
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
  Serial.begin(9600);
  pinMode(PIN_LAMP, OUTPUT);
  pinMode(PIN_HORN, OUTPUT);
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
}

// reads all bytes in the serial input buffer, sets flags and timers accordingly
void process_bluetooth_buffer() 
{
  while (Serial.available())
  {
    char command = (char)Serial.read();
    switch (command)
    {
      case 'L': // lamp
        lamp_on = true;
        lamp_start_time = millis();
        break;
      case 'S': // spray
        mist_on = true;
        mist_start_time = millis();
        break;
      case 'H': // horn
        horn_on = true;
        horn_start_time = millis();
        break;
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
    long duration, cm;
    pinMode(PIN_SONAR, OUTPUT);
    digitalWrite(PIN_SONAR, LOW);
    delayMicroseconds(2);
    digitalWrite(PIN_SONAR, HIGH);
    delayMicroseconds(5);
    digitalWrite(PIN_SONAR, LOW);
    
    // read the output pulse
    pinMode(PIN_SONAR, INPUT);
    duration = pulseIn(PIN_SONAR, HIGH); // timeout after 1 second
    
    // accomodate for the speed of sound (no big deal)
    cm = duration / 29 / 2;
    
    prev_hand_detected = hand_detected;
    if (cm < 40){
      hand_detected = true;
    }
    else {
      hand_detected = false;
    }
    if (hand_detected && !prev_hand_detected && (millis() - last_detection_time) > SONAR_DOWN_TIME){
      Serial.write('S'); // snoz
      last_detection_time = millis();
    }
    
  }
}

// reads flag and timer, turns lamp on/off accordingly
void lamp_do_events()
{
  if (!lamp_on) return;
  if (millis() - lamp_start_time < LAMP_ON_TIME) {
    digitalWrite(PIN_LAMP, HIGH);
  } else {
    digitalWrite(PIN_LAMP, LOW);
    lamp_on = false;
  }
}
  
// reads flag and timer, moves the mister sevo accordingly
void mist_do_events()
{
  if (!mist_on) return;
  if (millis() - mist_start_time < MIST_ON_TIME) {
    float proportion = 1.0 - float(millis() - mist_start_time) / float(MIST_ON_TIME); // 0.0 to 1.0
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

