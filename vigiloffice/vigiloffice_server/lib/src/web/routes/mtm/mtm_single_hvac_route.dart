import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/endpoints/hvacs_endpoint.dart';

import '../../../generated/protocol.dart';

class JsonSingleHvacRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
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
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Hvac? hvac = await Hvac.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (hvac == null) {
      session.log('Hvac not found: $macAddress', level: LogLevel.warning);
      request.response.statusCode = HttpStatus.notFound;
      request.response.reasonPhrase = 'Hvac $macAddress not found';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Hvac $macAddress not found'});
    }
    switch (request.method) {
      case 'GET':
        return _get(session, request, hvac);
      case 'PUT':
        return _put(session, request, hvac);
      case 'DELETE':
        return _delete(session, request, hvac);
      case 'OPTIONS':
        return _options(session, request, hvac);
      default:
        request.response.statusCode = HttpStatus.methodNotAllowed;
        request.response.reasonPhrase = 'Method not allowed';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Method not allowed'});
    }
  }

  WidgetJson _options(Session session, HttpRequest request, Hvac hvac) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Allow', 'GET, PUT, DELETE, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {'options': 'GET, PUT, DELETE, OPTIONS'});
  }

  WidgetJson _get(Session session, HttpRequest request, Hvac hvac) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    setHeaders(request.response.headers);
    return WidgetJson(object: hvac.toJson());
  }

  Future<WidgetJson> _put(
      Session session, HttpRequest request, Hvac hvac) async {
    try {
            String content = await utf8.decoder.bind(request).join();
      Hvac newHvac = Hvac.fromJson(json.decode(content));
      hvac = hvac.copyWith(
        flameSensor: newHvac.flameSensor,
        tempSensor: newHvac.tempSensor,
        ventActuator: newHvac.ventActuator,
        alarm: newHvac.alarm,
        lastUpdate: newHvac.lastUpdate,
      );
      hvac = await HvacsEndpoint().updateHvac(session, hvac);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: hvac.toJson());
    } catch (e, s) {
      session.log('Failed to update hvac: ${hvac.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to update hvac';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to update hvac. $e'});
    }
  }

  Future<WidgetJson> _delete(
      Session session, HttpRequest request, Hvac hvac) async {
    try {
      hvac = await HvacsEndpoint().deleteHvac(session, hvac);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: hvac.toJson());
    } catch (e, s) {
      session.log('Failed to delete hvac: ${hvac.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to delete hvac';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to delete hvac. $e'});
    }
  }
}
