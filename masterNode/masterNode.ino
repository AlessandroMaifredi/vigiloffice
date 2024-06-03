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
#include <MySQL_Connection.h>
#include <MySQL_Cursor.h>
#include "lampHtml.h"


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

WiFiClient client;
char mysql_user[] = MYSQL_USER;
char mysql_password[] = MYSQL_PASS;
IPAddress server_addr(MYSQL_IP);
MySQL_Connection conn((Client *)&client);
unsigned long latestDBWrite = 0;
char query[1024];
char UPSERT_DATA[] = "INSERT INTO `%s`.`vigiloffice_lamp` ("
                     "`mac-address`, `light-enabled`, `light-status`, "
                     "`light-threshold`, `light-value`, "
                     "`motion-enabled`, `motion-status`, `motion-value`, "
                     "`flame-enabled`, `flame-status`, `flame-value`, "
                     "`rgb-enabled`, `rgb-status`, `rgb-value`, "
                     "`alarm-enabled`, `alarm-status`) "
                     "VALUES ('%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d) "
                     "ON DUPLICATE KEY UPDATE "
                     "`light-enabled` = VALUES(`light-enabled`), "
                     "`light-status` = VALUES(`light-status`), "
                     "`light-threshold` = VALUES(`light-threshold`), "
                     "`light-value` = VALUES(`light-value`), "
                     "`motion-enabled` = VALUES(`motion-enabled`), "
                     "`motion-status` = VALUES(`motion-status`), "
                     "`motion-value` = VALUES(`motion-value`), "
                     "`flame-enabled` = VALUES(`flame-enabled`), "
                     "`flame-status` = VALUES(`flame-status`), "
                     "`flame-value` = VALUES(`flame-value`), "
                     "`rgb-enabled` = VALUES(`rgb-enabled`), "
                     "`rgb-status` = VALUES(`rgb-status`), "
                     "`rgb-value` = VALUES(`rgb-value`), "
                     "`alarm-enabled` = VALUES(`alarm-enabled`), "
                     "`alarm-status` = VALUES(`alarm-status`)";


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
  //wifiManager.resetSettings();
  wifiManager.autoConnect("AP Vigiloffice Master - **MAC**");

  server.on("/", handle_root);
  server.on("/devices/", handle_devices);

  server.on("/devices/lamps/", handle_intermediate);
  //server.on("/devices/conditioning/", handle_intermediate);

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

JsonDocument knownDevicesDoc;

const String root_html = "<!DOCTYPE html>\
  <html>\
  <head>\
    <title>VigilOffice</title>\
  </head>\
  <body>\
    <a href='/devices/'>Manage devices</a>\
    <a href='/alarm/'>Manage alarm</a>\
  </body>\
</html>";

String createDevicesPage() {
  String page = "<!DOCTYPE html><html><head><title>VigilOffice</title></head><body><table><th><td>#</td><td>Device type</td><td>Device MAC</td><td>Device status</td></th>";
  int i = 0;
  JsonArray macArray = knownDevicesDoc["macs"].as<JsonArray>();
  Serial.println("DEVICES PAGE HAS " + String(macArray.size()) + " DEVICES");
  for (JsonVariant deviceMacVariant : macArray) {
    String deviceMac = deviceMacVariant.as<String>();
    JsonObject device = knownDevicesDoc[deviceMac].as<JsonObject>();
    ++i;
    page += "<tr onclick=\"location.href = '/devices/" + String(device["url"]) + "/" + deviceMac + "';\">";
    page += "<td>" + String(i) + "</td>";
    page += "<td>" + String(device["type"]) + "</td>";
    page += "<td>" + String(device["mac"]) + "</td>";
    page += "<td>" + String(device["status"]) + "</td>";
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

JsonDocument getLastDeviceStatusDoc() {
  //TODO: QUERY MYSQL FOR LAST STATUS OF DEVICE
  JsonDocument statusDoc;
  statusDoc["mac-address"] = "BC:DD:C2:B6:6F:9B";
  statusDoc["type"] = "lamp";
  JsonArray sensors = statusDoc.createNestedArray("sensors");
  JsonObject lightSensor = sensors.createNestedObject();
  lightSensor[SENSOR_NAME_JSON_NAME] = LIGHT_JSON_NAME;
  lightSensor[SENSOR_VALUE_JSON_NAME] = 126;
  lightSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = 350;
  lightSensor[STATUS_JSON_NAME] = 0;
  lightSensor[SENSOR_STATUS_JSON_NAME] = true;
  lightSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 3000;


  JsonObject motionSensor = sensors.createNestedObject();
  motionSensor[SENSOR_NAME_JSON_NAME] = MOTION_JSON_NAME;
  motionSensor[SENSOR_VALUE_JSON_NAME] = 0;
  motionSensor[STATUS_JSON_NAME] = 0;
  motionSensor[SENSOR_STATUS_JSON_NAME] = false;

  JsonObject flameSensor = sensors.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[SENSOR_VALUE_JSON_NAME] = 0;
  flameSensor[STATUS_JSON_NAME] = 0;
  flameSensor[SENSOR_STATUS_JSON_NAME] = true;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 1000;

  JsonObject RGBLed = sensors.createNestedObject();
  RGBLed[SENSOR_NAME_JSON_NAME] = RGB_JSON_NAME;
  RGBLed[SENSOR_VALUE_JSON_NAME] = 0;
  RGBLed[STATUS_JSON_NAME] = 0;
  RGBLed[SENSOR_STATUS_JSON_NAME] = true;

  JsonObject alarm = statusDoc.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = false;
  alarm[SENSOR_STATUS_JSON_NAME] = true;
  return statusDoc;
}

void handle_single_lamp() {
  String mac = server.pathArg(0);
  if (server.method() == HTTP_GET) {
    JsonDocument lastStatusFile = getLastDeviceStatusDoc();
    server.send(200, F("text/html"), createSingleLampEditPage(lastStatusFile));
  } else {
    if (server.method() != HTTP_POST) {
      server.send(405, F("text/plain"), F("ERROR 405 - Method not allowed"));
    } else {
      if (!server.hasArg(F("mac"))) {
        server.send(400, F("text/plain"), F("ERROR 400 - Bad Request"));
      } else {
        String controlTopic = "vigiloffice/lamps/" + server.pathArg(0) + "/control";
        Serial.print(F("Sendig new configuration to: "));
        Serial.println(controlTopic);
        char buffer[512];
        JsonDocument configFile = createLampConfigFile();
        size_t n = serializeJson(configFile, buffer);
        mqttClient.publish(controlTopic.c_str(), buffer, n, false, 1);
        server.send(200, F("text/html"), createSingleLampEditPage(configFile));
      }
    }
  }
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


JsonDocument createLampConfigFile() {
  JsonDocument newConfig;
  newConfig[F("mac-address")] = server.pathArg(0);
  JsonArray sensori = newConfig.createNestedArray(F("sensors"));
  JsonObject lightSensor = sensori.createNestedObject();
  lightSensor[SENSOR_NAME_JSON_NAME] = LIGHT_JSON_NAME;
  lightSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = server.arg(F("lightSliderInput")).toInt();
  lightSensor[STATUS_JSON_NAME] = server.arg(F("lightDropdown")).toInt();
  lightSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("lightStatus")) == "true" ? true : false;
  lightSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("lightIntervalSliderInput")).toInt();
  JsonObject motionSensor = sensori.createNestedObject();
  motionSensor[SENSOR_NAME_JSON_NAME] = MOTION_JSON_NAME;
  motionSensor[STATUS_JSON_NAME] = server.arg(F("motionDropdown")).toInt();
  motionSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("motionStatus")) == "true" ? true : false;

  JsonObject flameSensor = sensori.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[STATUS_JSON_NAME] = server.arg(F("flameDropdown")).toInt();
  flameSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("flameStatus")) == "true" ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("flameIntervalSliderInput")).toInt();

  JsonObject RGBLed = sensori.createNestedObject();
  RGBLed[SENSOR_NAME_JSON_NAME] = RGB_JSON_NAME;
  RGBLed[STATUS_JSON_NAME] = server.arg(F("rgbDropdown")).toInt();
  RGBLed[SENSOR_STATUS_JSON_NAME] = server.arg(F("rgbStatus")) == "true" ? true : false;

  JsonObject alarm = newConfig.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = server.arg(F("alarmDropdown")) == "true" ? true : false;
  alarm[SENSOR_STATUS_JSON_NAME] = server.arg(F("alarmStatus")) == "true" ? true : false;

  return newConfig;
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
    doc[F("serverIP")] = ipToString(WiFi.localIP());
    doc[F("registerTopic")] = MQTT_TOPIC_REGISTER;
    char buffer[128];
    size_t n = serializeJson(doc, buffer);
    mqttClient.publish(MQTT_TOPIC_WELCOME, buffer, n, true, 2);
    Serial.println(buffer);
    mqttClient.subscribe(MQTT_TOPIC_REGISTER);
    Serial.println(F("Subscribed to register topic."));
  }
}


void registerDevice(String &payload) {
  JsonDocument readDoc;
  deserializeJson(readDoc, payload);
  String mac = readDoc[F("mac-address")];
  String type = readDoc[F("type")];
  Serial.println(mac);
  Serial.println(type);

  if (!knownDevicesDoc.containsKey(mac)) {
    knownDevicesDoc[mac] = knownDevicesDoc.createNestedObject();
    knownDevicesDoc[F("macs")].add(mac);
  }

  JsonObject newDevice = knownDevicesDoc[mac];

  JsonDocument writeDoc;
  String prefix = String("vigiloffice/");
  if (type.equals(F("hvac"))) {
    prefix = prefix + MQTT_TOPIC_HVAC + mac;
    newDevice[F("url")] = "hvac";
  } else if (type.equals("lamp")) {
    prefix = prefix + MQTT_TOPIC_LAMPS + mac;
    newDevice[F("url")] = "lamps";
  } else {
    return;
  }
  newDevice[F("type")] = type;
  newDevice[F("status")] = "connected";

  writeDoc[F("statusTopic")] = prefix + String(F("/status"));
  writeDoc[F("controlTopic")] = prefix + String(F("/control"));
  writeDoc[F("lwtTopic")] = prefix + String(F("/lwt"));
  mqttClient.subscribe(prefix + String(F("/status")));
  char buffer[256];
  size_t n = serializeJson(writeDoc, buffer);

  String registerTopicStr = String(MQTT_TOPIC_REGISTER) + "/" + mac;

  mqttClient.publish(registerTopicStr.c_str(), buffer, n, false, 1);
  knownDevicesDoc[mac] = newDevice;
  knownDevicesDoc.shrinkToFit();
  Serial.println(F("Device registered: ") + mac);
}


void handleLampStatusMessage(String &payload) {
  Serial.println(payload);

  JsonDocument doc;
  deserializeJson(doc, payload);

    pointDeviceLamp.clearFields();
    pointDeviceLamp.clearTags();

    String mac_address = doc[F("mac-address")];
    Serial.println(F("Il mac address e': ") + mac_address);
    int light_value = 0;
    int light_threshold = 0;
    int light_status = 0;
    bool light_enabled = 0;
    int motion_value = 0;
    int motion_status = 0;
    bool motion_enabled =0;
    int flame_value = 0;
    int flame_status = 0;
    bool flame_enabled = 0;
    int rgb_value = 0;
    int rgb_status = 0;
    bool rgb_enabled = 0;
    bool alarm_status = 0;
    bool alarm_enabled = 0;

    pointDeviceLamp.addTag(F("mac-address"), mac_address);

    JsonArray sensori = doc[F("sensors")];
    for (JsonObject sensor : sensori) {
      const char *sensorName = sensor[SENSOR_NAME_JSON_NAME];
      if (strcmp(sensorName, LIGHT_JSON_NAME) == 0) {
        light_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
        light_threshold = (int)sensor[SENSOR_LOW_THRESHOLD_JSON_NAME];
        light_status = (int)sensor[STATUS_JSON_NAME];
        light_enabled = (int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false;
        pointDeviceLamp.addField(F("light-value"), light_value);
        pointDeviceLamp.addField(F("light-threshold"), light_threshold);
        pointDeviceLamp.addField(F("light-status"), light_status);
        pointDeviceLamp.addField(F("light-enabled"), light_enabled);
      } else if (strcmp(sensorName, MOTION_JSON_NAME) == 0) {
        motion_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
        motion_status = (int)sensor[STATUS_JSON_NAME];
        motion_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
        pointDeviceLamp.addField(F("motion-value"), motion_value);
        pointDeviceLamp.addField(F("motion-status"), motion_status);
        pointDeviceLamp.addField(F("motion-enabled"), motion_enabled);
      } else if (strcmp(sensorName, FLAME_JSON_NAME) == 0) {
        flame_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
        flame_status = (int)sensor[STATUS_JSON_NAME];
        flame_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
        pointDeviceLamp.addField(F("flame-value"), flame_value);
        pointDeviceLamp.addField(F("flame-status"), flame_status);
        pointDeviceLamp.addField(F("flame-enabled"), flame_enabled);
      } else if (strcmp(sensorName, RGB_JSON_NAME) == 0) {
        rgb_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
        rgb_status = (int)sensor[STATUS_JSON_NAME];
        rgb_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
        pointDeviceLamp.addField(F("rgb-value"), rgb_value);
        pointDeviceLamp.addField(F("rgb-status"), rgb_status);
        pointDeviceLamp.addField(F("rgb-enabled"), rgb_enabled);
      }
    }

    JsonObject allarme = doc[F("alarm")];
    alarm_status = ((int)allarme[STATUS_JSON_NAME] == 1 ? true : false);
    alarm_enabled = ((int)allarme[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
    pointDeviceLamp.addField(F("alarm-status"), alarm_status);
    pointDeviceLamp.addField(F("alarm-enabled"), alarm_enabled);

  if (!client_idb.writePoint(pointDeviceLamp)) {
    Serial.print(F("InfluxDB write failed: "));
    Serial.println(client_idb.getLastErrorMessage());
  }

    if (!conn.connected()) {
      conn.close();
      Serial.println(F("Connecting to MySQL..."));
      if (conn.connect(server_addr, 3306, mysql_user, mysql_password)) {
        Serial.println(F("MySQL connection established."));
      } else {
        Serial.println(F("MySQL connection failed."));
        return;
      }
    }

    MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
    sprintf(query, UPSERT_DATA, mysql_user, mac_address.c_str(), light_status, light_enabled, light_threshold, light_value, 
            motion_enabled, motion_status, motion_value, flame_enabled, flame_status, flame_value, rgb_enabled, 
            rgb_status, rgb_value, alarm_enabled, alarm_status, mac_address.c_str());
    Serial.println(query);
    cur_mem->execute(query);
    delete cur_mem;
    latestDBWrite = millis();
    Serial.println(F("Data recorded on MySQL"));
    knownDevicesDoc[mac_address][F("status")] = "connected";
}

void handleLastWillTestamentMessage(String &payload){
  JsonDocument doc;
  deserializeJson(doc, payload);
  String mac = doc["mac-address"];
  knownDevicesDoc[mac][F("status")] = "disconnected";
  Serial.println(F("Device of type ") + String(doc[F("type")]) + F(" with mac ") + mac + F(" disconnected!"));
}

void mqttMessageReceived(String &topic, String &payload) {
  if (topic == MQTT_TOPIC_REGISTER) {
    registerDevice(payload);
  } else if (topic.startsWith(F("vigiloffice/lamps")) && topic.endsWith(F("/status"))) {
    handleLampStatusMessage(payload);
  } else if(topic.startsWith(F("vigiloffice")) && topic.endsWith(F("/lwt"))){
    handleLastWillTestamentMessage(payload);
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