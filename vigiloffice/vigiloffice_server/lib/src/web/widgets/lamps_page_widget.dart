import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';
import '../routes/mtm/semantic_helper.dart';

class LampsPageWidget extends Widget {
  LampsPageWidget({required List<Lamp> lamps}) : super(name: 'status_page') {
    final now = DateTime.now();
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      'type': DeviceType.lamp.name,
      'Type': DeviceType.lamp.name[0].toUpperCase() + DeviceType.lamp.name.substring(1),
      'devices': lamps.map((lamp) => lamp.toJson()).map((lamp) {
        if (lamp['lastUpdate'] != null) {
          final lastUpdate = DateTime.parse(lamp['lastUpdate']);
          final difference = now.difference(lastUpdate);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);

          final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

          lamp['lastUpdate'] = timeAgo;
        } else {
          lamp['lastUpdate'] = 'Unknown';
        }
        return lamp;
      }).toList(),
    };
  }
}


class JsonLampsWidget extends WidgetJson {
  JsonLampsWidget({required List<Lamp> lamps, bool isSemantic = false})
      : super(object: lamps.map((e) {
        if (isSemantic) {
          return transformStatusJsonToWoT(e.toJson());
        }
        return e.toJson();
      }).toList());
}