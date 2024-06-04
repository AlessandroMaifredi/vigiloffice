#include "wiring_private.h"
#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include "secrets.h"
#include "sensorsJsonNames.h"


#ifdef ENABLE_LOGS

// === LOGGING ===

enum LOG_LEVEL {
  LOG_COMM,
  LOG_SENSORS,
  LOG_ALARMS,
  LOG_ALL,
  LOG_OFF,
};

LOG_LEVEL logLevel = LOG_COMM;

#endif

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
#ifdef ENABLE_LOGS
    if (logLevel != LOG_OFF) {
      Serial.println(F("!!ALARM ACTIVATED!!"));
    }
#endif
  }
}

void deactivateAlarm() {
  alarmStatus = ALARM_NORMAL;
#ifdef ENABLE_LOGS
  if (logLevel != LOG_OFF) {
    Serial.println(F("SHUT OFF ALARM!"));
  }
#endif
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
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("MOTION SENSOR INIT COMPLETE"));
        }
#endif
      }
    } else {
      motionStatus = digitalRead(MOTION_SENSOR_PIN) == HIGH ? MOTION_DETECTED : MOTION_NORMAL;
      if (motionStatus == MOTION_DETECTED) {
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set MOTION to MOTION_DETECTED!"));
        }
#endif
        activateAlarm();
      } else {
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set MOTION to MOTION_NORMAL!"));
        }
#endif
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
  LIGHT_NORMAL,
  LIGHT_LOW
};

volatile LIGHT_STATUS lightStatus = LIGHT_NORMAL;

unsigned int lowLightTreshold = 450;

unsigned long lightReadingInterval = 3500;


void readLight() {
  static unsigned long lastLightReading = millis();
  if (lightSensorStatus == LIGHT_SENSOR_ENABLED) {
    if (millis() - lastLightReading > lightReadingInterval) {
      lightValue = analogRead(LIGHT_SENSOR_PIN);
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
        Serial.print(F("LIGHT: "));
        Serial.println(lightValue);
      }
#endif
      if (lightValue >= lowLightTreshold) {
        lightStatus = LIGHT_LOW;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set LIGHT to LIGHT_LOW"));
        }
#endif
      } else {
        lightStatus = LIGHT_NORMAL;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set LIGHT to LIGHT_NORMAL"));
        }
#endif
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
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set FLAME to FLAME_PRESENT"));
        }
#endif
        activateAlarm();
      } else {
        flameStatus = FLAME_ABSENT;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set FLAME to FLAME_ABSENT"));
        }
#endif
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
  RGB_OFF,
  RGB_ON,
  RGB_ALARM,
  RGB_CUSTOM_ON,
  RGB_CUSTOM_OFF
};

RGB_SENSOR_STATUS rgbSensorStatus = RGB_SENSOR_ENABLED;

RGB_STATUS rgbStatus = RGB_OFF;

void setRGB(byte red, byte green, byte blue) {
  digitalWrite(RGB_RED_PIN, red);
  digitalWrite(RGB_GREEN_PIN, green);
  digitalWrite(RGB_BLUE_PIN, blue);
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
      if (rgbStatus != RGB_CUSTOM_ON && rgbStatus != RGB_CUSTOM_OFF) {
        switch (lightStatus) {
          case LIGHT_LOW:
            setRGBOn();
            break;
          case LIGHT_NORMAL:
            setRGBOff();
            break;
        }
      } else {
        switch (rgbStatus) {
          case RGB_CUSTOM_ON:
            setRGB(HIGH, HIGH, HIGH);
            break;
          case RGB_CUSTOM_OFF:
            setRGB(LOW, LOW, LOW);
            break;
          case RGB_OFF:
          case RGB_ON:
          case RGB_ALARM:
          default:
            break;
        }
      }
    }
  }
}



// MQTT data
#define MQTT_BUFFER_SIZE 1024             // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
#define MQTT_TOPIC_LWT "vigiloffice/lwt"
String macAddress;

String registerTopic = "";
String statusTopic = "";
String controlTopic = "";
String settingsTopic = "";

JsonDocument statusDoc;

volatile bool applyChanges = false;

void updateStatusDoc() {
  statusDoc[F("mac-address")] = macAddress;
  statusDoc[F("type")] = DEVICE_TYPE;
  JsonArray sensors = statusDoc.createNestedArray(F("sensors"));
  JsonObject lightSensor = sensors.createNestedObject();
  lightSensor[SENSOR_NAME_JSON_NAME] = LIGHT_JSON_NAME;
  lightSensor[SENSOR_VALUE_JSON_NAME] = lightValue;
  lightSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = lowLightTreshold;
  lightSensor[STATUS_JSON_NAME] = lightStatus;
  lightSensor[SENSOR_STATUS_JSON_NAME] = lightSensorStatus == LIGHT_SENSOR_ENABLED ? true : false;
  lightSensor[SENSOR_READING_INTERVAL_JSON_NAME] = lightReadingInterval;

  JsonObject motionSensor = sensors.createNestedObject();
  motionSensor[SENSOR_NAME_JSON_NAME] = MOTION_JSON_NAME;
  motionSensor[SENSOR_VALUE_JSON_NAME] = motionStatus == MOTION_INIT || motionStatus == MOTION_NORMAL ? 0 : 1;
  motionSensor[STATUS_JSON_NAME] = motionStatus;
  motionSensor[SENSOR_STATUS_JSON_NAME] = motionSensorStatus == MOTION_SENSOR_ENABLED ? true : false;

  JsonObject flameSensor = sensors.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[SENSOR_VALUE_JSON_NAME] = flameStatus == FLAME_PRESENT ? 1 : 0;
  flameSensor[STATUS_JSON_NAME] = flameStatus;
  flameSensor[SENSOR_STATUS_JSON_NAME] = flameSensorStatus == FLAME_SENSOR_ENABLED ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = flameReadingInterval;

  JsonObject RGBLed = sensors.createNestedObject();
  RGBLed[SENSOR_NAME_JSON_NAME] = RGB_JSON_NAME;
  RGBLed[SENSOR_VALUE_JSON_NAME] = rgbStatus;
  RGBLed[STATUS_JSON_NAME] = rgbStatus;
  RGBLed[SENSOR_STATUS_JSON_NAME] = rgbSensorStatus == RGB_SENSOR_ENABLED ? true : false;

  JsonObject alarm = statusDoc.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = alarmStatus == ALARM_NORMAL ? false : true;
  alarm[SENSOR_STATUS_JSON_NAME] = alarmSystemStatus == ALARM_ENABLED ? true : false;

  statusDoc.shrinkToFit();
}

void connectToMQTTBroker() {
  static unsigned long lastDataSend = millis();
  if (!mqttClient.connected()) {  // not connected
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.print(F("\nConnecting to MQTT broker..."));
    }
#endif
    updateStatusDoc();
    char buffer[1024];
    serializeJson(statusDoc, buffer);
    String lwtTopic = MQTT_TOPIC_LWT + macAddress;
    mqttClient.setWill(lwtTopic.c_str(), buffer, true, 1);
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.print(F("LWT message set!"));
    }
#endif
    while (!mqttClient.connect(MQTT_CLIENTID, MQTT_USERNAME, MQTT_PASSWORD)) {
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
        Serial.print(F("."));
      }
#endif
      delay(1000);
    }
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.println(F("\nConnected!"));
    }
#endif
    // connected to broker, subscribe topics
    mqttClient.subscribe(MQTT_TOPIC_WELCOME);
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.println(F("\nSubscribed to welcome topic!"));
    }
#endif
  } else {
    if (statusTopic != "" && millis() - lastDataSend > 5000) {

      updateStatusDoc();

      // Serialize JSON to a buffer
      char buffer[1024];
      size_t n = serializeJson(statusDoc, buffer);

#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
        Serial.print(F("Sending status on "));
        Serial.println(statusTopic);
        Serial.println(buffer);
      }
#endif
      mqttClient.publish(statusTopic.c_str(), buffer, n, false, 1);
      lastDataSend = millis();
    }
  }
}

void mqttMessageReceived(String &topic, String &payload) {
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.println(F("Incoming MQTT message: ") + topic + F(" - ") + payload);
  }
#endif
  if (topic == MQTT_TOPIC_WELCOME) {
    JsonDocument doc;
    deserializeJson(doc, payload);
    setRegisterTopic(doc);
  } else if (topic == settingsTopic) {
    JsonDocument doc;
    deserializeJson(doc, payload);
    setTopics(doc);
  } else if (topic == controlTopic) {
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.println(F("Control topic!"));
    }
#endif
    JsonDocument controlDoc;
    deserializeJson(controlDoc, payload);
    applyControlChanges(controlDoc);
  }
}

void setRegisterTopic(JsonDocument doc) {
  registerTopic = String(doc[F("registerTopic")]);
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.print(F("Recieved register topic: "));
    Serial.println(registerTopic);
  }
#endif
  JsonDocument settingsDoc;
  settingsDoc[F("mac-address")] = macAddress;
  settingsDoc[F("type")] = DEVICE_TYPE;
  char buffer[512];
  size_t n = serializeJson(settingsDoc, buffer);
  settingsTopic = registerTopic + String(F("/")) + macAddress;
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.print(F("Setting topic is: "));
    Serial.println(settingsTopic);
  }
#endif
  mqttClient.subscribe(settingsTopic.c_str());
  mqttClient.publish(registerTopic.c_str(), buffer, n);
}

void setTopics(JsonDocument topicsDoc) {
  statusTopic = String(topicsDoc[F("statusTopic")]);
  controlTopic = String(topicsDoc[F("controlTopic")]);
  //mqttClient.subscribe(statusTopic);
  mqttClient.subscribe(controlTopic.c_str());
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.print(F("Status topic set to: "));
    Serial.println(statusTopic);
    Serial.print(F("Control topic set to: "));
    Serial.println(controlTopic);
  }
#endif
}

void applyControlChanges(JsonDocument controlDoc) {
  JsonObject allarme = controlDoc[ALARM_JSON_NAME].as<JsonObject>();
  alarmStatus = allarme[STATUS_JSON_NAME] == true ? ALARM_ACTIVE : ALARM_NORMAL;
  alarmSystemStatus = allarme[SENSOR_STATUS_JSON_NAME] == true ? ALARM_ENABLED : ALARM_DISABLED;
  JsonArray sensors = controlDoc[F("sensors")].as<JsonArray>();
  for (JsonVariant v : sensors) {
    JsonObject sensor = v.as<JsonObject>();
    String nome = String(sensor[SENSOR_NAME_JSON_NAME]);
    if (nome == LIGHT_JSON_NAME) {
      lightStatus = sensor[STATUS_JSON_NAME];
      lightSensorStatus = sensor[SENSOR_STATUS_JSON_NAME] == true ? LIGHT_SENSOR_ENABLED : LIGHT_SENSOR_DISABLED;
      lowLightTreshold = sensor[SENSOR_LOW_THRESHOLD_JSON_NAME];
      lightReadingInterval = sensor[SENSOR_READING_INTERVAL_JSON_NAME];
    } else if (nome == MOTION_JSON_NAME) {
      motionStatus = sensor[STATUS_JSON_NAME];
      motionSensorStatus = sensor[SENSOR_STATUS_JSON_NAME] == true ? MOTION_SENSOR_ENABLED : MOTION_SENSOR_DISABLED;
    } else if (nome == FLAME_JSON_NAME) {
      flameStatus = sensor[STATUS_JSON_NAME];
      flameSensorStatus = sensor[SENSOR_STATUS_JSON_NAME] == true ? FLAME_SENSOR_ENABLED : FLAME_SENSOR_DISABLED;
      flameReadingInterval = sensor[SENSOR_READING_INTERVAL_JSON_NAME];
    } else if (nome == RGB_JSON_NAME) {
      rgbStatus = sensor[STATUS_JSON_NAME];
      rgbSensorStatus = sensor[SENSOR_STATUS_JSON_NAME] == true ? RGB_SENSOR_ENABLED : RGB_SENSOR_DISABLED;
    }
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
#ifdef ENABLE_LOGS
  Serial.begin(115200);
#endif
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
  commLoop();
  updateRGB();
}