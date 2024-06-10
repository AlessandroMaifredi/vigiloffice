import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/devices_page_widget.dart';

class DevicesRoute extends WidgetRoute {
  final DeviceType? type;

  DevicesRoute({this.type}) : super();

  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Device> devices = await Device.db.find(session, where: (o) {
      if (type == null) return o.macAddress.notEquals("");
      return o.type.equals(type);
    });
    return DevicesPageWidget(devices: devices, type: type);
  }
}
