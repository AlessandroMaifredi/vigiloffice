import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../endpoints/parkings_endpoint.dart';
import '../../../generated/protocol.dart';
import '../../widgets/parkings_page_widget.dart';
import 'semantic_helper.dart';

class JsonParkingsRoute extends WidgetRoute {

  final bool isSemantic;

  JsonParkingsRoute({this.isSemantic = false}) : super();

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
      case 'POST':
        return _post(session, request);
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
    request.response.headers.set('Allow', 'GET, POST, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {});
  }

  Future<WidgetJson> _get(Session session, HttpRequest request) async {
    List<Parking> parkings = await Parking.db.find(session);
    session.log('Found ${parkings.length} parkings.', level: LogLevel.debug);
    request.response.headers.contentType = ContentType.json;
    request.response.statusCode = HttpStatus.ok;
    setHeaders(request.response.headers);
    return JsonParkingsWidget(parkings: parkings, isSemantic: isSemantic);
  }

  Future<WidgetJson> _post(Session session, HttpRequest request) async {
    if (!(request.headers.contentType?.mimeType.contains('application/json') ??
        true)) {
      session.log(
          'MTM | Invalid content type (${request.headers.contentType}). Please provide a parking using application/json.',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase =
          'Invalid content type. Please provide a parking using application/json.';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {
        'error':
            'Invalid content type. Please provide a parking using application/json.'
      });
    }
    String content = await utf8.decoder.bind(request).join();
    session.log('MTM | Received POST request with body: $content',
        level: LogLevel.debug);
    try {
      ParkingsEndpoint endpoint = ParkingsEndpoint();
      Parking parking = Parking.fromJson(json.decode(content));
      if ((await endpoint.readParking(session, parking)) != null) {
        request.response.statusCode = HttpStatus.conflict;
        request.response.reasonPhrase = 'Parking already exists.';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Parking already exists.'});
      }
      parking = await endpoint.createParking(session, parking);
      session.log('MTM | Parking created: ${parking.macAddress}',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      if(isSemantic){
        return WidgetJson(object: transformStatusJsonToWoT(parking.toJson()));
      }
      return WidgetJson(object: parking.toJson());
    } catch (e, s) {
      session.log('MTM | Failed to create parking',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = e.toString();
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(
          object: {'error': 'Failed to create parking. ${e.toString()}'});
    }
  }
}
