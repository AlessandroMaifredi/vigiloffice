import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class DevicesPageWidget extends Widget {
  DevicesPageWidget({required List<Device> devices})
      : super(name: 'devices_page') {
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
      'devices': devices.map((device) => device.toJson()).toList(),
    };
  }
}
