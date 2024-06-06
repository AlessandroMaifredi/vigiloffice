import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/device_not_found_page_widget.dart';
import '../widgets/single_lamp_page_widget.dart';

class SingleLampRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String macAddress = request.uri.toString().split("/").last;
    Lamp? lamp = await Lamp.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (lamp == null) {
      return DeviceNotFoundPageWidget(
          type: DeviceType.lamp, macAddress: macAddress);
    }
    if (request.method == 'POST') {
      String content = await utf8.decoder.bind(request).join();
      print('Received POST request with body: $content');
      //MqttManager().controlLamp(lamp);
    }
    return SingleLampPageWidget(lamp: lamp);
  }
}
