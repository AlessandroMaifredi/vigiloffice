import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class DeviceNotFoundPageWidget extends Widget {
  DeviceNotFoundPageWidget(
      {required DeviceType type, required String macAddress})
      : super(name: 'not_found_page');
}
