#include <ArduinoJson.h>


void connectToMQTTBroker();
void mqttMessageReceived(String &topic, String &payload);
void commSetup();
void commLoop(std::function<void (JsonDocument)> callback);
