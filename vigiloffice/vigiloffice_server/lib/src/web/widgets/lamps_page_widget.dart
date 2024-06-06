import 'package:serverpod/relic.dart';

import '../../generated/protocol.dart';

class LampsPageWidget extends Widget {
  LampsPageWidget({required List<Lamp> lamps}) : super(name: 'lamps_page') {
    values = {
      'type': DeviceType.lamp.name,
      'lamps': lamps.map((lamp) => lamp.toJson()).toList(),
    };
  }
}
