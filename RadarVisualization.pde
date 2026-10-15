
import processing.serial.*;

Serial myPort;

int angle = 0;
float distance = -1;

final int MAX_DISTANCE = 300;
final int RADAR_RADIUS = 300;

float[] detectedDistances = new float[181];

void setup() {
  size(1000, 700);
  smooth();

  // Initialize detection history.
  for (int i = 0; i < detectedDistances.length; i++) {
    detectedDistances[i] = -1;
  }

  // Display available serial ports.
  println(Serial.list());

  // Connect to Arduino Uno on COM5.
  myPort = new Serial(this, "COM5", 9600);
  myPort.bufferUntil('\n');
}

void draw() {
  background(0);

  drawTitle();
  drawRadar();
  drawDetections();
  drawScanLine();
  drawInformation();
}

void serialEvent(Serial port) {
  String data = port.readStringUntil('\n');

  if (data == null) {
    return;
  }

  data = trim(data);

  String[] values = split(data, ',');

  if (values.length != 2) {
    return;
  }

  try {
    int newAngle = int(values[0]);
    float newDistance = float(values[1]);

    if (newAngle >= 0 && newAngle <= 180) {
      angle = newAngle;
      distance = newDistance;

      if (distance >= 2 && distance <= MAX_DISTANCE) {
        detectedDistances[angle] = distance;
      } else {
        detectedDistances[angle] = -1;
      }
    }
  }
  catch (Exception e) {
    println("Invalid data received: " + data);
  }
}

void drawTitle() {
  fill(0, 255, 100);
  textAlign(CENTER);
  textSize(26);

  text("LIVE ULTRASONIC RADAR", width / 2, 35);

  stroke(0, 100, 50);
  line(30, 50, width - 30, 50);
}

void drawRadar() {
  float cx = width / 2.0;
  float cy = height - 100;

  pushMatrix();
  translate(cx, cy);

  noFill();
  stroke(0, 180, 70);
  strokeWeight(1.5);

  // Draw semicircular distance rings.
  for (int d = 60; d <= MAX_DISTANCE; d += 60) {
    float r = map(d, 0, MAX_DISTANCE, 0, RADAR_RADIUS);

    arc(0, 0, r * 2, r * 2, PI, TWO_PI);

    fill(0, 255, 100);
    textAlign(CENTER);
    textSize(12);
    text(d + " cm", 0, -r + 15);

    noFill();
  }

  // Draw angle guide lines.
  for (int a = 0; a <= 180; a += 30) {
    float x = RADAR_RADIUS * cos(radians(a));
    float y = -RADAR_RADIUS * sin(radians(a));

    line(0, 0, x, y);
  }

  // Draw the baseline.
  line(-RADAR_RADIUS, 0, RADAR_RADIUS, 0);

  popMatrix();
}

void drawDetections() {
  float cx = width / 2.0;
  float cy = height - 100;

  // Plot the latest valid detection at every angle.
  for (int a = 0; a <= 180; a++) {
    float d = detectedDistances[a];

    if (d >= 2 && d <= MAX_DISTANCE) {
      float r = map(d, 0, MAX_DISTANCE, 0, RADAR_RADIUS);

      float x = cx + r * cos(radians(a));
      float y = cy - r * sin(radians(a));

      // Red detection point.
      noStroke();
      fill(255, 30, 30);
      circle(x, y, 8);
    }
  }
}

void drawScanLine() {
  float cx = width / 2.0;
  float cy = height - 100;

  float x = cx + RADAR_RADIUS * cos(radians(angle));
  float y = cy - RADAR_RADIUS * sin(radians(angle));

  // Main scanning line.
  stroke(0, 255, 80);
  strokeWeight(3);
  line(cx, cy, x, y);

  // Scanner origin.
  noStroke();
  fill(0, 255, 80);
  circle(cx, cy, 10);
}

void drawInformation() {
  fill(0, 255, 100);
  textAlign(LEFT);
  textSize(17);

  text("PORT: COM5", 30, 85);
  text("ANGLE: " + angle + " deg", 30, 115);

  if (distance >= 2 && distance <= MAX_DISTANCE) {
    text("DISTANCE: " + nf(distance, 0, 1) + " cm",
         30, 145);
    text("STATUS: OBJECT DETECTED", 30, 175);
  } else {
    text("DISTANCE: NO ECHO", 30, 145);
    text("STATUS: NO OBJECT IN RANGE", 30, 175);
  }

  text("MAX RANGE: " + MAX_DISTANCE + " cm", 30, 205);

  fill(180);
  textSize(13);

  text("GREEN = SCANNING LINE", 30, height - 35);
  text("RED = DETECTED OBJECT", 30, height - 15);

  textAlign(RIGHT);
  text("ARDUINO UNO + HC-SR04", width - 30, height - 20);
}

