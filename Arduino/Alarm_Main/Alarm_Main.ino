//#include "ble_shield.h"

const int pingPin = 7;

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
  
  Serial.println(cm);
}
