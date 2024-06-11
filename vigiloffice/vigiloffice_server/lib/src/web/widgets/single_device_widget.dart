import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class SingleDevicePageWidget extends Widget {
  SingleDevicePageWidget(
      {required Device device, required bool statusAvailable})
      : super(name: 'single_device_page') {
    values = {
      'statusAvailable': statusAvailable,
      "types": DeviceType.values.map((e) => e.name).toList(),
      'device': device.toJson(),
    };
  }
}

class JsonSingleDeviceWidget extends WidgetJson {
  JsonSingleDeviceWidget({required Device device})
      : super(object: device.toJson());
}
