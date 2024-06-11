import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../generated/protocol.dart';
import '../widgets/parkings_page_widget.dart';

class ParkingsRoute extends WidgetRoute {
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
    List<Parking> parkings = await Parking.db.find(session);
    request.response.headers.contentType = ContentType.html;
    request.response.statusCode = HttpStatus.ok;
    setHeaders(request.response.headers);
    return ParkingsPageWidget(parkings: parkings);
  }
}
