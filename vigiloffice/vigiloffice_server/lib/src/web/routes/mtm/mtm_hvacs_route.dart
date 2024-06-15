import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../endpoints/hvacs_endpoint.dart';
import '../../../generated/protocol.dart';
import '../../widgets/hvacs_page_widget.dart';
import 'semantic_helper.dart';

class JsonHvacsRoute extends WidgetRoute {

  final bool isSemantic;

  JsonHvacsRoute({this.isSemantic = false}) : super();

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
    return WidgetJson(object: {'options': 'GET, POST, OPTIONS'});
  }

  Future<WidgetJson> _get(Session session, HttpRequest request) async {
    List<Hvac> hvacs = await Hvac.db.find(session);
    session.log('Found ${hvacs.length} hvacs.', level: LogLevel.debug);
    request.response.headers.contentType = ContentType.json;
    request.response.statusCode = HttpStatus.ok;
    setHeaders(request.response.headers);
    return JsonHvacsWidget(hvacs: hvacs, isSemantic: isSemantic);
  }

  Future<WidgetJson> _post(Session session, HttpRequest request) async {
    if (!(request.headers.contentType?.mimeType.contains('application/json') ??
        true)) {
      session.log(
          'MTM | Invalid content type (${request.headers.contentType}). Please provide a hvac using application/json.',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase =
          'Invalid content type. Please provide a hvac using application/json.';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {
        'error':
            'Invalid content type. Please provide a hvac using application/json.'
      });
    }
    String content = await utf8.decoder.bind(request).join();
    session.log('MTM | Received POST request with body: $content',
        level: LogLevel.debug);
    try {
      HvacsEndpoint endpoint = HvacsEndpoint();
      Hvac hvac = Hvac.fromJson(json.decode(content));
      if ((await endpoint.readHvac(session, hvac)) != null) {
        request.response.statusCode = HttpStatus.conflict;
        request.response.reasonPhrase = 'Hvac already exists.';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Hvac already exists.'});
      }
      hvac = await endpoint.createHvac(session, hvac);
      session.log('MTM | Hvac created: ${hvac.macAddress}',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      if(isSemantic){
        return WidgetJson(object: transformStatusJsonToWoT(hvac.toJson()));
      }
      return WidgetJson(object: hvac.toJson());
    } catch (e, s) {
      session.log('MTM | Failed to create hvac',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = e.toString();
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(
          object: {'error': 'Failed to create hvac. ${e.toString()}'});
    }
  }
}
