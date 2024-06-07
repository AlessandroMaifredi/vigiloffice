#include "wiring_private.h"
#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include <DHT.h>
#include "secrets.h"
#include "sensorsJsonNames.h"



// === LOGGING ===
#ifdef ENABLE_LOGS
enum LOG_LEVEL {
  LOG_COMM,
  LOG_SENSORS,
  LOG_ALARMS,
  LOG_ALL,
  LOG_OFF,
};

LOG_LEVEL logLevel = LOG_ALL;
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

// === TEMP & HUM SENSOR ===

#define DHTPIN D6
#define DHTTYPE DHT11
DHT dht = DHT(DHTPIN, DHTTYPE);

enum TEMP_SENSOR_STATUS {
  TEMP_SENSOR_ENABLED,
  TEMP_SENSOR_DISABLED
};

TEMP_SENSOR_STATUS tempSensorStatus = TEMP_SENSOR_ENABLED;

enum TEMP_STATUS {
  TEMP_LOW,
  TEMP_NORM,
  TEMP_HIGH,
};

volatile TEMP_STATUS tempStatus = TEMP_NORM;


unsigned long tempReadingInterval = 60000;

int lowTempThreshold = 18;

int highTempThreshold = 24;

int tempTarget = 21;

int temp;
int hum;

void readTemp() {
  static unsigned long lastTempReading = millis();
  if (tempSensorStatus == TEMP_SENSOR_ENABLED) {
    if (millis() - lastTempReading > tempReadingInterval) {
      temp = dht.readTemperature();
      hum = dht.readHumidity();
      simulateHVAC();
      if (temp >= highTempThreshold) {
        tempStatus = TEMP_HIGH;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set TEMP to TEMP_HIGH"));
        }
#endif
        activateAlarm();
      } else if (temp <= lowTempThreshold) {
        tempStatus = TEMP_LOW;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set TEMP to TEMP_LOW"));
        }
#endif
        activateAlarm();
      } else {
        tempStatus = TEMP_NORM;
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_SENSORS) {
          Serial.println(F("Set TEMP to TEMP_NORM"));
        }
#endif
      }
      lastTempReading = millis();
    }
  }
}

// === SIMULATED HVAC MODULE ===

enum HVAC_SENSOR_STATUS {
  HVAC_SENSOR_ENABLED,
  HVAC_SENSOR_DISABLED
};

HVAC_SENSOR_STATUS hvacSensorStatus = HVAC_SENSOR_DISABLED;

void simulateHVAC() {
  if (hvacSensorStatus == HVAC_SENSOR_ENABLED) {
    if (tempStatus == TEMP_LOW) {
      temp += 2;
    } else if (tempStatus == TEMP_HIGH) {
      temp -= 2;
    } else {
      int targetDiff = tempTarget - temp;
      if (targetDiff > 0) {
        temp += 1;
      } else if (targetDiff < 0) {
        temp -= 1;
      }
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

volatile bool applyChanges = false;

void updateStatusDoc() {
  statusDoc[F("mac-address")] = macAddress;

  JsonObject tempSensor = statusDoc.createNestedObject(TEMP_SENSOR_JSON_NAME);
  tempSensor[SENSOR_TEMP_VALUE_JSON_NAME] = temp;
  tempSensor[SENSOR_HUM_VALUE_JSON_NAME] = hum;
  tempSensor[STATUS_JSON_NAME] = tempStatus;
  tempSensor[SENSOR_STATUS_JSON_NAME] = tempSensorStatus == TEMP_SENSOR_ENABLED ? true : false;
  tempSensor[SENSOR_READING_INTERVAL_JSON_NAME] = tempReadingInterval;
  tempSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME] = highTempThreshold;
  tempSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = lowTempThreshold;
  tempSensor[SENSOR_TEMP_TARGET_JSON_NAME] = highTempThreshold;

  JsonObject hvacSensor = statusDoc.createNestedObject(VENT_ACTUATOR_JSON_NAME);
  hvacSensor[SENSOR_STATUS_JSON_NAME] = hvacSensorStatus == HVAC_SENSOR_ENABLED ? true : false;

  JsonObject flameSensor = statusDoc.createNestedObject(FLAME_SENSOR_JSON_NAME);
  flameSensor[SENSOR_TEMP_VALUE_JSON_NAME] = flameStatus == FLAME_PRESENT ? 1 : 0;
  flameSensor[STATUS_JSON_NAME] = flameStatus;
  flameSensor[SENSOR_STATUS_JSON_NAME] = flameSensorStatus == FLAME_SENSOR_ENABLED ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = flameReadingInterval;

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

  JsonObject tempSensor = controlDoc[TEMP_SENSOR_JSON_NAME].as<JsonObject>();
  temp = tempSensor[SENSOR_TEMP_VALUE_JSON_NAME];
  hum = tempSensor[SENSOR_HUM_VALUE_JSON_NAME];
  tempStatus = tempSensor[STATUS_JSON_NAME];
  tempSensorStatus = tempSensor[SENSOR_STATUS_JSON_NAME] == true ? TEMP_SENSOR_ENABLED : TEMP_SENSOR_DISABLED;
  tempReadingInterval = tempSensor[SENSOR_READING_INTERVAL_JSON_NAME];
  highTempThreshold = tempSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME];
  lowTempThreshold = tempSensor[SENSOR_LOW_THRESHOLD_JSON_NAME];
  tempTarget = tempSensor[SENSOR_TEMP_TARGET_JSON_NAME];

  JsonObject hvacSensor = controlDoc[VENT_ACTUATOR_JSON_NAME].as<JsonObject>();
  hvacSensorStatus = hvacSensor[SENSOR_STATUS_JSON_NAME] == true ? HVAC_SENSOR_ENABLED : HVAC_SENSOR_DISABLED;

  JsonObject flameSensor = controlDoc[FLAME_SENSOR_JSON_NAME].as<JsonObject>();
  flameStatus = flameSensor[STATUS_JSON_NAME];
  flameSensorStatus = flameSensor[SENSOR_STATUS_JSON_NAME] == true ? FLAME_SENSOR_ENABLED : FLAME_SENSOR_DISABLED;
  flameReadingInterval = flameSensor[SENSOR_READING_INTERVAL_JSON_NAME];
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
  /*
  pinMode(RGB_RED_PIN, OUTPUT);
  pinMode(RGB_GREEN_PIN, OUTPUT);
  pinMode(RGB_BLUE_PIN, OUTPUT);

  setRGBOff();
  */

  dht.begin();

  pinMode(FLAME_SENSOR_PIN, INPUT);

  commSetup();
}

void loop() {
  readFlame();
  readTemp();
  commLoop();
}