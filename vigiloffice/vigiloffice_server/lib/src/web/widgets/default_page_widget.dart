import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';

class DefaultPageWidget extends Widget {
  DefaultPageWidget() : super(name: 'default') {
    values = {
      "types": DeviceType.values.map((e) => e.name).toList(),
    };
  }
}
