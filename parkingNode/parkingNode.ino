#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include "secrets.h"
#include "sensorJsonNames.h"
#include <time.h>
#include <ArduinoOTA.h>
extern "C" {
#include "user_interface.h"
}

#define ENABLE_LOGS true

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

// === TIME ===
unsigned long checkSleepInterval = 300000;

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

// === FLAME SENSOR ===
#define FLAME_SENSOR_PIN D7

enum FLAME_SENSOR_STATUS {
  FLAME_SENSOR_ENABLED,
  FLAME_SENSOR_DISABLED
};

enum FLAME_STATUS {
  FLAME_PRESENT,
  FLAME_ABSENT
};

FLAME_SENSOR_STATUS flameSensorStatus = FLAME_SENSOR_ENABLED;

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

// === FLOODING ===
#define FLOODING_SENSOR_PIN A0

enum FLOODING_SENSOR_STATUS {
  FLOODING_SENSOR_ENABLED,
  FLOODING_SENSOR_DISABLED
};

enum FLOODING_STATUS {
  FLOODING_PRESENT,
  FLOODING_ABSENT
};

FLOODING_SENSOR_STATUS floodingSensorStatus = FLOODING_SENSOR_ENABLED;
volatile FLOODING_STATUS floodingStatus = FLOODING_ABSENT;
unsigned int floodingHighThreshold = 100;
unsigned long floodingReadingInterval = 1000;

void readFlooding() {
  static unsigned long lastFloodingReading = millis();
  if (floodingSensorStatus == FLOODING_SENSOR_ENABLED) {
    if (millis() - lastFloodingReading >= floodingReadingInterval) {
      if (analogRead(FLOODING_SENSOR_PIN) > floodingHighThreshold) {
        floodingStatus = FLOODING_PRESENT;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set FLOODING to FLOODING_PRESENT"));
        }
#endif
        activateAlarm();
      } else {
        floodingStatus = FLOODING_ABSENT;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set FLOODING to FLOODING_ABSENT"));
        }
#endif
      }
      lastFloodingReading = millis();
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
  RGB_OCCUPIED,
  RGB_AVAILABLE,
  RGB_RESERVED
};

RGB_SENSOR_STATUS rgbSensorStatus = RGB_SENSOR_ENABLED;
RGB_STATUS rgbStatus;

void setRGB(byte red, byte green, byte blue) {
  digitalWrite(RGB_RED_PIN, red);
  digitalWrite(RGB_GREEN_PIN, green);
  digitalWrite(RGB_BLUE_PIN, blue);
}

void setRGBOff() {
  setRGB(LOW, LOW, LOW);
  rgbStatus = RGB_OFF;
}

void setRGBOccupied() {
  setRGB(HIGH, LOW, LOW);
  rgbStatus = RGB_OCCUPIED;
}

void setRGBAvailable() {
  setRGB(LOW, HIGH, LOW);
  rgbStatus = RGB_AVAILABLE;
}

void setRGBReserved() {
  setRGB(LOW, LOW, HIGH);
  rgbStatus = RGB_RESERVED;
}

void updateRGB() {
  switch (rgbStatus) {
    case RGB_OFF:
      setRGBOff();
      break;
    case RGB_OCCUPIED:
      setRGBOccupied();
      break;
    case RGB_AVAILABLE:
      setRGBAvailable();
      break;
    case RGB_RESERVED:
      setRGBReserved();
      break;
  }
}

// === AVOIDANCE ===
#define AVOIDANCE_SENSOR_PIN D5

enum AVOIDANCE_SENSOR_STATUS {
  AVOIDANCE_SENSOR_ENABLED,
  AVOIDANCE_SENSOR_DISABLED
};

enum AVOIDANCE_STATUS {
  AVOIDANCE_PRESENT,
  AVOIDANCE_ABSENT
};

AVOIDANCE_SENSOR_STATUS avoidanceSensorStatus = AVOIDANCE_SENSOR_ENABLED;
volatile AVOIDANCE_STATUS avoidanceStatus = AVOIDANCE_ABSENT;
unsigned long avoidanceReadingInterval = 1000;

void readAvoidance() {
  static unsigned long lastAvoidanceReading = millis();
  if (avoidanceSensorStatus == AVOIDANCE_SENSOR_ENABLED) {
    if (millis() - lastAvoidanceReading >= avoidanceReadingInterval) {
      avoidanceStatus = analogRead(AVOIDANCE_SENSOR_PIN) == LOW ? AVOIDANCE_PRESENT : AVOIDANCE_ABSENT;
      if (rgbStatus == RGB_RESERVED) {
        if (avoidanceStatus == AVOIDANCE_PRESENT) {
          setRGBOccupied();
#ifdef ENABLE_LOGS
          if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
            Serial.println(F("Set AVOIDANCE to AVOIDANCE_PRESENT"));
          }
#endif
        }
      } else {
        if (avoidanceStatus == AVOIDANCE_PRESENT) {
          setRGBOccupied();
#ifdef ENABLE_LOGS
          if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
            Serial.println(F("Set AVOIDANCE to AVOIDANCE_PRESENT"));
          }
#endif
        } else {
          setRGBAvailable();
#ifdef ENABLE_LOGS
          if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
            Serial.println(F("Set AVOIDANCE to AVOIDANCE_ABSENT"));
          }
#endif
        }
      }
      lastAvoidanceReading = millis();
    }
  }
}

// MQTT data
#define MQTT_BUFFER_SIZE 1024             // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
#define MQTT_TOPIC_LWT "vigiloffice/lwt/"
String macAddress;

String registerTopic = "";
String statusTopic = "";
String controlTopic = "";
String settingsTopic = "";

JsonDocument statusDoc;

void updateStatusDoc() {
  statusDoc[F("type")] = DEVICE_TYPE;
  statusDoc[F("macAddress")] = macAddress;

  JsonObject floodingSensor = statusDoc.createNestedObject(FLOODING_SENSOR_JSON_NAME);
  floodingSensor[STATUS_JSON_NAME] = floodingStatus;
  floodingSensor[SENSOR_STATUS_JSON_NAME] = floodingSensorStatus == FLOODING_SENSOR_ENABLED ? true : false;
  floodingSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME] = floodingHighThreshold;
  floodingSensor[SENSOR_READING_INTERVAL_JSON_NAME] = flameReadingInterval;

  JsonObject flameSensor = statusDoc.createNestedObject(FLAME_SENSOR_JSON_NAME);
  flameSensor[STATUS_JSON_NAME] = flameStatus;
  flameSensor[SENSOR_STATUS_JSON_NAME] = flameSensorStatus == FLAME_SENSOR_ENABLED ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = flameReadingInterval;

  JsonObject avoidanceSensor = statusDoc.createNestedObject(AVOIDANCE_SENSOR_JSON_NAME);
  avoidanceSensor[STATUS_JSON_NAME] = avoidanceStatus;
  avoidanceSensor[SENSOR_STATUS_JSON_NAME] = avoidanceSensorStatus == AVOIDANCE_SENSOR_ENABLED ? true : false;

  JsonObject rgbLed = statusDoc.createNestedObject(RGB_ACTUATOR_JSON_NAME);
  rgbLed[STATUS_JSON_NAME] = rgbStatus;
  rgbLed[SENSOR_STATUS_JSON_NAME] = rgbSensorStatus == RGB_SENSOR_ENABLED ? true : false;

  JsonObject alarm = statusDoc.createNestedObject(F("alarm"));
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

void mqttMessageReceived(String& topic, String& payload) {
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
  settingsDoc[F("macAddress")] = macAddress;
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
  JsonObject alarm = controlDoc[ALARM_JSON_NAME].as<JsonObject>();
  alarmStatus = alarm[STATUS_JSON_NAME] == true ? ALARM_ACTIVE : ALARM_NORMAL;
  alarmSystemStatus = alarm[SENSOR_STATUS_JSON_NAME] == true ? ALARM_ENABLED : ALARM_DISABLED;

  JsonObject floodingSensor = controlDoc[FLOODING_SENSOR_JSON_NAME].as<JsonObject>();
  floodingStatus = floodingSensor[STATUS_JSON_NAME];
  floodingSensorStatus = floodingSensor[SENSOR_STATUS_JSON_NAME] == true ? FLOODING_SENSOR_ENABLED : FLOODING_SENSOR_DISABLED;
  floodingHighThreshold = floodingSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME];
  floodingReadingInterval = floodingSensor[SENSOR_READING_INTERVAL_JSON_NAME];

  JsonObject flameSensor = controlDoc[FLAME_SENSOR_JSON_NAME].as<JsonObject>();
  flameStatus = flameSensor[STATUS_JSON_NAME];
  flameSensorStatus = flameSensor[SENSOR_STATUS_JSON_NAME] == true ? FLAME_SENSOR_ENABLED : FLAME_SENSOR_DISABLED;
  flameReadingInterval = flameSensor[SENSOR_READING_INTERVAL_JSON_NAME];

  JsonObject avoidanceSensor = controlDoc[AVOIDANCE_SENSOR_JSON_NAME].as<JsonObject>();
  avoidanceStatus = avoidanceSensor[STATUS_JSON_NAME];
  avoidanceSensorStatus = avoidanceSensor[SENSOR_STATUS_JSON_NAME] == true ? AVOIDANCE_SENSOR_ENABLED : AVOIDANCE_SENSOR_DISABLED;

  JsonObject rgbActuator = controlDoc[RGB_ACTUATOR_JSON_NAME].as<JsonObject>();
  rgbStatus = rgbActuator[STATUS_JSON_NAME];
  rgbSensorStatus = rgbActuator[SENSOR_STATUS_JSON_NAME] == true ? RGB_SENSOR_ENABLED : RGB_SENSOR_DISABLED;
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

void wakeUpCallback() {
  Serial.println(F("Parking is opened from 7:00 to 21:00"));
  Serial.flush();
}

void checkForSleep() {
  static unsigned long lastSleepCheck = millis();
  if (millis() - lastSleepCheck > checkSleepInterval) {
    lastSleepCheck = millis();
    time_t now = time(nullptr);
    struct tm* timeInfo = localtime(&now);

    int currentHour = timeInfo->tm_hour;

    if (currentHour == 21) {
      int sleepTimeSeconds;
      sleepTimeSeconds = (24 - currentHour + 7) * 3600 - (timeInfo->tm_min * 60 + timeInfo->tm_sec);

      timed_light_sleep(sleepTimeSeconds * 1000);
    }
  }
}

void timed_light_sleep(unsigned int sleep_time_ms) {
  Serial.print(F("Parking is closed from 21:00 to 7:00"));
  Serial.print(sleep_time_ms);
  Serial.println(F(" ms..."));
  Serial.flush();

  wifi_set_opmode_current(NULL_MODE);
  extern os_timer_t* timer_list;
  timer_list = nullptr;
  wifi_fpm_set_sleep_type(LIGHT_SLEEP_T);
  wifi_fpm_open();
  wifi_fpm_set_wakeup_cb(wakeUpCallback);
  wifi_fpm_do_sleep(sleep_time_ms * 1000);
  esp_delay(sleep_time_ms + 1);
  Serial.println(F("Woke up!"));
}

void otaSetup() {
  ArduinoOTA.setHostname(AP_NAME);
  ArduinoOTA.onStart([]() {  // switch off all the PWMs during upgrade
#ifdef ENABLE_LOGS
    Serial.println(F("Starting OTA."));
#endif
  });
  ArduinoOTA.onEnd([]() {  // do a fancy thing with our board led at end
#ifdef ENABLE_LOGS
    Serial.println(F("OTA finished."));
#endif
  });

  ArduinoOTA.onError([](ota_error_t error) {
    (void)error;
    ESP.restart();
  });
  ArduinoOTA.begin();
}


void setup() {
#ifdef ENABLE_LOGS
  Serial.begin(115200);
#endif

  configTime(0, 0, "pool.ntp.org", "time.nist.gov");

  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);
  setRGBAvailable();
  pinMode(FLAME_SENSOR_PIN, INPUT);
  commSetup();
  otaSetup();
}

void loop() {
  ArduinoOTA.handle();
  checkForSleep();
  readFlame();
  readFlooding();
  readAvoidance();
  commLoop();
  updateRGB();
}