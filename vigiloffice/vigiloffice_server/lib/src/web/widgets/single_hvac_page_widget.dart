import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class SingleHvacPageWidget extends Widget {
  SingleHvacPageWidget({required Hvac hvac, required DeviceStatus deviceStatus})
      : super(name: 'single_hvac_page') {
    Map<String, dynamic> hvacValues = hvac.toJson();
    if (hvac.lastUpdate != null) {
      final difference = DateTime.now().difference(hvac.lastUpdate!);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

      hvacValues['lastUpdateString'] = timeAgo;
    } else {
      hvacValues['lastUpdateString'] = 'Unknown';
      hvacValues['lastUpdate'] = 'null';
    }

    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      "deviceConnected": deviceStatus == DeviceStatus.connected ? true : false,
      "hvac": hvacValues,
      if (hvac.flameSensor.enabled) "flameIsEnabled": true,
      if (!hvac.flameSensor.enabled) "flameIsEnabled": false,
      if (hvac.flameSensor.status == 0) "flameStatus0": true,
      if (hvac.flameSensor.status == 0) "flameStatus1": false,
      if (hvac.flameSensor.status == 1) "flameStatus1": true,
      if (hvac.flameSensor.status == 1) "flameStatus0": false,
      if (hvac.tempSensor.enabled) "tempIsEnabled": true,
      if (!hvac.tempSensor.enabled) "tempIsEnabled": false,
      if (hvac.tempSensor.status == 0) "tempStatus0": true,
      if (hvac.tempSensor.status == 0) "tempStatus1": false,
      if (hvac.tempSensor.status == 0) "tempStatus2": false,
      if (hvac.tempSensor.status == 1) "tempStatus1": true,
      if (hvac.tempSensor.status == 1) "tempStatus0": false,
      if (hvac.tempSensor.status == 1) "tempStatus2": false,
      if (hvac.tempSensor.status == 2) "tempStatus2": true,
      if (hvac.tempSensor.status == 2) "tempStatus0": false,
      if (hvac.tempSensor.status == 2) "tempStatus1": false,
      if (hvac.ventActuator.enabled) "ventIsEnabled": true,
      if (!hvac.ventActuator.enabled) "ventIsEnabled": false,
      if (hvac.alarm.enabled) "alarmIsEnabled": true,
      if (!hvac.alarm.enabled) "alarmIsEnabled": false,
      if (hvac.alarm.status) "alarmIsActive": true,
      if (!hvac.alarm.status) "alarmIsActive": false,
    };
  }
}
