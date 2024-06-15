import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/web/routes/mtm/semantic_helper.dart';

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
  JsonSingleDeviceWidget({required Device device, bool isSemantic = false})
      : super(object: isSemantic ? transformBasicInfoJsonToWoT(device.toJson()) : device.toJson());
}
