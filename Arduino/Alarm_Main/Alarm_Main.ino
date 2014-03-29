#include <boards.h>
#include <ble_shield.h>
#include <services.h>

const int pingPin = 7;
boolean check = false;

void setup() {
  Serial.begin(9600);
}

void loop()
{
  long duration, cm;
  
  pinMode(pingPin, OUTPUT);
  digitalWrite(pingPin, LOW);
  delayMicroseconds(2);
  digitalWrite(pingPin, HIGH);
  delayMicroseconds(5);
  digitalWrite(pingPin, LOW);
  
  pinMode(pingPin, INPUT);
  duration = pulseIn(pingPin, HIGH);
  
  cm = duration / 29 /2;
  
  delay(150);
  if (cm < 40){
    check = true;
  }
  else {
    check = false;
  }
  if (check){
    Serial.println("HI MUKUND");
  }

}
