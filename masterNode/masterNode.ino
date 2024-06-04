
/*
 *** MASTER NODE ***

 By Qazim Toska 847361 & Alessandro Maifredi 851610

 Currently, the master node is configured to manage ONLY the lampNode. 
 The code that manages the hvacNode is commented out and marked with ***REMOVE TO HANDLE HVAC***.
 You can search this phrase to be sure to uncomment the right code.

 In case of memory errors caused by MYSQL and webserver, the method `getLastLampDeviceStatusDoc` can 
 communicate the status of the node using a hardcoded JSON. Follow the instructions given in the commented code to
 switch operation mode. 
 !! The same method for hvac does not have the same capability !!

 To optimize memory usage, logging features are disabled unless the `ENABLE_LOGS` variable is defined at the top of the code.
 See line 38.

*/

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
#include "hvacHtml.h"

//REMOVE COMMENT TO ENABLE LOGGING
// #define ENABLE_LOGS true

#ifdef ENABLE_LOGS

enum LOG_LEVEL {
  LOG_COMM,
  LOG_DB,
  LOG_WEB,
  LOG_ALL,
  LOG_OFF,
};

LOG_LEVEL logLevel = LOG_ALL;

#endif

#define MQTT_BUFFER_SIZE 2048             // the maximum size for packets being published and received
MQTTClient mqttClient(MQTT_BUFFER_SIZE);  // handles the MQTT communication protocol
WiFiClient networkClient;                 // handles the network connection to the MQTT broker
#define MQTT_TOPIC_WELCOME "vigiloffice/welcome"
#define MQTT_TOPIC_REGISTER "vigiloffice/register"
#define MQTT_TOPIC_LWT "vigiloffice/lwt/"
#define MQTT_TOPIC_HVAC "hvacs/"
#define MQTT_TOPIC_LAMPS "lamps/"

WiFiClient client;
char mysql_user[] = MYSQL_USER;
char mysql_password[] = MYSQL_PASS;
IPAddress server_addr(MYSQL_IP);
MySQL_Connection conn((Client *)&client);
unsigned long latestDBWrite = 0;
char query[1024];

InfluxDBClient client_idb(INFLUXDB_URL, INFLUXDB_ORG, INFLUXDB_BUCKET, INFLUXDB_TOKEN);
Point pointDeviceLamp("Lamps");
Point pointDeviceHVAC("HVACs");
boolean alarmStatus = false;

// Set web server port number to 80
ESP8266WebServer server(80);

JsonDocument knownDevicesDoc;


void setup() {
#ifdef ENABLE_LOGS
  Serial.begin(115200);
#endif

  mqttClient.begin(MQTT_BROKERIP, 1883, networkClient);  // setup communication with MQTT broker
  mqttClient.onMessage(mqttMessageReceived);             // callback on message received from MQTT broker

  WiFiManager wifiManager;
  //wifiManager.resetSettings();
  wifiManager.autoConnect("AP Vigiloffice Master");

  server.on("/", handle_root);
  server.on("/devices", handle_devices);
  server.on("/devices/", handle_devices);
  server.on("/devices/lamps/", handle_intermediate);
  server.on("/devices/hvacs/", handle_intermediate);

  server.on(UriBraces("/devices/lamps/{}"), handle_single_lamp);
  //server.on(UriBraces("/devices/hvacs/{}"), handle_single_hvac);

  server.onNotFound(handle_NotFound);
  server.begin();
  knownDevicesDoc[F("macs")].clear();
}

void loop() {
  server.handleClient();
  connectToMQTTBroker();
  mqttClient.loop();
  check_influxdb();
}

// === WEBSERVER ===

const String root_html = "<!DOCTYPE html>\
  <html>\
  <head>\
    <title>VigilOffice</title>\
  </head>\
  <body>\
    <a href='/devices/'>Manage devices</a>\
  </body>\
</html>";

String createDevicesPage() {
  String page = "<!DOCTYPE html><html><head><link href='https://cdn.jsdelivr.net/npm/bootstrap@5.1.3/dist/css/bootstrap.min.css' rel='stylesheet' integrity='sha384-1BmE4kWBq78iYhFldvKuhfTAU6auU8tT94WrHftjDbrCEXSU1oBoqyl2QvZ6jIW3' crossorigin='anonymous'>"
                "<title>VigilOffice</title></head><body><table class='table table-striped table-hover'><tr><th scope='col'>#</th><th scope='col'>Device type</th><th scope='col'>Device MAC</th><th scope='col'>Device status</th></tr>";
  int i = 0;
  JsonArray macArray = knownDevicesDoc[F("macs")].as<JsonArray>();
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_WEB) {
    Serial.println("DEVICES PAGE HAS " + String(macArray.size()) + " DEVICES");
  }
#endif
  for (JsonVariant deviceMacVariant : macArray) {
    String deviceMac = deviceMacVariant.as<String>();
    JsonObject device = knownDevicesDoc[deviceMac].as<JsonObject>();
    ++i;
    page += "<tr style=\"cursor: pointer;\" onclick=\"location.href = '/devices/" + String(device["url"]) + "/" + deviceMac + "';\">";
    page += "<th scope='row'>" + String(i) + "</th>";
    page += "<td>" + String(device["type"]) + "</td>";
    page += "<td>" + String(device["mac"]) + "</td>";
    page += "<td>" + String(device["status"]) + "</td>";
    page += "</tr>";
  }
  page += "</table></body></html>";
  return page;
}

void handle_root() {
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_WEB) {
    Serial.print(F("New Client with IP: "));
    Serial.println(server.client().remoteIP().toString());
  }
#endif
  server.send(200, F("text/html"), root_html);
}

void handle_NotFound() {
  server.send(404, F("text/plain"), F("ERROR 404 - Not found"));
}

void handle_devices() {
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_WEB) {
    Serial.print(F("New Client with IP: "));
    Serial.println(server.client().remoteIP().toString());
  }
#endif
  server.send(200, F("text/html"), createDevicesPage());
}

void handle_intermediate() {
  server.sendHeader("Location", String("http://") + server.client().localIP().toString() + "/devices/", true);
  server.send(301);
}

JsonDocument getLastLampDeviceStatusDoc(String &mac) {
  /***  REMOVE COMMENT TO ENABLE MYSQL CONNECTION AND GET REAL LAST STATUS ***/
  /***  BE SURE TO COMMENT THE FAKE CODE PART TO DISABLE THE FAKE STATUS PART ***/

  // *** REAL STATUS START ***
  /*
  char GET_DATA_LAMP[] = "SELECT * FROM `%s`.`vigiloffice_lamp` WHERE `mac-address` = '%s'";

  sprintf(query, GET_DATA_LAMP, mysql_user, mac.c_str());

  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  // Execute the query
  cur_mem->execute(query);
  // Fetch the columns (required) but we don't use them.
  column_names *columns = cur_mem->get_columns();
  row_values *row = NULL;
  row = cur_mem->get_next_row();
  JsonDocument statusDoc;
  if (row == NULL) {
#ifdef ENABLE_LOGS
    if (logLevel == LOG_DB || logLevel == LOG_ALL) {
      Serial.println(F("NO RESULTS IN GET LAST STATUS QUERY!"));
    }
#endif
  } else {
#ifdef ENABLE_LOGS
    if (logLevel == LOG_DB || logLevel == LOG_ALL) {
      Serial.print(F("LAST STATUS RECIEVED FROM DB! #: "));
      Serial.println(columns->num_fields);
    }
#endif
    statusDoc["mac-address"] = mac;
    statusDoc["type"] = "lamp";
    statusDoc[F("status")] = knownDevicesDoc[mac][F("status")];
    JsonArray sensors = statusDoc.createNestedArray("sensors");
    JsonObject lightSensor = sensors.createNestedObject();
    lightSensor[SENSOR_NAME_JSON_NAME] = LIGHT_JSON_NAME;
    lightSensor[SENSOR_VALUE_JSON_NAME] = row->values[4];
    lightSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = row->values[3];
    lightSensor[STATUS_JSON_NAME] = row->values[2];
    lightSensor[SENSOR_STATUS_JSON_NAME] = row->values[1];
    lightSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 3000;  //TODO ADD


    JsonObject motionSensor = sensors.createNestedObject();
    motionSensor[SENSOR_NAME_JSON_NAME] = MOTION_JSON_NAME;
    motionSensor[SENSOR_VALUE_JSON_NAME] = row->values[7];
    motionSensor[STATUS_JSON_NAME] = row->values[6];
    motionSensor[SENSOR_STATUS_JSON_NAME] = row->values[5];

    JsonObject flameSensor = sensors.createNestedObject();
    flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
    flameSensor[SENSOR_VALUE_JSON_NAME] = row->values[10];
    flameSensor[STATUS_JSON_NAME] = row->values[9];
    flameSensor[SENSOR_STATUS_JSON_NAME] = row->values[8];
    flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 1000;  //TODO ADD

    JsonObject RGBLed = sensors.createNestedObject();
    RGBLed[SENSOR_NAME_JSON_NAME] = RGB_JSON_NAME;
    RGBLed[SENSOR_VALUE_JSON_NAME] = row->values[13];
    RGBLed[STATUS_JSON_NAME] = row->values[12];
    RGBLed[SENSOR_STATUS_JSON_NAME] = row->values[11];

    JsonObject alarm = statusDoc.createNestedObject(ALARM_JSON_NAME);
    alarm[STATUS_JSON_NAME] = row->values[15];
    alarm[SENSOR_STATUS_JSON_NAME] = row->values[14];
  }
  delete cur_mem;
  return statusDoc;
  */
  // *** REAL STATUS END ***

  // *** THE FOLLOWING CODE SIMULATES THE LAST STATUS OF THE DEVICE ***
  // *** COMMENT THE FOLLOWING CODE IF YOU WANT TO USE REAL MYSQL CONNECTION ***
  // *** FAKE STATUS START ***
  JsonDocument statusDoc;
  statusDoc["mac-address"] = mac;
  statusDoc["type"] = "lamp";
  statusDoc["status"] = knownDevicesDoc[mac][F("status")];
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
  // *** FAKE STATUS END ***
}

void handle_single_lamp() {
  String mac = server.pathArg(0);
  if (server.method() == HTTP_GET) {
    JsonDocument lastStatusFile = getLastLampDeviceStatusDoc(mac);
    server.send(200, F("text/html"), createSingleLampEditPage(lastStatusFile));
  } else {
    if (server.method() != HTTP_POST) {
      server.send(405, F("text/plain"), F("ERROR 405 - Method not allowed"));
    } else {
      if (!server.hasArg(F("mac"))) {
        server.send(400, F("text/plain"), F("ERROR 400 - Bad Request"));
      } else {
        String controlTopic = "vigiloffice/lamps/" + server.pathArg(0) + "/control";
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
          Serial.print(F("Sendig new configuration to: "));
          Serial.println(controlTopic);
        }
#endif
        char buffer[512];
        JsonDocument configFile = createLampConfigFile();
        size_t n = serializeJson(configFile, buffer);
        mqttClient.publish(controlTopic.c_str(), buffer, n, false, 1);
        server.send(200, F("text/html"), createSingleLampEditPage(configFile));
      }
    }
  }
}

JsonDocument createLampConfigFile() {
  JsonDocument newConfig;
  newConfig[F("mac-address")] = server.pathArg(0);
  JsonArray sensors = newConfig.createNestedArray(F("sensors"));
  JsonObject lightSensor = sensors.createNestedObject();
  lightSensor[SENSOR_NAME_JSON_NAME] = LIGHT_JSON_NAME;
  lightSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = server.arg(F("lightSliderInput")).toInt();
  lightSensor[STATUS_JSON_NAME] = server.arg(F("lightDropdown")).toInt();
  lightSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("lightStatus")) == "true" ? true : false;
  lightSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("lightIntervalSliderInput")).toInt();
  JsonObject motionSensor = sensors.createNestedObject();
  motionSensor[SENSOR_NAME_JSON_NAME] = MOTION_JSON_NAME;
  motionSensor[STATUS_JSON_NAME] = server.arg(F("motionDropdown")).toInt();
  motionSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("motionStatus")) == "true" ? true : false;

  JsonObject flameSensor = sensors.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[STATUS_JSON_NAME] = server.arg(F("flameDropdown")).toInt();
  flameSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("flameStatus")) == "true" ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("flameIntervalSliderInput")).toInt();

  JsonObject RGBLed = sensors.createNestedObject();
  RGBLed[SENSOR_NAME_JSON_NAME] = RGB_JSON_NAME;
  RGBLed[STATUS_JSON_NAME] = server.arg(F("rgbDropdown")).toInt();
  RGBLed[SENSOR_STATUS_JSON_NAME] = server.arg(F("rgbStatus")) == "true" ? true : false;

  JsonObject alarm = newConfig.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = server.arg(F("alarmDropdown")) == "true" ? true : false;
  alarm[SENSOR_STATUS_JSON_NAME] = server.arg(F("alarmStatus")) == "true" ? true : false;

  return newConfig;
}


// === HANDLE HVAC ===
/* ***REMOVE TO HANDLE HVAC***



JsonDocument getLastHvacDeviceStatusDoc(String mac) {
  JsonDocument statusDoc;
  statusDoc[F("mac-address")] = mac;
  statusDoc[F("type")] = "hvac";
  statusDoc[F("status")] = knownDevicesDoc[mac];
  JsonArray sensors = statusDoc.createNestedArray(F("sensors"));

  JsonObject tempSensor = sensors.createNestedObject();
  tempSensor[SENSOR_NAME_JSON_NAME] = TEMP_JSON_NAME;
  tempSensor[SENSOR_VALUE_JSON_NAME] = 22;
  tempSensor[STATUS_JSON_NAME] = 0;
  tempSensor[SENSOR_STATUS_JSON_NAME] = true;
  tempSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 60000;
  tempSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME] = 24;
  tempSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = 18;
  tempSensor[SENSOR_TEMP_TARGET_JSON_NAME] = 21;

  JsonObject hvacSensor = sensors.createNestedObject();
  hvacSensor[SENSOR_NAME_JSON_NAME] = HVAC_JSON_NAME;
  hvacSensor[SENSOR_STATUS_JSON_NAME] = true;

  JsonObject flameSensor = sensors.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[SENSOR_VALUE_JSON_NAME] = 0;
  flameSensor[STATUS_JSON_NAME] = 0;
  flameSensor[SENSOR_STATUS_JSON_NAME] = true;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = 1000;

  JsonObject alarm = statusDoc.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = false;
  alarm[SENSOR_STATUS_JSON_NAME] = true;

  return statusDoc;
}

void handle_single_hvac() {
  String mac = server.pathArg(0);
  if (server.method() == HTTP_GET) {
    JsonDocument lastStatusFile = getLastHvacDeviceStatusDoc(mac);
    server.send(200, F("text/html"), createSingleHvacEditPage(lastStatusFile));
  } else {
    if (server.method() != HTTP_POST) {
      server.send(405, F("text/plain"), F("ERROR 405 - Method not allowed"));
    } else {
      if (!server.hasArg(F("mac"))) {
        server.send(400, F("text/plain"), F("ERROR 400 - Bad Request"));
      } else {
        String controlTopic = "vigiloffice/hvacs/" + server.pathArg(0) + "/control";
#ifdef ENABLE_LOGS
        if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
          Serial.print(F("Sendig new configuration to: "));
          Serial.println(controlTopic);
        }
#endif
        char buffer[512];
        JsonDocument configFile = createHvacConfigFile();
        size_t n = serializeJson(configFile, buffer);
        mqttClient.publish(controlTopic.c_str(), buffer, n, false, 1);
        server.send(200, F("text/html"), createSingleHvacEditPage(configFile));
      }
    }
  }
}

JsonDocument createHvacConfigFile() {
  JsonDocument newConfig;
  newConfig[F("mac-address")] = server.pathArg(0);
  JsonArray sensors = newConfig.createNestedArray(F("sensors"));

  JsonObject tempSensor = sensors.createNestedObject();
  tempSensor[SENSOR_NAME_JSON_NAME] = TEMP_JSON_NAME;
  tempSensor[STATUS_JSON_NAME] = server.arg(F("tempDropdown")).toInt();
  tempSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("tempStatus")) == "true" ? true : false;
  tempSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("tempIntervalSliderInput")).toInt();
  tempSensor[SENSOR_HIGH_THRESHOLD_JSON_NAME] = server.arg(F("highTempSliderInput")).toInt();
  tempSensor[SENSOR_LOW_THRESHOLD_JSON_NAME] = server.arg(F("lowTempSliderInput")).toInt();
  tempSensor[SENSOR_TEMP_TARGET_JSON_NAME] = server.arg(F("targetTempSliderInput")).toInt();

  JsonObject hvacSensor = sensors.createNestedObject();
  hvacSensor[SENSOR_NAME_JSON_NAME] = HVAC_JSON_NAME;
  hvacSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("hvacStatus")) == "true" ? true : false;

  JsonObject flameSensor = sensors.createNestedObject();
  flameSensor[SENSOR_NAME_JSON_NAME] = FLAME_JSON_NAME;
  flameSensor[STATUS_JSON_NAME] = server.arg(F("flameDropdown")).toInt();
  flameSensor[SENSOR_STATUS_JSON_NAME] = server.arg(F("flameStatus")) == "true" ? true : false;
  flameSensor[SENSOR_READING_INTERVAL_JSON_NAME] = server.arg(F("flameIntervalSliderInput")).toInt();

  JsonObject alarm = newConfig.createNestedObject(ALARM_JSON_NAME);
  alarm[STATUS_JSON_NAME] = server.arg(F("alarmDropdown")) == "true" ? true : false;
  alarm[SENSOR_STATUS_JSON_NAME] = server.arg(F("alarmStatus")) == "true" ? true : false;

  return newConfig;
}
***REMOVE TO HANDLE HVAC***  */

// === MQTT ===

void connectToMQTTBroker() {
  if (!mqttClient.connected()) {  // not connected
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.print(F("\nConnecting to MQTT broker..."));
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
    JsonDocument doc;
    doc[F("serverIP")] = ipToString(WiFi.localIP());
    doc[F("registerTopic")] = MQTT_TOPIC_REGISTER;
    char buffer[128];
    size_t n = serializeJson(doc, buffer);
    mqttClient.publish(MQTT_TOPIC_WELCOME, buffer, n, true, 2);
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.println(buffer);
    }
#endif
    mqttClient.subscribe(MQTT_TOPIC_REGISTER);
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
      Serial.println(F("Subscribed to register topic."));
    }
#endif
  }
}


void registerDevice(String &payload) {
  JsonDocument readDoc;
  deserializeJson(readDoc, payload);
  String mac = readDoc[F("mac-address")];
  String type = readDoc[F("type")];
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.println(mac);
    Serial.println(type);
  }
#endif
  JsonDocument writeDoc;
  String prefix = String(F("vigiloffice/"));
  String url = "";
  if (type.equals(F("hvac"))) {
    prefix = prefix + MQTT_TOPIC_HVAC + mac;
    url = "hvacs";
  } else if (type.equals("lamp")) {
    prefix = prefix + MQTT_TOPIC_LAMPS + mac;
    url = "lamps";
  } else {
    return;
  }


  writeDoc[F("statusTopic")] = prefix + String(F("/status"));
  writeDoc[F("controlTopic")] = prefix + String(F("/control"));
  writeDoc[F("lwtTopic")] = MQTT_TOPIC_LWT + mac;
  mqttClient.subscribe(MQTT_TOPIC_LWT + mac);
  mqttClient.subscribe(prefix + String(F("/status")));
  char buffer[256];
  size_t n = serializeJson(writeDoc, buffer);

  String registerTopicStr = String(MQTT_TOPIC_REGISTER) + "/" + mac;

  mqttClient.publish(registerTopicStr.c_str(), buffer, n, false, 1);
  int j = 0;
  for (JsonVariant v : knownDevicesDoc[F("macs")].as<JsonArray>()) {
    if (v.as<String>() == mac) {
      knownDevicesDoc[F("macs")].remove(j);
      break;
    }
    j++;
  }
  knownDevicesDoc[F("macs")].add(mac);
  knownDevicesDoc[mac][F("url")] = url;
  knownDevicesDoc[mac][F("mac")] = mac;
  knownDevicesDoc[mac][F("type")] = type;
  knownDevicesDoc[mac][F("status")] = "connected";
  knownDevicesDoc.shrinkToFit();
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.println(F("Device registered: ") + String(knownDevicesDoc[mac]));
  }
#endif
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
  bool motion_enabled = 0;
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
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_DB) {
      Serial.print(F("InfluxDB write failed: "));
      Serial.println(client_idb.getLastErrorMessage());
    }
#endif
  }

  if (!conn.connected()) {
    conn.close();
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_DB) {
      Serial.println(F("Connecting to MySQL..."));
    }
#endif
    if (conn.connect(server_addr, 3306, mysql_user, mysql_password)) {
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_DB) {
        Serial.println(F("MySQL connection established."));
      }
#endif
    } else {
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_DB) {
        Serial.println(F("MySQL connection failed."));
      }
#endif
      return;
    }
  }
  char UPSERT_DATA_LAMP[] = "INSERT INTO `%s`.`vigiloffice_lamp` ("
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

  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  sprintf(query, UPSERT_DATA_LAMP, mysql_user, mac_address.c_str(), light_status, light_enabled, light_threshold, light_value,
          motion_enabled, motion_status, motion_value, flame_enabled, flame_status, flame_value, rgb_enabled,
          rgb_status, rgb_value, alarm_enabled, alarm_status, mac_address.c_str());
  //Serial.println(query);
  cur_mem->execute(query);
  delete cur_mem;
  latestDBWrite = millis();
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_DB) {
    Serial.println(F("Data recorded on MySQL"));
  }
#endif
  knownDevicesDoc[mac_address][F("status")] = "connected";
}

/* ***REMOVE TO HANDLE HVAC***
void handleHvacStatusMessage(String &payload) {
  //Serial.println(payload);

  JsonDocument doc;
  deserializeJson(doc, payload);

  pointDeviceHVAC.clearFields();
  pointDeviceHVAC.clearTags();

  String mac_address = doc[F("mac-address")];
  //Serial.println(F("Il mac address e': ") + mac_address);
  int temp_value = 0;
  int low_temp_threshold = 0;
  int high_temp_threshold = 0;
  int temp_target = 0;
  int temp_status = 0;
  bool temp_enabled = 0;
  int temp_interval = 0;
  bool hvac_enabled = 0;
  int flame_value = 0;
  int flame_status = 0;
  int flame_interval = 0;
  bool flame_enabled = 0;
  bool alarm_status = 0;
  bool alarm_enabled = 0;

  pointDeviceHVAC.addTag(F("mac-address"), mac_address);

  JsonArray sensors = doc[F("sensors")];
  for (JsonObject sensor : sensors) {
    String sensorName = sensor[SENSOR_NAME_JSON_NAME];
    if (sensorName == FLAME_JSON_NAME) {
      flame_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
      flame_status = (int)sensor[STATUS_JSON_NAME];
      flame_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
      pointDeviceHVAC.addField(F("flame-value"), flame_value);
      pointDeviceHVAC.addField(F("flame-status"), flame_status);
      pointDeviceHVAC.addField(F("flame-enabled"), flame_enabled);
    } else if (sensorName == TEMP_JSON_NAME) {
      temp_value = (int)sensor[SENSOR_VALUE_JSON_NAME];
      low_temp_threshold = (int)sensor[SENSOR_LOW_THRESHOLD_JSON_NAME];
      high_temp_threshold = (int)sensor[SENSOR_HIGH_THRESHOLD_JSON_NAME];
      temp_status = (int)sensor[SENSOR_STATUS_JSON_NAME];
      temp_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
      temp_target = (int)sensor[SENSOR_TEMP_TARGET_JSON_NAME];
      temp_interval = (int)sensor[SENSOR_READING_INTERVAL_JSON_NAME];
    } else if (sensorName == HVAC_JSON_NAME) {
      hvac_enabled = ((int)sensor[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
    }
  }

  JsonObject alarm = doc[F("alarm")];
  alarm_status = ((int)alarm[STATUS_JSON_NAME] == 1 ? true : false);
  alarm_enabled = ((int)alarm[SENSOR_STATUS_JSON_NAME] == 1 ? true : false);
  pointDeviceHVAC.addField(F("alarm-status"), alarm_status);
  pointDeviceHVAC.addField(F("alarm-enabled"), alarm_enabled);

  if (!client_idb.writePoint(pointDeviceHVAC)) {
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_DB) {
      Serial.print(F("InfluxDB write failed: "));
      Serial.println(client_idb.getLastErrorMessage());
    }
#endif
  }

  if (!conn.connected()) {
    conn.close();
#ifdef ENABLE_LOGS
    if (logLevel == LOG_ALL || logLevel == LOG_DB) {
      Serial.println(F("Connecting to MySQL..."));
    }
#endif
    if (conn.connect(server_addr, 3306, mysql_user, mysql_password)) {
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_DB) {
        Serial.println(F("MySQL connection established."));
      }
#endif
    } else {
#ifdef ENABLE_LOGS
      if (logLevel == LOG_ALL || logLevel == LOG_DB) {
        Serial.println(F("MySQL connection failed."));
      }
#endif
      return;
    }
  }

  char UPSERT_DATA_HVAC[] = "INSERT INTO `%s`.`vigiloffice_hvac` ("
                          "`mac-address`, `temp-enabled`, `temp-status`, "
                          "`temp-low-threshold`, `temp-high-threshold`, "
                          "`temp-target`, `temp-value`, `temp-interval`,"
                          "`flame-enabled`, `flame-status`, `flame-value`, `flame-interval`, "
                          "`hvac-enabled`, `alarm-enabled`, `alarm-status`) "
                          "VALUES ('%s', %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d, %d) "
                          "ON DUPLICATE KEY UPDATE "
                          "`temp-enabled` = VALUES(`temp-enabled`), "
                          "`temp-status` = VALUES(`temp-status`), "
                          "`temp-low-threshold` = VALUES(`temp-low-threshold`), "
                          "`temp-high-threshold` = VALUES(`temp-high-threshold`), "
                          "`temp-target` = VALUES(`temp-target`), "
                          "`temp-value` = VALUES(`temp-value`), "
                          "`temp-interval` = VALUES(`temp-interval`), "
                          "`flame-enabled` = VALUES(`flame-enabled`), "
                          "`flame-status` = VALUES(`flame-status`), "
                          "`flame-value` = VALUES(`flame-value`), "
                          "`flame-interval` = VALUES(`flame-interval`), "
                          "`hvac-enabled` = VALUES(`hvac-enabled`), "
                          "`alarm-enabled` = VALUES(`alarm-enabled`), "
                          "`alarm-status` = VALUES(`alarm-status`)";

  MySQL_Cursor *cur_mem = new MySQL_Cursor(&conn);
  sprintf(query, UPSERT_DATA_HVAC, mysql_user, mac_address.c_str(), temp_enabled, temp_status, low_temp_threshold, high_temp_threshold, temp_target, temp_value, temp_interval,
          flame_enabled, flame_status, flame_value, flame_interval, hvac_enabled, alarm_enabled, alarm_status, mac_address.c_str());
  //Serial.println(query);
  cur_mem->execute(query);
  delete cur_mem;
  latestDBWrite = millis();
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_DB) {
    Serial.println(F("Data recorded on MySQL"));
  }
#endif

  knownDevicesDoc[mac_address][F("status")] = "connected";
}
***REMOVE TO HANDLE HVAC*** */

void handleLastWillTestamentMessage(String &payload) {
  JsonDocument doc;
  deserializeJson(doc, payload);
  String mac = doc["mac-address"];
  knownDevicesDoc[mac][F("status")] = "disconnected";
#ifdef ENABLE_LOGS
  if (logLevel == LOG_ALL || logLevel == LOG_COMM) {
    Serial.println(F("Device of type ") + String(doc[F("type")]) + F(" with mac ") + mac + F(" disconnected!"));
  }
#endif
}

void mqttMessageReceived(String &topic, String &payload) {
  if (topic == MQTT_TOPIC_REGISTER) {
    registerDevice(payload);
  } else if (topic.startsWith(F("vigiloffice/lamps")) && topic.endsWith(F("/status"))) {
    handleLampStatusMessage(payload);
  } else if (topic.startsWith(F("vigiloffice/hvacs")) && topic.endsWith(F("/status"))) {
    //***REMOVE TO HANDLE HVAC*** handleHvacStatusMessage(payload);
  } else if (topic.startsWith(MQTT_TOPIC_LWT)) {
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