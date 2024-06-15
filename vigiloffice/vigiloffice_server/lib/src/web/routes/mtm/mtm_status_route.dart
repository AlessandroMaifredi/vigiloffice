import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../generated/protocol.dart';
import '../../widgets/status_page_widget.dart';

class JsonStatusRoute extends WidgetRoute {
  final DeviceType? type;

  final bool isSemantic;

  JsonStatusRoute({this.type, this.isSemantic = false}) : super();

  @override
  Future<WidgetJson> build(Session session, HttpRequest request) async {
    if (request.headers.value('Accept') != null) {
      if (request.headers.value('Accept') != 'application/json' &&
          request.headers.value('Accept') != '*/*') {
        request.response.statusCode = HttpStatus.badRequest;
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(
            object: {'error': 'This endpoint only supports application/json.'});
      }
    }
    switch (request.method) {
      case 'OPTIONS':
        return _options(session, request);
      case 'GET':
        return _get(session, request);
      default:
        request.response.statusCode = HttpStatus.badRequest;
        request.response.headers.contentType = ContentType.json;
        request.response.reasonPhrase = 'Method not supported.';
        setHeaders(request.response.headers);
        return WidgetJson(object: {
          'error':
              'Method not supported. To know more about the supported methods, please refer to the documentation or use the OPTIONS method.'
        });
    }
  }

  Future<WidgetJson> _options(Session session, HttpRequest request) async {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.set('Allow', 'GET, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {'options': 'GET, OPTIONS'});
  }

  Future<WidgetJson> _get(Session session, HttpRequest request) async {
    List<Map<String,dynamic>> devices = (await Lamp.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Hvac.db.find(session)).map((e) => e.toJson()).toList();
    devices += (await Parking.db.find(session)).map((e) => e.toJson()).toList();
    session.log('Found ${devices.length} devices.', level: LogLevel.debug);
    request.response.headers.contentType = ContentType.json;
    request.response.statusCode = HttpStatus.ok;
    setHeaders(request.response.headers);
    return JsonStatusWidget(nodes: devices, isSemantic: isSemantic);
  }
}
