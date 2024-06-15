import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../endpoints/lamps_endpoint.dart';
import '../../../generated/protocol.dart';
import 'semantic_helper.dart';

class JsonSingleLampRoute extends WidgetRoute {
  final bool isSemantic;

  JsonSingleLampRoute({this.isSemantic = false}) : super();

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
          'MTM | Invalid content type (${request.headers.contentType}). Please provide a lamp using application/json.',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase =
          'Invalid content type. Please provide a lamp using application/json.';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {
        'error':
            'Invalid content type. Please provide a lamp using application/json.'
      });
    }
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Lamp? lamp = await Lamp.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (lamp == null) {
      session.log('Lamp not found: $macAddress', level: LogLevel.warning);
      request.response.statusCode = HttpStatus.notFound;
      request.response.reasonPhrase = 'Lamp $macAddress not found';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Lamp $macAddress not found'});
    }
    switch (request.method) {
      case 'GET':
        return _get(session, request, lamp);
      case 'PUT':
        return _put(session, request, lamp);
      case 'DELETE':
        return _delete(session, request, lamp);
      case 'OPTIONS':
        return _options(session, request, lamp);
      default:
        request.response.statusCode = HttpStatus.methodNotAllowed;
        request.response.reasonPhrase = 'Method not allowed';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Method not allowed'});
    }
  }

  WidgetJson _options(Session session, HttpRequest request, Lamp lamp) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Allow', 'GET, PUT, DELETE, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {'options': 'GET, PUT, DELETE, OPTIONS'});
  }

  WidgetJson _get(Session session, HttpRequest request, Lamp lamp) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    setHeaders(request.response.headers);
    if (isSemantic) {
      return WidgetJson(object: transformStatusJsonToWoT(lamp.toJson()));
    }
    return WidgetJson(object: lamp.toJson());
  }

  Future<WidgetJson> _put(
      Session session, HttpRequest request, Lamp lamp) async {
    try {
      String content = await utf8.decoder.bind(request).join();
      Lamp newLamp = Lamp.fromJson(json.decode(content));
      lamp = lamp.copyWith(
        flameSensor: newLamp.flameSensor,
        motionSensor: newLamp.motionSensor,
        lightSensor: newLamp.lightSensor,
        rgbLed: newLamp.rgbLed,
        alarm: newLamp.alarm,
        lastUpdate: newLamp.lastUpdate,
      );
      lamp = await LampsEndpoint().updateLamp(session, lamp);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      if (isSemantic) {
        return WidgetJson(object: transformStatusJsonToWoT(lamp.toJson()));
      }
      return WidgetJson(object: lamp.toJson());
    } catch (e, s) {
      session.log('Failed to update lamp: ${lamp.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to update lamp';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to update lamp. $e'});
    }
  }

  Future<WidgetJson> _delete(
      Session session, HttpRequest request, Lamp lamp) async {
    try {
      Lamp? deletedLamp = await LampsEndpoint().deleteLamp(session, lamp);
      if (deletedLamp == null) {
        session.log('Failed to delete lamp ${lamp.macAddress}: not found',
            level: LogLevel.warning);
        request.response.statusCode = HttpStatus.badRequest;
        request.response.reasonPhrase = 'Lamp ${lamp.macAddress} not found';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(
            object: {'error': 'Lamp ${lamp.macAddress} not found'});
      }
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      if (isSemantic) {
        return WidgetJson(object: transformStatusJsonToWoT(lamp.toJson()));
      }
      return WidgetJson(object: deletedLamp.toJson());
    } catch (e, s) {
      session.log('Failed to delete lamp: ${lamp.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to delete lamp';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to delete lamp. $e'});
    }
  }
}
