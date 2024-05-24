#include "wiring_private.h"
#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include "secrets.h"

// MQTT data
#define MQTT_BUFFER_SIZE 512              // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"

const char *registerTopic;
const char *statusTopic;
const char *controlTopic;
const char *settingsTopic;

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
      //update json with current status
      //publish on statusTopic
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
    doc["macAddress"] = "mac";
    doc["type"] = DEVICE_TYPE;
    char buffer[128];
    size_t n = serializeJson(settingsDoc, buffer);
    String newSettingsTopic = registerTopic + "mac";
    settingsTopic = newSettingsTopic.c_str();
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
    //deserialize status json
    //update status json
    //set applyChanges to true
    applyChanges = true;
  }
}


void commSetup() {
  mqttClient.begin(MQTT_BROKERIP, 1883, networkClient);  // setup communication with MQTT broker
  mqttClient.onMessage(mqttMessageReceived);             // callback on message received from MQTT broker
  WiFiManager wifiManager;
  //wifiManager.resetSettings();
  wifiManager.autoConnect(AP_NAME);
}

void commLoop(std::function<void(JsonDocument)> callback) {
  connectToMQTTBroker();  // connect to MQTT broker (if not already connected)
  mqttClient.loop();      // MQTT client loop
  if (applyChanges) {
    callback(statusDoc);
    applyChanges = false;
  }
}
