

import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/devices_page_widget.dart';

class DevicesRoute extends WidgetRoute {
  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Device> devices = await Device.db.find(session);
    return DevicesPageWidget(devices: devices);
  }
}