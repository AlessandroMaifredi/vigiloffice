import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';
import '../routes/mtm/semantic_helper.dart';

class HvacsPageWidget extends Widget {
  HvacsPageWidget({required List<Hvac> hvacs})
      : super(name: 'status_page') {
    final now = DateTime.now();
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      'type': DeviceType.hvac.name,
      'Type': DeviceType.hvac.name[0].toUpperCase() +
          DeviceType.hvac.name.substring(1),
      'devices': hvacs.map((hvac) => hvac.toJson()).map((hvac) {
        if (hvac['lastUpdate'] != null) {
          final lastUpdate = DateTime.parse(hvac['lastUpdate']);
          final difference = now.difference(lastUpdate);
          final hours = difference.inHours;
          final minutes = difference.inMinutes.remainder(60);
          final seconds = difference.inSeconds.remainder(60);

          final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

          hvac['lastUpdate'] = timeAgo;
        } else {
          hvac['lastUpdate'] = 'Unknown';
        }
        return hvac;
      }).toList(),
    };
  }
}


class JsonHvacsWidget extends WidgetJson {
  JsonHvacsWidget({required List<Hvac> hvacs, bool isSemantic = false})
      : super(object: hvacs.map((e) {
        if (isSemantic) {
          return transformStatusJsonToWoT(e.toJson());
        }
        return e.toJson();
      }).toList());
}