import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class DevicesPageWidget extends Widget {
  DevicesPageWidget({required List<Map<String,dynamic>> devices, DeviceType? type})
      : super(name: 'devices_page') {
    values = {
      "filter": type?.name ?? "all",
      "types": DeviceType.values.map((e) => e.name).toList(),
      'devices': devices
    };
  }
}

class JsonDevicesWidget extends WidgetJson {
  JsonDevicesWidget({required List<Device> devices})
      : super(object: devices.map((e) => e.toJson()).toList());
}
