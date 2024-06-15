import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class SingleParkingPageWidget extends Widget {
  SingleParkingPageWidget(
      {required Parking parking, required DeviceStatus deviceStatus})
      : super(name: 'single_parking_page') {
    Map<String, dynamic> parkingValues = parking.toJson();
    if (parking.lastUpdate != null) {
      final difference = DateTime.now().difference(parking.lastUpdate!);
      final hours = difference.inHours;
      final minutes = difference.inMinutes.remainder(60);
      final seconds = difference.inSeconds.remainder(60);

      final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

      parkingValues['lastUpdateString'] = timeAgo;
    } else {
      parkingValues['lastUpdateString'] = 'Unknown';
      parkingValues['lastUpdate'] = 'null';
    }

    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      "deviceConnected": deviceStatus == DeviceStatus.connected ? true : false,
      "parking": parkingValues,
      if (parking.flameSensor.enabled) "flameIsEnabled": true,
      if (!parking.flameSensor.enabled) "flameIsEnabled": false,
      if (parking.flameSensor.status == 0) "flameStatus0": true,
      if (parking.flameSensor.status == 0) "flameStatus1": false,
      if (parking.flameSensor.status == 1) "flameStatus1": true,
      if (parking.flameSensor.status == 1) "flameStatus0": false,
      if (parking.floodingSensor.enabled) "floodingIsEnabled": true,
      if (!parking.floodingSensor.enabled) "floodingIsEnabled": false,
      if (parking.floodingSensor.status == 0) "floodingStatus0": true,
      if (parking.floodingSensor.status == 0) "floodingStatus1": false,
      if (parking.floodingSensor.status == 1) "floodingStatus1": true,
      if (parking.floodingSensor.status == 1) "floodingStatus0": false,
      if (parking.avoidanceSensor.enabled) "avoidanceIsEnabled": true,
      if (!parking.avoidanceSensor.enabled) "avoidanceIsEnabled": false,
      if (parking.avoidanceSensor.status == 0) "avoidanceStatus0": true,
      if (parking.avoidanceSensor.status == 0) "avoidanceStatus1": false,
      if (parking.avoidanceSensor.status == 1) "avoidanceStatus1": true,
      if (parking.avoidanceSensor.status == 1) "avoidanceStatus0": false,
      if (parking.rgbLed.enabled) "rgbIsEnabled": true,
      if (!parking.rgbLed.enabled) "rgbIsEnabled": false,
      if (parking.rgbLed.status == 0) "rgbStatus0": true,
      if (parking.rgbLed.status == 0) "rgbStatus1": false,
      if (parking.rgbLed.status == 0) "rgbStatus2": false,
      if (parking.rgbLed.status == 0) "rgbStatus3": false,
      if (parking.rgbLed.status == 1) "rgbStatus1": true,
      if (parking.rgbLed.status == 1) "rgbStatus0": false,
      if (parking.rgbLed.status == 1) "rgbStatus2": false,
      if (parking.rgbLed.status == 1) "rgbStatus3": false,
      if (parking.rgbLed.status == 2) "rgbStatus2": true,
      if (parking.rgbLed.status == 2) "rgbStatus0": false,
      if (parking.rgbLed.status == 2) "rgbStatus1": false,
      if (parking.rgbLed.status == 2) "rgbStatus3": false,
      if (parking.rgbLed.status == 3) "rgbStatus3": true,
      if (parking.rgbLed.status == 3) "rgbStatus0": false,
      if (parking.rgbLed.status == 3) "rgbStatus1": false,
      if (parking.rgbLed.status == 3) "rgbStatus2": false,
      if (parking.alarm.enabled) "alarmIsEnabled": true,
      if (!parking.alarm.enabled) "alarmIsEnabled": false,
      if (parking.alarm.status) "alarmIsActive": true,
      if (!parking.alarm.status) "alarmIsActive": false,
    };
  }
}
