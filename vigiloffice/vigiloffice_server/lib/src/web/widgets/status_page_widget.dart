import 'package:serverpod/relic.dart';
import 'package:vigiloffice_server/src/web/routes/mtm/semantic_helper.dart';

import '../../generated/protocol.dart';

class StatusPageWidget extends Widget {
  StatusPageWidget({required List<Map<String, dynamic>> nodes}) : super(name: 'status_page') {
    final now = DateTime.now();
    nodes = nodes.map((device) {
      if (device['lastUpdate'] != null) {
        final lastUpdate = DateTime.parse(device['lastUpdate']);
        final difference = now.difference(lastUpdate);
        final hours = difference.inHours;
        final minutes = difference.inMinutes.remainder(60);
        final seconds = difference.inSeconds.remainder(60);

        final timeAgo = '${hours}h : ${minutes}m : ${seconds}s ago';

        device['lastUpdate'] = timeAgo;
      } else {
        device['lastUpdate'] = 'Unknown';
      }
      return device;
    }).toList();
    values = {
      "type": "",
      "Type": "All",
      "types": DeviceType.values.map((e) => e.name).toList(),
      'devices': nodes,
    };
  }
}

class JsonStatusWidget extends WidgetJson {
  JsonStatusWidget({required List<Map<String, dynamic>> nodes, bool isSemantic = false})
      : super(object: isSemantic ? nodes.map((n) => transformStatusJsonToWoT(n)).toList() : nodes);
}
