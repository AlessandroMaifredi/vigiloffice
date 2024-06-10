import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/web/widgets/status_page_widget.dart';

import '../../generated/protocol.dart';

class StatusRoute extends WidgetRoute {
  StatusRoute() : super();

  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    List<Map<String, dynamic>> devices =
        (await Lamp.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Hvac.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Parking.db.find(session)).map((e) => e.toJson()).toList();
    return StatusPageWidget(nodes: devices);
  }
}
