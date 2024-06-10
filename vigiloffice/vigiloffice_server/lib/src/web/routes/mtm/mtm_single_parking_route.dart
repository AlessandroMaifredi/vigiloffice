import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/endpoints/parkings_endpoint.dart';

import '../../../generated/protocol.dart';

class JsonSingleParkingRoute extends WidgetRoute {
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
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Parking? parking = await Parking.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (parking == null) {
      session.log('Parking not found: $macAddress', level: LogLevel.warning);
      request.response.statusCode = HttpStatus.notFound;
      request.response.reasonPhrase = 'Parking $macAddress not found';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Parking $macAddress not found'});
    }
    switch (request.method) {
      case 'GET':
        return _get(session, request, parking);
      case 'PUT':
        return _put(session, request, parking);
      case 'DELETE':
        return _delete(session, request, parking);
      case 'OPTIONS':
        return _options(session, request, parking);
      default:
        request.response.statusCode = HttpStatus.methodNotAllowed;
        request.response.reasonPhrase = 'Method not allowed';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Method not allowed'});
    }
  }

  WidgetJson _options(Session session, HttpRequest request, Parking parking) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Allow', 'GET, PUT, DELETE, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {'options': 'GET, PUT, DELETE, OPTIONS'});
  }

  WidgetJson _get(Session session, HttpRequest request, Parking parking) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    setHeaders(request.response.headers);
    return WidgetJson(object: parking.toJson());
  }

  Future<WidgetJson> _put(
      Session session, HttpRequest request, Parking parking) async {
    try {
      String content = await utf8.decoder.bind(request).join();
      Parking newParking = Parking.fromJson(json.decode(content));
      parking = parking.copyWith(
        floodingSensor: newParking.floodingSensor,
        flameSensor: newParking.flameSensor,
        avoidanceSensor: newParking.avoidanceSensor,
        rgbLed: newParking.rgbLed,
        alarm: newParking.alarm,
        lastUpdate: newParking.lastUpdate,
      );
      parking = await ParkingsEndpoint().updateParking(session, parking);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: parking.toJson());
    } catch (e, s) {
      session.log('Failed to update parking: ${parking.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to update parking';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to update parking. $e'});
    }
  }

  Future<WidgetJson> _delete(
      Session session, HttpRequest request, Parking parking) async {
    try {
      parking = await ParkingsEndpoint().deleteParking(session, parking);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: parking.toJson());
    } catch (e, s) {
      session.log('Failed to delete parking: ${parking.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to delete parking';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to delete parking. $e'});
    }
  }
}
