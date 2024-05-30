#include <DNSServer.h>
#include <ESP8266WebServer.h>
#include <ESP8266WiFi.h>
#include <WiFiManager.h>
#include <LiquidCrystal_I2C.h>
#include <Wire.h>
#include <MQTT.h>
#include <ArduinoJson.h>
#include <InfluxDbClient.h>
#include "sensorsJsonNames.h"
#include "secrets.h"
#include "UriBraces.h"

#define DISPLAY_CHARS 16                                            // number of characters on a line
#define DISPLAY_LINES 2                                             // number of display lines
#define DISPLAY_ADDR 0x27                                           // display address on I2C bus
LiquidCrystal_I2C lcd(DISPLAY_ADDR, DISPLAY_CHARS, DISPLAY_LINES);  // display object

#define MQTT_BUFFER_SIZE 2048             // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
#define MQTT_TOPIC_REGISTER "vigiloffice/register"
#define MQTT_TOPIC_HVAC "hvacs/"
#define MQTT_TOPIC_LAMPS "lamps/"

InfluxDBClient client_idb(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN);
Point pointDeviceLamp("Lamps");
Point pointDeviceHVAC("HVACs");
boolean alarmStatus = false;

// Set web server port number to 80
ESP8266WebServer server(80);

// Variable to store the HTTP request
String header;

// Auxiliary variables to store the current output state
String output0State = "off";
String output4State = "off";

// Assign output variables to GPIO pins
const int output0 = D0;
const int output4 = D4;

void setup() {
  Serial.begin(115200);

  mqttClient.begin(MQTT_BROKERIP, 1883, networkClient);  // setup communication with MQTT broker
  mqttClient.onMessage(mqttMessageReceived);             // callback on message received from MQTT broker

  // Initialize the output variables as outputs
  pinMode(output0, OUTPUT);
  pinMode(output4, OUTPUT);
  // Set outputs to LOW
  digitalWrite(output0, HIGH);
  digitalWrite(output4, HIGH);

  /*Wire.begin();
  Wire.beginTransmission(DISPLAY_ADDR);
  byte error = Wire.endTransmission();

  if (error == 0) {
    Serial.println(F("LCD found."));
    lcd.begin(DISPLAY_CHARS, 2);
    lcd.setBacklight(255);
    lcd.home();
    lcd.clear();
    lcd.setCursor(0, 0);
    lcd.print(F("Connect to SSID:"));
    lcd.setCursor(0, 1);
    lcd.print(F("AP Master - **MAC**"));
  } else {
    Serial.print(F("LCD not found. Error "));
    Serial.println(error);
    Serial.println(F("Check connections and configuration. Reset to try again!"));
    while (true)
      delay(1);
  }*/

  WiFiManager wifiManager;

  wifiManager.autoConnect("AP Vigiloffice Master - **MAC**");

  server.on("/", handle_root);
  server.on("/devices/", handle_devices);

  server.on("/devices/lamps/", handle_intermediate);
  //server.on("/devices/conditioning/", handle_intermediate);

  server.on(UriBraces("/devices/lamps/{}/edit"), handle_single_lamp_edit);
  //server.on(UriBraces("/devices/conditioning/{}/edit"), handle_single_conditioning_edit);

  server.on(UriBraces("/devices/lamps/{}"), handle_single_lamp);
  //server.on(UriBraces("/devices/conditioning/{}"), handle_single_conditioning);

  server.onNotFound(handle_NotFound);
  server.begin();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("Server:"));
  lcd.setCursor(0, 1);
  lcd.print(WiFi.localIP());
}

void loop() {
  server.handleClient();
  connectToMQTTBroker();
  mqttClient.loop();
  check_influxdb();
}

// === WEBSERVER ===

JsonDocument knownDevices;

const String root_html = "<!DOCTYPE html>\
  <html>\
  <head>\
    <title>VigilOffice</title>\
  </head>\
  <body>\
    <button href='/devices'>Manage devices</button>\
    <button href='/alarm'>Manage alarm</button>\
  </button>\
</html>";

String createDevicesPage() {
  String page = "<!DOCTYPE html><html><head><title>VigilOffice</title></head><body><table><th><td>#</td><td>Device type</td><td>Device MAC</td></th>";
  int i = 0;
  JsonArray devices = knownDevices["devices"].as<JsonArray>();
  for (JsonVariant v : devices) {
    JsonObject device = v.as<JsonObject>();
    ++i;
    page += "<tr onclick=\"location.href = '/devices/" + String(device["url"]) + "/" + String(device["mac"]) + "';\">";
    page += "<td>" + String(i) + "</td>";
    page += "<td>" + String(device["type"]) + "</td>";
    page += "<td>" + String(device["mac"]) + "</td>";
    page += "</tr>";
  }
  page += "</table></body></html>";
  return page;
}

void handle_root() {
  Serial.print(F("New Client with IP: "));
  Serial.println(server.client().remoteIP().toString());
  server.send(200, F("text/html"), root_html);
}

void handle_NotFound() {
  server.send(404, F("text/plain"), F("ERROR 404 - Not found"));
}

void handle_devices() {
  Serial.print(F("New Client with IP: "));
  Serial.println(server.client().remoteIP().toString());
  server.send(200, F("text/html"), createDevicesPage());
}

void handle_intermediate() {
  server.sendHeader("Location", String("http://") + server.client().localIP().toString() + "/devices/", true);
  server.send(301);
}

void handle_single_lamp() {
  String page = "<!DOCTYPE html><html><head><title>VigilOffice</title></head><body>";
  String mac = server.pathArg(0);
  //TODO: RETRIEVE INFORMATION FROM INFLUX?
  //TODO: DISPLAY DEVICE INFO
  //TODO: DISPLAY CONFIGURATION EDITING FORM
  page += "<form method=\"post\" enctype=\"application/x-www-form-urlencoded\" action=\"/control\">\
      <label for=\"flame\">Flame status:</label>\
      <input type=\"number\" name=\"flameStatus\" value=\"0\" min=\"0\" max=\"1\"><br>\
      <label for=\"flame\">Flame sensor enabled:</label>\
      <input type=\"number\" name=\"flameEnabled\" value=\"0\" min=\"0\" max=\"1\"><br>\
      <button class=\"button\" type=\"submit\">Send new configuration</button>\
    </form>";
  page += "</body></html>";
}

/*void handle_single_conditioning() {
  String page = "<!DOCTYPE html><html><head><title>VigilOffice</title></head><body>";
  String mac = server.pathArg(0);
  //RETRIEVE INFORMATION FROM INFLUX?
  //DISPLAY DEVICE INFO
  //DISPLAY CONFIGURATION EDITING FORM
  page += "<form method=\"post\" enctype=\"application/x-www-form-urlencoded\" action=\"/control\">\
  <input type=\"hidden\" value="
          + "\
      <label for=\"flame\">Flame status:</label>\
      <input type=\"number\" name=\"flameStatus\" value=\"0\" min=\"0\" max=\"1\"><br>\
      <label for=\"flame\">Flame sensor enabled:</label>\
      <input type=\"number\" name=\"flameEnabled\" value=\"0\" min=\"0\" max=\"1\"><br>\
      <button class=\"button\" type=\"submit\">Send new configuration</button>\
    </form>";
  page += "</body></html>";
}*/

void handle_single_lamp_edit() {
  String mac = server.pathArg(0);
  if (server.method() != HTTP_POST) {
    server.send(405, F("text/plain"), F("ERROR 405 - Method Not Allowed"));
  } else if (!server.hasArg(F("mac"))) {
    server.send(400, F("text/plain"), F("ERROR 400 - Bad Request"));
  } else {
    //TODO: SEND NEW CONFIGURATION TO DEVICE
    //server.sendHeader("Location", String("http://") + server.client().localIP().toString() + "/devices/" + device.url + "/" + device.mac, true);
    server.sendHeader("Location", String("http://") + server.client().localIP().toString(), true);
    server.send(301);
  }
}

// === MQTT ===

void connectToMQTTBroker() {
  if (!mqttClient.connected()) {  // not connected
    Serial.print(F("\nConnecting to MQTT broker..."));
    while (!mqttClient.connect(MQTT_CLIENTID, MQTT_USERNAME, MQTT_PASSWORD)) {
      Serial.print(F("."));
      delay(1000);
    }
    Serial.println(F("\nConnected!"));

    JsonDocument doc;
    doc["serverIP"] = ipToString(WiFi.localIP());
    doc["registerTopic"] = MQTT_TOPIC_REGISTER;
    char buffer[128];
    size_t n = serializeJson(doc, buffer);
    mqttClient.publish(MQTT_TOPIC_WELCOME, buffer, n, true, 2);
    Serial.println(buffer);
    mqttClient.subscribe(MQTT_TOPIC_REGISTER);
    Serial.println(F("Subscribed to register topic."));
  }
}

void mqttMessageReceived(String &topic, String &payload) {
  if (topic == MQTT_TOPIC_REGISTER) {
    JsonDocument readDoc;
    deserializeJson(readDoc, payload);
    const char *mac = readDoc["mac-address"];
    const char *type = readDoc["type"];
    Serial.println(mac);
    Serial.println(type);

    JsonDocument writeDoc;
    String prefix = String("vigiloffice/");
    if (strcmp(type, "hvac") == 0) {
      prefix = prefix + MQTT_TOPIC_HVAC + mac;
    } else if (strcmp(type, "lamp") == 0) {
      prefix = prefix + MQTT_TOPIC_LAMPS + mac;
    } else {
      return;
    }
    writeDoc["statusTopic"] = prefix + String("/status");
    writeDoc["controlTopic"] = prefix + String("/control");
    mqttClient.subscribe(prefix + String("/status"));
    char buffer[256];
    size_t n = serializeJson(writeDoc, buffer);

    String registerTopicStr = String(MQTT_TOPIC_REGISTER) + "/" + mac;
    const char *registerTopicMAC = registerTopicStr.c_str();

    mqttClient.publish(registerTopicMAC, buffer, n, false, 1);
  } else if (topic.startsWith("vigiloffice/lamps") && topic.endsWith("/status")) {
    Serial.println(payload);

    JsonDocument doc;
    deserializeJson(doc, payload);

    pointDeviceLamp.clearFields();
    pointDeviceLamp.clearTags();
    pointDeviceLamp.addTag("mac-address", doc["mac-address"]);

    JsonArray sensori = doc["sensors"];
    for (JsonObject sensor : sensori) {
      const char* sensorName = sensor[SENSOR_NAME_JSON_NAME];
      if (strcmp(sensorName, LIGHT_JSON_NAME) == 0) {
        pointDeviceLamp.addField("light-value", (int) sensor[SENSOR_VALUE_JSON_NAME]);
        pointDeviceLamp.addField("light-threshold", (int) sensor[SENSOR_THRESHOLD_JSON_NAME]);
        pointDeviceLamp.addField("light-status", (int) sensor[STATUS_JSON_NAME]);
        pointDeviceLamp.addField("light-enabled", ((int) sensor[SENSOR_STATUS_JSON_NAME]) == 1 ? true : false);
      } else if (strcmp(sensorName, MOTION_JSON_NAME) == 0) {
        pointDeviceLamp.addField("motion-value", (int) sensor[SENSOR_VALUE_JSON_NAME]);
        pointDeviceLamp.addField("motion-status", (int) sensor[STATUS_JSON_NAME]);
        pointDeviceLamp.addField("motion-enabled", ((int) sensor[SENSOR_STATUS_JSON_NAME]) == 1 ? true : false);
      } else if (strcmp(sensorName, FLAME_JSON_NAME) == 0) {
        pointDeviceLamp.addField("flame-value", (int) sensor[SENSOR_VALUE_JSON_NAME]);
        pointDeviceLamp.addField("flame-status", (int) sensor[STATUS_JSON_NAME]);
        pointDeviceLamp.addField("flame-enabled", ((int) sensor[SENSOR_STATUS_JSON_NAME]) == 1 ? true : false);
      } else if (strcmp(sensorName, RGB_JSON_NAME) == 0) {
        pointDeviceLamp.addField("rgb-value", (int) sensor[SENSOR_VALUE_JSON_NAME]);
        pointDeviceLamp.addField("rgb-status", (int) sensor[STATUS_JSON_NAME]);
        pointDeviceLamp.addField("rgb-enabled", ((int) sensor[SENSOR_STATUS_JSON_NAME]) == 1 ? true : false);
      }
    }

    JsonObject allarme = doc["alarm"];
    pointDeviceLamp.addField("alarm-status", ((int) allarme[STATUS_JSON_NAME]) == 1 ? true : false);
    pointDeviceLamp.addField("alarm-enabled", ((int) allarme[SENSOR_STATUS_JSON_NAME]) == 1 ? true : false);

    if (!client_idb.writePoint(pointDeviceLamp)) {
      Serial.print(F("InfluxDB write failed: "));
      Serial.println(client_idb.getLastErrorMessage());
    }
  }
}

void check_influxdb() {
  if (!client_idb.validateConnection()) {
    Serial.print(F("InfluxDB connection failed: "));
    Serial.println(client_idb.getLastErrorMessage());
  }
}

String ipToString(IPAddress ip) {
  String s = "";
  for (int i = 0; i < 4; i++) {
    s += i ? "." + String(ip[i]) : String(ip[i]);
  }
  return s;
}