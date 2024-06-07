import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class SingleLampPageWidget extends Widget {
  SingleLampPageWidget({required Lamp lamp}) : super(name: 'single_lamp_page') {
    Map<String, dynamic> lampValues = lamp.toJson();
    if (lamp.lastUpdate != null) {
      final difference = DateTime.now().difference(lamp.lastUpdate!);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

      lampValues['lastUpdateString'] = timeAgo;
    } else {
      lampValues['lastUpdateString'] = 'Unknown';
      lampValues['lastUpdate'] = 'null';
    }

    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      "lamp": lampValues,
      if (lamp.flameSensor.enabled) "flameIsEnabled": true,
      if (!lamp.flameSensor.enabled) "flameIsEnabled": false,
      if (lamp.flameSensor.status == 0) "flameStatus0": true,
      if (lamp.flameSensor.status == 0) "flameStatus1": false,
      if (lamp.flameSensor.status == 1) "flameStatus1": true,
      if (lamp.flameSensor.status == 1) "flameStatus0": false,
      if (lamp.lightSensor.enabled) "lightIsEnabled": true,
      if (!lamp.lightSensor.enabled) "lightIsEnabled": false,
      if (lamp.lightSensor.status == 0) "lightStatus0": true,
      if (lamp.lightSensor.status == 0) "lightStatus1": false,
      if (lamp.lightSensor.status == 1) "lightStatus1": true,
      if (lamp.lightSensor.status == 1) "lightStatus0": false,
      if (lamp.motionSensor.enabled) "motionIsEnabled": true,
      if (!lamp.motionSensor.enabled) "motionIsEnabled": false,
      if (lamp.motionSensor.status == 0) "motionStatus0": true,
      if (lamp.motionSensor.status == 0) "motionStatus1": false,
      if (lamp.motionSensor.status == 0) "motionStatus2": true,
      if (lamp.motionSensor.status == 1) "motionStatus1": true,
      if (lamp.motionSensor.status == 1) "motionStatus0": false,
      if (lamp.motionSensor.status == 1) "motionStatus2": false,
      if (lamp.motionSensor.status == 2) "motionStatus2": true,
      if (lamp.motionSensor.status == 2) "motionStatus0": false,
      if (lamp.motionSensor.status == 2) "motionStatus1": false,
      if (lamp.rgbLed.enabled) "rgbIsEnabled": true,
      if (!lamp.rgbLed.enabled) "rgbIsEnabled": false,
      if (lamp.rgbLed.status <= 2) "rgbStatus0": true,
      if (lamp.rgbLed.status <= 2) "rgbStatus3": false,
      if (lamp.rgbLed.status <= 2) "rgbStatus4": false,
      if (lamp.rgbLed.status == 3) "rgbStatus3": true,
      if (lamp.rgbLed.status == 3) "rgbStatus0": false,
      if (lamp.rgbLed.status == 3) "rgbStatus4": false,
      if (lamp.rgbLed.status == 4) "rgbStatus4": true,
      if (lamp.rgbLed.status == 4) "rgbStatus0": false,
      if (lamp.rgbLed.status == 4) "rgbStatus3": false,
      if (lamp.alarm.enabled) "alarmIsEnabled": true,
      if (!lamp.alarm.enabled) "alarmIsEnabled": false,
      if (lamp.alarm.status) "alarmIsActive": true,
      if (!lamp.alarm.status) "alarmIsActive": false,
    };
  }
}
