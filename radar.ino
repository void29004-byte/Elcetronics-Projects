#include <Servo.h>

// Pin configuration
const int trigPin = 9;
const int echoPin = 10;
const int servoPin = 6;

// Radar settings
const int MIN_ANGLE = 0;
const int MAX_ANGLE = 180;
const int STEP_ANGLE = 2;
const int MAX_DISTANCE = 300;

// Objects
Servo radarServo;

int angle = 0;
int direction = 1;

// Measure distance using HC-SR04
float getDistance() {
    digitalWrite(trigPin, LOW);
    delayMicroseconds(2);

    digitalWrite(trigPin, HIGH);
    delayMicroseconds(10);
    digitalWrite(trigPin, LOW);

    unsigned long duration = pulseIn(echoPin, HIGH, 25000);

    if (duration == 0) {
        return -1;
    }

    float distance = duration * 0.0343 / 2.0;

    if (distance < 2 || distance > MAX_DISTANCE) {
        return -1;
    }

    return distance;
}

void setup() {
    pinMode(trigPin, OUTPUT);
    pinMode(echoPin, INPUT);

    radarServo.attach(servoPin);
    radarServo.write(angle);

    Serial.begin(9600);
    delay(500);

    Serial.println("0,-1");
}

void loop() {
    radarServo.write(angle);
    delay(25);

    float distance = getDistance();

    // Send angle and distance to Processing
    Serial.print(angle);
    Serial.print(",");
    Serial.println(distance, 1);

    // Reverse direction at each endpoint
    angle += direction * STEP_ANGLE;

    if (angle >= MAX_ANGLE) {
        angle = MAX_ANGLE;
        direction = -1;
    } 
    else if (angle <= MIN_ANGLE) {
        angle = MIN_ANGLE;
        direction = 1;
    }

    delay(20);
}
