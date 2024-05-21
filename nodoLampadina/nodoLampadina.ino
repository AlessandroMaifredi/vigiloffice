

// === ALARM ===

enum ALARM_SYSTEM_STATUS {
  ALARM_ENABLED,
  ALARM_DISABLED
};

ALARM_SYSTEM_STATUS alarmSystemStatus = ALARM_ENABLED;

enum ALARM_STATUS {
  ALARM_ACTIVE,
  ALARM_NORMAL
};

volatile ALARM_STATUS alarmStatus = ALARM_NORMAL;


// === PHOTORESISTOR ===

#define LIGHT_SENSOR_PIN A0
volatile unsigned int lightValue = 0;

enum LIGHT_SENSOR_STATUS {
  LIGHT_SENSOR_ENABLED,
  LIGHT_SENSOR_DISABLED
};

LIGHT_SENSOR_STATUS lightSensorStatus = LIGHT_SENSOR_ENABLED;

enum LIGHT_STATUS {
  LIGHT_LOW,
  LIGHT_NORMAL
};

volatile LIGHT_STATUS lightStatus = LIGHT_NORMAL;

unsigned int lowLightTreshold = 450;

unsigned long lightReadingInterval = 3500;


void readLight() {
  static unsigned long lastLightReading = millis();
  if (lightSensorStatus == LIGHT_SENSOR_ENABLED) {
    if (millis() - lastLightReading > lightReadingInterval) {
      lightValue = analogRead(LIGHT_SENSOR_PIN);
      if (lightValue <= lowLightTreshold) {
        lightStatus = LIGHT_LOW;
        Serial.println(F("Set LIGHT to LIGHT_LOW"));
      } else {
        lightStatus = LIGHT_NORMAL;
        Serial.println(F("Set LIGHT to LIGHT_NORMAL"));
      }
      lastLightReading = millis();
    }
  }
}

// === FLAME SENSOR ===

#define FLAME_SENSOR_PIN D7

enum FLAME_SENSOR_STATUS {
  FLAME_SENSOR_ENABLED,
  FLAME_SENSOR_DISABLED
};

FLAME_SENSOR_STATUS flameSensorStatus = FLAME_SENSOR_ENABLED;

enum FLAME_STATUS {
  FLAME_PRESENT,
  FLAME_ABSENT
};

volatile FLAME_STATUS flameStatus = FLAME_ABSENT;

unsigned long flameReadingInterval = 1000;

void readFlame() {
  static unsigned long lastFlameReading = millis();
  if (flameSensorStatus == FLAME_SENSOR_ENABLED) {
    if (millis() - lastFlameReading > flameReadingInterval) {
      if (digitalRead(FLAME_SENSOR_PIN) == HIGH) {
        flameStatus = FLAME_PRESENT;
        Serial.println(F("Set FLAME to FLAME_PRESENT"));
        if (alarmSystemStatus == ALARM_ENABLED) {
          alarmStatus = ALARM_ACTIVE;
          Serial.println(F("Set ALARM to ALARM_ACTIVE"));
        }
      } else {
        flameStatus = FLAME_ABSENT;
        Serial.println(F("Set FLAME to FLAME_ABSENT"));
      }
      lastFlameReading = millis();
    }
  }
}

// === RGB ===

#define RGB_RED_PIN D3
#define RGB_GREEN_PIN D2
#define RGB_BLUE_PIN D1

enum RGB_STATUS {
  RGB_ENABLED,
  RGB_DISABLED,
};

RGB_STATUS rgbStatus = RGB_ENABLED;

void setRGB(byte red, byte green, byte blue) {
  digitalWrite(RGB_RED_PIN, red);
  digitalWrite(RGB_GREEN_PIN, green);
  digitalWrite(RGB_BLUE_PIN, blue);
}

void setRGBOff() {
  setRGB(LOW, LOW, LOW);
}

void setRGBOn() {
  setRGB(HIGH, LOW, LOW);
}

void setRGBAlarm() {
  setRGB(HIGH, LOW, LOW);
}

void updateRGB() {
  if (rgbStatus == RGB_ENABLED) {
    if (alarmStatus == ALARM_ACTIVE) {
      setRGBAlarm();
    } else {
      switch (lightStatus) {
        case LIGHT_LOW:
          setRGBOn();
          break;
        case LIGHT_NORMAL:
          setRGBOff();
          break;
      }
    }
  }
}

void setup() {
  Serial.begin(9600);
  pinMode(LIGHT_SENSOR_PIN, INPUT);

  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);

  setRGBOff();

  pinMode(FLAME_SENSOR_PIN, INPUT);
}

void loop() {
  readFlame();
  readLight();
  updateRGB();
  //sendData();
}
