import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../endpoints/device_endpoint.dart';
import '../../../generated/protocol.dart';

class JsonSingleDeviceRoute extends WidgetRoute {
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
          'MTM | Invalid content type (${request.headers.contentType}). Please provide a device using application/json.',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase =
          'Invalid content type. Please provide a device using application/json.';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {
        'error':
            'Invalid content type. Please provide a device using application/json.'
      });
    }
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Device? device = await Device.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (device == null) {
      session.log('Device not found: $macAddress', level: LogLevel.warning);
      request.response.statusCode = HttpStatus.notFound;
      request.response.reasonPhrase = 'Device $macAddress not found';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Device $macAddress not found'});
    }
    switch (request.method) {
      case 'GET':
        return _get(session, request, device);
      case 'PUT':
        return _put(session, request, device);
      case 'DELETE':
        return _delete(session, request, device);
      case 'OPTIONS':
        return _options(session, request, device);
      default:
        request.response.statusCode = HttpStatus.methodNotAllowed;
        request.response.reasonPhrase = 'Method not allowed';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Method not allowed'});
    }
  }

  WidgetJson _options(Session session, HttpRequest request, Device device) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    request.response.headers.add('Allow', 'GET, PUT, DELETE, OPTIONS');
    setHeaders(request.response.headers);
    return WidgetJson(object: {'options': 'GET, PUT, DELETE, OPTIONS'});
  }

  WidgetJson _get(Session session, HttpRequest request, Device device) {
    request.response.statusCode = HttpStatus.ok;
    request.response.headers.contentType = ContentType.json;
    setHeaders(request.response.headers);
    return WidgetJson(object: device.toJson());
  }

  Future<WidgetJson> _put(
      Session session, HttpRequest request, Device device) async {
    try {
      String content = await utf8.decoder.bind(request).join();
      Device newDevice = Device.fromJson(json.decode(content));
      device = device.copyWith(
        type: newDevice.type,
        macAddress: newDevice.macAddress,
        status: newDevice.status,
      );
      device = await DevicesEndpoint().updateDevice(session, device);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: device.toJson());
    } catch (e, s) {
      session.log('Failed to update device: ${device.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to update device';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to update device. $e'});
    }
  }

  Future<WidgetJson> _delete(
      Session session, HttpRequest request, Device device) async {
    try {
      Device? deletedDevice = await DevicesEndpoint().deleteDevice(session, device);
      if(deletedDevice == null){
        session.log('Failed to delete device ${device.macAddress}: not found', level: LogLevel.warning);
        request.response.statusCode = HttpStatus.notFound;
        request.response.reasonPhrase = 'Device ${device.macAddress} not found';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Device ${device.macAddress} not found'});
      }
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: device.toJson());
    } catch (e, s) {
      session.log('Failed to delete device: ${device.macAddress}',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = 'Failed to delete device';
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(object: {'error': 'Failed to delete device. $e'});
    }
  }
}
