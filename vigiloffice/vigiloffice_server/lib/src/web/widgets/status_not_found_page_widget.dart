import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class StatusNotFoundPageWidget extends Widget {
  StatusNotFoundPageWidget(
      {DeviceType? type, required String macAddress})
      : super(name: 'status_not_found_page') {
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      "macAddress": macAddress,
      "type": type?.name ?? "all",
    };
  }
}
