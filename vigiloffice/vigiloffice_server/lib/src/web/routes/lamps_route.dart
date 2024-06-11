import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/lamps_page_widget.dart';

class LampsRoute extends WidgetRoute {
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
    List<Lamp> lamps = await Lamp.db.find(session);
    return LampsPageWidget(lamps: lamps);
  }
}
