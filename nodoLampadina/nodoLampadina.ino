#include <ArduinoJson.h>

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

void disableAlarm() {
  alarmSystemStatus = ALARM_DISABLED;
}

void enableAlarm() {
  alarmSystemStatus = ALARM_ENABLED;
}

void activateAlarm() {
  if (alarmSystemStatus == ALARM_ENABLED) {
    alarmStatus = ALARM_ACTIVE;
    Serial.println("!!ALARM ACTIVATED!!");
  }
}

void deactivateAlarm() {
  alarmStatus = ALARM_NORMAL;
  Serial.println("SHUT OFF ALARM!");
}

// === PIR MOTION ===

#define MOTION_SENSOR_PIN D6

enum MOTION_SENSOR_STATUS {
  MOTION_SENSOR_ENABLED,
  MOTION_SENSOR_DISABLED
};

MOTION_SENSOR_STATUS motionSensorStatus = MOTION_SENSOR_DISABLED;

enum MOTION_STATUS {
  MOTION_DETECTED,
  MOTION_NORMAL,
  MOTION_INIT
};

volatile MOTION_STATUS motionStatus = MOTION_INIT;

#define MOTION_INIT_TIME_DELAY 80000

volatile unsigned long motionInitTimer;

void readMotion() {
  if (motionSensorStatus == MOTION_SENSOR_ENABLED) {
    if (motionStatus == MOTION_INIT) {
      if (millis() - motionInitTimer > MOTION_INIT_TIME_DELAY) {
        motionInitTimer = millis();
        motionStatus = MOTION_NORMAL;
        Serial.println("MOTION SENSOR INIT COMPLETE");
      }
    } else {
      motionStatus = digitalRead(MOTION_SENSOR_PIN) == HIGH ? MOTION_DETECTED : MOTION_NORMAL;
      if (motionStatus == MOTION_DETECTED) {
        Serial.println("Set MOTION to MOTION_DETECTED!");
        activateAlarm();
      } else {
        Serial.println("Set MOTION to MOTION_NORMAL!");
      }
    }
  }
}


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
      Serial.print(F("LIGHT: "));
      Serial.println(lightValue);
      if (lightValue >= lowLightTreshold) {
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
        activateAlarm();
      } else {
        flameStatus = FLAME_ABSENT;
        Serial.println(F("Set FLAME to FLAME_ABSENT"));
      }
      lastFlameReading = millis();
    }
  }
}

// === RGB ===

#define RGB_RED_PIN D2
#define RGB_GREEN_PIN D1
#define RGB_BLUE_PIN D3

enum RGB_SENSOR_STATUS {
  RGB_SENSOR_ENABLED,
  RGB_SENSOR_DISABLED,
};

enum RGB_STATUS {
  RGB_ON,
  RGB_OFF,
  RGB_ALARM,
  RGB_CUSTOM
};

RGB_SENSOR_STATUS rgbSensorStatus = RGB_SENSOR_ENABLED;

RGB_STATUS rgbStatus = RGB_OFF;

void setRGB(byte red, byte green, byte blue) {
  digitalWrite(RGB_RED_PIN, red);
  digitalWrite(RGB_GREEN_PIN, green);
  digitalWrite(RGB_BLUE_PIN, blue);
  rgbStatus = RGB_CUSTOM;
}

void setRGBOff() {
  setRGB(LOW, LOW, LOW);
  rgbStatus = RGB_OFF;
}

void setRGBOn() {
  setRGB(HIGH, HIGH, HIGH);
  rgbStatus = RGB_ON;
}

void setRGBAlarm() {
  setRGB(HIGH, LOW, LOW);
  rgbStatus = RGB_ALARM;
}

void updateRGB() {
  if (rgbSensorStatus == RGB_SENSOR_ENABLED) {
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

#include "wiring_private.h"
#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include "secrets.h"

// MQTT data
#define MQTT_BUFFER_SIZE 1024             // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
String macAddress;

const char *registerTopic;
const char *statusTopic;
const char *controlTopic;
String settingsTopic;

JsonDocument statusDoc;

volatile bool applyChanges = false;

void connectToMQTTBroker() {
  static unsigned long lastDataSend = millis();
  if (!mqttClient.connected()) {  // not connected
    Serial.print(F("\nConnecting to MQTT broker..."));
    while (!mqttClient.connect(MQTT_CLIENTID, MQTT_USERNAME, MQTT_PASSWORD)) {
      Serial.print(F("."));
      delay(1000);
    }
    Serial.println(F("\nConnected!"));

    // connected to broker, subscribe topics
    mqttClient.subscribe(MQTT_TOPIC_WELCOME);
    Serial.println(F("\nSubscribed to welcome topic!"));
  } else {
    if (millis() - lastDataSend > 5000) {
      statusDoc["indirizzo-mac"] = macAddress;
      statusDoc["tipo"] = DEVICE_TYPE;
      JsonArray sensori = statusDoc.createNestedArray("sensori");
      JsonObject lightSensor = sensori.createNestedObject();
      lightSensor["nome"] = "luce";
      lightSensor["misurazione"] = lightValue;
      lightSensor["stato"] = lightStatus;
      lightSensor["abilitato"] = lightSensorStatus == LIGHT_SENSOR_ENABLED ? true : false;

      JsonObject motionSensor = sensori.createNestedObject();
      motionSensor["nome"] = "movimento";
      motionSensor["misurazione"] = motionStatus == MOTION_INIT || motionStatus == MOTION_NORMAL ? 0 : 1;
      motionSensor["stato"] = motionStatus;
      motionSensor["abilitato"] = motionSensorStatus == MOTION_SENSOR_ENABLED ? true : false;

      JsonObject flameSensor = sensori.createNestedObject();
      flameSensor["nome"] = "fiamma";
      flameSensor["misurazione"] = flameStatus == FLAME_PRESENT ? 1 : 0;
      flameSensor["stato"] = flameStatus;
      flameSensor["abilitato"] = flameSensorStatus == FLAME_SENSOR_ENABLED ? true : false;

      JsonObject RGBLed = sensori.createNestedObject();
      RGBLed["nome"] = "rgb";
      RGBLed["misurazione"] = rgbStatus;
      RGBLed["stato"] = rgbStatus;
      RGBLed["abilitato"] = rgbSensorStatus == RGB_SENSOR_ENABLED ? true : false;


      JsonObject alarm = statusDoc.createNestedObject("allarme");
      alarm["stato"] = alarmStatus == ALARM_NORMAL ? false : true;
      alarm["abilitato"] = alarmSystemStatus == ALARM_ENABLED ? true : false;

      // Serialize JSON to a buffer
      char buffer[1024];
      size_t n = serializeJson(statusDoc, buffer);

      // Print the serialized JSON
      Serial.println(buffer);
      mqttClient.publish(statusTopic, buffer, n, false, 1);
      lastDataSend = millis();
    }
  }
}

void mqttMessageReceived(String &topic, String &payload) {
  // this function handles a message from the MQTT broker
  Serial.println("Incoming MQTT message: " + topic + " - " + payload);
  if (topic == MQTT_TOPIC_WELCOME) {
    JsonDocument doc;
    deserializeJson(doc, payload);
    registerTopic = doc["registerTopic"];
    JsonDocument settingsDoc;
    settingsDoc["indirizzo-mac"] = macAddress;
    settingsDoc["tipo"] = DEVICE_TYPE;
    char buffer[128];
    size_t n = serializeJson(settingsDoc, buffer);
    settingsTopic = registerTopic + String("/") + macAddress;
    mqttClient.subscribe(settingsTopic);
    mqttClient.publish(registerTopic, buffer, n);
  } else if (topic == settingsTopic) {
    JsonDocument doc;
    deserializeJson(doc, payload);
    statusTopic = doc["statusTopic"];
    controlTopic = doc["controlTopic"];
    mqttClient.subscribe(statusTopic);
    mqttClient.subscribe(controlTopic);
  } else if (topic == controlTopic) {
  }
}

void commSetup() {
  mqttClient.begin(MQTT_BROKERIP, 1883, networkClient);  // setup communication with MQTT broker
  mqttClient.onMessage(mqttMessageReceived);             // callback on message received from MQTT broker
  WiFiManager wifiManager;
  //wifiManager.resetSettings();
  wifiManager.autoConnect(AP_NAME);
  macAddress = WiFi.macAddress();
}

void commLoop() {
  connectToMQTTBroker();  // connect to MQTT broker (if not already connected)
  mqttClient.loop();      // MQTT client loop
}


void setup() {
  Serial.begin(9600);
  pinMode(LIGHT_SENSOR_PIN, INPUT);

  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);

  setRGBOff();

  pinMode(FLAME_SENSOR_PIN, INPUT);

  pinMode(MOTION_SENSOR_PIN, INPUT);
  motionStatus = MOTION_INIT;
  motionInitTimer = millis();
  commSetup();
}

void loop() {
  readFlame();
  readLight();
  readMotion();
  updateRGB();
  commLoop();
}
