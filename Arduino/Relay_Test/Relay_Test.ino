#define PIN_RELAY 5

void setup() {
  pinMode(PIN_RELAY, OUTPUT);
}

void loop() {
  digitalWrite(PIN_RELAY, HIGH);
  delay(250);
  digitalWrite(PIN_RELAY, LOW);
  delay(250);
}
