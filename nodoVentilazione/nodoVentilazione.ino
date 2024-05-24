#include <DNSServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include "secrets.h"

// MQTT data
#define MQTT_BUFFER_SIZE 1024               // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);   // handles the MQTT communication protocol
WiFiClient networkClient;                  // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
#define MAC_ADDRESS "08:F9:E0:67:AC:08"

const char *registerTopic;
const char *serverIP;
bool gotRegisterTopic = false;

bool allarmeInCorso = false;
bool allarmeAttivo = true;
bool sensoreTemperaturaAttivo = true;
bool sensoreUmiditaAttivo = true;
bool sensoreFiammaAttivo = false;
bool sensoreInfrarossiAttivo = false;
float temperatura = 24.5;
float umidita = 33.5;
float fiamma = 0.0;
float infrarossi = 0.0;

char message[1024];

void setup() {
  Serial.begin(115200);

  mqttClient.begin(MQTT_BROKERIP, 1883, networkClient);   // setup communication with MQTT broker
  mqttClient.onMessage(mqttMessageReceived);              // callback on message received from MQTT broker

  WiFiManager wifiManager;
  //wifiManager.resetSettings();
  wifiManager.autoConnect("AP Ventilazione - **MAC**");
  Serial.println(F("Connected."));
}

void loop() {
  connectToMQTTBroker();   // connect to MQTT broker (if not already connected)
  mqttClient.loop();       // MQTT client loop
}

void connectToMQTTBroker() {
  if (!mqttClient.connected()) {   // not connected
    Serial.print(F("\nConnecting to MQTT broker..."));
    while (!mqttClient.connect(MQTT_CLIENTID, MQTT_USERNAME, MQTT_PASSWORD)) {
      Serial.print(F("."));
      delay(1000);
    }
    Serial.println(F("\nConnected!"));
    // connected to broker, subscribe topics
    mqttClient.subscribe(MQTT_TOPIC_WELCOME);
    Serial.println(F("\nSubscribed to welcome topic!"));
  }
}

void mqttMessageReceived(String &topic, String &payload) {
  // this function handles a message from the MQTT broker
  Serial.println("Incoming MQTT message: " + topic + " - " + payload);
  if (topic == MQTT_TOPIC_WELCOME) {
    JsonDocument readDoc;
    deserializeJson(readDoc, payload);
    const char *servIP = readDoc["serverIP"];
    const char *regTopic = readDoc["registerTopic"];
    serverIP = servIP;
    registerTopic = regTopic;
    Serial.println(serverIP);
    Serial.println(registerTopic);

    registrazioneDispositivo();
  }
}

void registrazioneDispositivo() {
  JsonDocument doc;

  doc["indirizzo-mac"] = MAC_ADDRESS;
  doc["tipo"] = "ventilazione";

  JsonArray sensori = doc.createNestedArray("sensori");

  JsonObject temperaturaSensor = sensori.createNestedObject();
  temperaturaSensor["nome"] = "temperatura";
  temperaturaSensor["misurazione"] = temperatura;
  temperaturaSensor["attivo"] = sensoreTemperaturaAttivo;

  JsonObject umiditaSensor = sensori.createNestedObject();
  umiditaSensor["nome"] = "umidita";
  umiditaSensor["misurazione"] = umidita;
  umiditaSensor["attivo"] = sensoreUmiditaAttivo;

  JsonObject fiammaSensor = sensori.createNestedObject();
  fiammaSensor["nome"] = "fiamma";
  fiammaSensor["misurazione"] = fiamma;
  fiammaSensor["attivo"] = sensoreFiammaAttivo;

  JsonObject infrarossiSensor = sensori.createNestedObject();
  infrarossiSensor["nome"] = "infrarossi";
  infrarossiSensor["misurazione"] = infrarossi;
  infrarossiSensor["attivo"] = sensoreInfrarossiAttivo;

  JsonObject allarme = doc.createNestedObject("allarme");
  allarme["stato"] = allarmeInCorso;
  allarme["abilitato"] = allarmeAttivo;

  // Serialize JSON to a buffer
  char buffer[512];
  size_t n = serializeJson(doc, buffer);

  // Print the serialized JSON
  Serial.println(buffer);
  mqttClient.publish(registerTopic, buffer, n, false, 1);
}

String boolToString(bool value) {
    return value ? "true" : "false";
}