#define PIN_SENSOR 7
#define PIN_RELAY 5

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>

boolean check = false;
boolean prevcheck = false;
int dur = 0;

void setup() {
  ble_begin();
  pinMode(PIN_RELAY, OUTPUT);

}

void loop()
{
  while (ble_available())
  {
    char command = (char)ble_read();
    switch (command)
    {
      case 'f': //CHANGE BACK TO 'r'
        flipLamp(); 
        break;
      default: 
        break;
    }
  }
  sonarSensor();
  
  ble_do_events();
}

void sonarSensor()
{
  long duration, cm;
  pinMode(PIN_SENSOR, OUTPUT);
  digitalWrite(PIN_SENSOR, LOW);
  delayMicroseconds(2);
  digitalWrite(PIN_SENSOR, HIGH);
  delayMicroseconds(5);
  digitalWrite(PIN_SENSOR, LOW);
  
  pinMode(PIN_SENSOR, INPUT);
  duration = pulseIn(PIN_SENSOR, HIGH);
  
  cm = duration / 29 /2;
  prevcheck = check;
  delay(50);
  if (cm < 40){
    check = true;
    dur++;
  }
  else {
    check = false;
    dur = 0;
  }
  if (check && !prevcheck){
    ble_write('s');
  }
}

void flipLamp()
{
  for (int i = 0; i < 10; i++)
  {
    digitalWrite(PIN_RELAY, HIGH);
    delay(250);
    digitalWrite(PIN_RELAY, LOW);
    delay(250);
  }
}
