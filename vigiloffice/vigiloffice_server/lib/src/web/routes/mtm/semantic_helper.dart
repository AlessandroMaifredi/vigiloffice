Map<String, dynamic> transformStatusJsonToWoT(Map<String, dynamic> json) {
  Map<String, dynamic> jsonLD = {
    "@context": "https://www.w3.org/2019/wot/td/v1",
    "@type": "Thing",
    "title": json["type"],
    "id": "urn:dev:mac:${json["macAddress"]}",
    "lastUpdate": json["lastUpdate"],
    "forms": [
      {
        "name": "Semantic status",
        "href": "/api/wot/v1/status/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic informations of the device",
        "href": "/api/wot/v1/devices/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic status list",
        "href": "/api/wot/v1/status/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic device list",
        "href": "/api/wot/v1/devices/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "MTM status",
        "href": "/api/v1/status/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM informations of the device",
        "href": "/api/v1/devices/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM status list",
        "href": "/api/v1/status/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM device list",
        "href": "/api/v1/devices/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      }
    ],
    "properties": {}
  };

  json.remove("type");
  json.remove("macAddress");
  json.remove("id");
  json.remove("lastUpdate");
  if (json.containsKey("renterId")) {
    jsonLD["renterId"] = json["renterId"];
    json.remove("renterId");
  }

  for (var e in json.entries) {
    jsonLD["properties"][e.key] = {"type": "object", "properties": {}};
    Map<String, dynamic> subJson = e.value;
    subJson.forEach((subKey, subValue) {
      jsonLD["properties"][e.key]["properties"][subKey] = {
        "type": subValue.runtimeType.toString(),
        "value": subValue
      };
    });
  }

  return jsonLD;
}

Map<String, dynamic> transformBasicInfoJsonToWoT(Map<String, dynamic> json) {
  Map<String, dynamic> jsonLD = {
    "@context": "https://www.w3.org/2019/wot/td/v1",
    "@type": "Thing",
    "title": json["type"],
    "id": "urn:dev:mac:${json["macAddress"]}",
    "status": json["status"],
    "forms": [
      {
        "name": "Semantic status",
        "href": "/api/wot/v1/status/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic informations of the device",
        "href": "/api/wot/v1/devices/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic status list",
        "href": "/api/wot/v1/status/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "Semantic device list",
        "href": "/api/wot/v1/devices/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty"]
      },
      {
        "name": "MTM status",
        "href": "/api/v1/status/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM informations of the device",
        "href": "/api/v1/devices/${json["type"]}s/${json["macAddress"]}",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM status list",
        "href": "/api/v1/status/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      },
      {
        "name": "MTM device list",
        "href": "/api/v1/devices/${json["type"]}s",
        "contentType": "application/json",
        "op": ["readproperty", "writeproperty"]
      }
    ]
  };

  return jsonLD;
}
