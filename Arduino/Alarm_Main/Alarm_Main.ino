#define PIN_SENSOR 7

#include <SPI.h>
#include <boards.h>
#include <ble_shield.h>
#include <services.h>

boolean check = false;
boolean prevcheck = false;
int dur = 0;

void setup() {
  //ble_begin();
  Serial.begin(9600);
}

void loop()
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
    //ble_write('c');
    Serial.println("HI MUKUND");
  }

}
