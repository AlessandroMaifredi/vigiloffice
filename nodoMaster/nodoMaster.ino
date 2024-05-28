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
WiFiServer server(80);

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

  // WiFiManager
  // Local intialization. Once its business is done, there is no need to keep it around
  WiFiManager wifiManager;
  // Uncomment and run it once, if you want to erase all the stored information
  //wifiManager.resetSettings();
  // set custom ip for portal
  // wifiManager.setAPConfig(IPAddress(10,0,1,1), IPAddress(10,0,1,1), IPAddress(255,255,255,0));

  // fetches ssid and pass from eeprom and tries to connect
  // if it does not connect it starts an access point with the specified name
  // here  "AutoConnectAP"
  // and goes into a blocking loop awaiting configuration
  wifiManager.autoConnect("AP Vigiloffice Master - **MAC**");  //Serve per creare un access point che broadcasterà il nome dell'SSID
  // or use this for auto generated name ESP + ChipID
  // wifiManager.autoConnect();

  // if you get here you have connected to the WiFi

  server.begin();

  lcd.clear();
  lcd.setCursor(0, 0);
  lcd.print(F("Server:"));
  lcd.setCursor(0, 1);
  lcd.print(WiFi.localIP());
}

void loop() {
  listenForClients();
  connectToMQTTBroker();
  mqttClient.loop();
  check_influxdb();
}

void listenForClients() {
  WiFiClient client = server.available();  // Listen for incoming clients

  if (client) {                     // If a new client connects,
    Serial.println("New Client.");  // print a message out in the serial port
    String currentLine = "";        // make a String to hold incoming data from the client
    while (client.connected()) {    // loop while the client's connected
      if (client.available()) {     // if there's bytes to read from the client,
        char c = client.read();     // read a byte, then
        Serial.write(c);            // print it out the serial monitor
        header += c;
        if (c == '\n') {  // if the byte is a newline character
          // if the current line is blank, you got two newline characters in a row.
          // that's the end of the client HTTP request, so send a response:
          if (currentLine.length() == 0) {
            // HTTP headers always start with a response code (e.g. HTTP/1.1 200 OK)
            // and a content-type so the client knows what's coming, then a blank line:
            client.println("HTTP/1.1 200 OK");
            client.println("Content-type:text/html");
            client.println("Connection: close");
            client.println();

            // turns the GPIOs on and off
            if (header.indexOf("GET /0/on") >= 0) {
              Serial.println("GPIO 0 on");
              output0State = "on";
              digitalWrite(output0, LOW);
            } else if (header.indexOf("GET /0/off") >= 0) {
              Serial.println("GPIO 0 off");
              output0State = "off";
              digitalWrite(output0, HIGH);
            } else if (header.indexOf("GET /4/on") >= 0) {
              Serial.println("GPIO 4 on");
              output4State = "on";
              digitalWrite(output4, LOW);
            } else if (header.indexOf("GET /4/off") >= 0) {
              Serial.println("GPIO 4 off");
              output4State = "off";
              digitalWrite(output4, HIGH);
            }

            // Display the HTML web page
            client.println("<!DOCTYPE html><html>");
            client.println("<head><meta name=\"viewport\" content=\"width=device-width, initial-scale=1\">");
            client.println("<link rel=\"icon\" href=\"data:,\">");
            // CSS to style the on/off buttons
            // Feel free to change the background-color and font-size attributes to fit your preferences
            client.println("<style>html { font-family: Helvetica; display: inline-block; margin: 0px auto; text-align: center;}");
            client.println(".button { background-color: #195B6A; border: none; color: white; padding: 16px 40px;");
            client.println("text-decoration: none; font-size: 30px; margin: 2px; cursor: pointer;}");
            client.println(".button2 {background-color: #77878A;}</style></head>");

            // Web Page Heading
            client.println("<body><h1>ESP8266 Web Server</h1>");

            // Display current state, and ON/OFF buttons for GPIO 0
            client.println("<p>GPIO 0 - State " + output0State + "</p>");
            // If the output0State is off, it displays the ON button
            if (output0State == "off") {
              client.println("<p><a href=\"/0/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/0/off\"><button class=\"button button2\">OFF</button></a></p>");
            }

            // Display current state, and ON/OFF buttons for GPIO 4
            client.println("<p>GPIO 4 - State " + output4State + "</p>");
            // If the output4State is off, it displays the ON button
            if (output4State == "off") {
              client.println("<p><a href=\"/4/on\"><button class=\"button\">ON</button></a></p>");
            } else {
              client.println("<p><a href=\"/4/off\"><button class=\"button button2\">OFF</button></a></p>");
            }
            client.println("</body></html>");

            // The HTTP response ends with another blank line
            client.println();
            // Break out of the while loop
            break;
          } else {  // if you got a newline, then clear currentLine
            currentLine = "";
          }
        } else if (c != '\r') {  // if you got anything else but a carriage return character,
          currentLine += c;      // add it to the end of the currentLine
        }
      }
    }
    // Clear the header variable
    header = "";
    // Close the connection
    client.stop();
    Serial.println("Client disconnected.");
    Serial.println("");
  }
}

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