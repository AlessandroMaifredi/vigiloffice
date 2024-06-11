import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/status_page_widget.dart';

class StatusRoute extends WidgetRoute {
  StatusRoute() : super();

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
    List<Map<String, dynamic>> devices =
        (await Lamp.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Hvac.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Parking.db.find(session)).map((e) => e.toJson()).toList();
    return StatusPageWidget(nodes: devices);
  }
}
