import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/devices_page_widget.dart';

class DevicesRoute extends WidgetRoute {
  final DeviceType? type;

  DevicesRoute({this.type}) : super();

  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.html;
      request.response.headers.set('Allow', 'GET, OPTIONS');
      setHeaders(request.response.headers);
    } else {
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.ok;
      setHeaders(request.response.headers);
    }
    List<Device> devices = await Device.db.find(session, where: (o) {
      if (type == null) return o.macAddress.notEquals("");
      return o.type.equals(type);
    });
    List<Map<String, dynamic>> devicesMap = [];
    for (var device in devices) {
      bool statusAvailable = false;
      switch (device.type) {
        case DeviceType.lamp:
          statusAvailable = (await Lamp.db.findFirstRow(session,
                  where: (o) => o.macAddress.equals(device.macAddress))) !=
              null;
          break;
        case DeviceType.hvac:
          statusAvailable = (await Hvac.db.findFirstRow(session,
                  where: (o) => o.macAddress.equals(device.macAddress))) !=
              null;
          break;
        case DeviceType.parking:
          statusAvailable = (await Parking.db.findFirstRow(session,
                  where: (o) => o.macAddress.equals(device.macAddress))) !=
              null;
          break;
      }
      Map<String, dynamic> deviceMap = device.toJson();
      deviceMap['statusAvailable'] = statusAvailable;
      devicesMap.add(deviceMap);
    }
    return DevicesPageWidget(devices: devicesMap, type: type);
  }
}
