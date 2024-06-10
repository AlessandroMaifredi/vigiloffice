import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class ParkingsPageWidget extends Widget {
  ParkingsPageWidget({required List<Parking> parkings})
      : super(name: 'single_type_page') {
    final now = DateTime.now();
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      'type': DeviceType.parking.name,
      'Type': DeviceType.parking.name[0].toUpperCase() +
          DeviceType.parking.name.substring(1),
      'devices': parkings.map((parking) => parking.toJson()).map((parking) {
        if (parking['lastUpdate'] != null) {
          final lastUpdate = DateTime.parse(parking['lastUpdate']);
          final difference = now.difference(lastUpdate);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);

          final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

          parking['lastUpdate'] = timeAgo;
        } else {
          parking['lastUpdate'] = 'Unknown';
        }
        return parking;
      }).toList(),
    };
  }
}

class JsonParkingsWidget extends WidgetJson {
  JsonParkingsWidget({required List<Parking> parkings})
      : super(object: parkings.map((e) => e.toJson()).toList());
}
