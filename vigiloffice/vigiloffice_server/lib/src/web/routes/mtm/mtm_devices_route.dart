import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../../endpoints/device_endpoint.dart';
import '../../../generated/protocol.dart';
import '../../widgets/devices_page_widget.dart';
import 'semantic_helper.dart';

class JsonDevicesRoute extends WidgetRoute {
  final DeviceType? type;

  final bool isSemantic;

  JsonDevicesRoute({this.type, this.isSemantic = false}) : super();

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
    List<Device> devices = await Device.db.find(session, where: (o) {
      if (type == null) return o.macAddress.notEquals("");
      return o.type.equals(type);
    });
    session.log('Found ${devices.length} devices.', level: LogLevel.debug);
    request.response.headers.contentType = ContentType.json;
    request.response.statusCode = HttpStatus.ok;
    setHeaders(request.response.headers);
    return JsonDevicesWidget(devices: devices, isSemantic: isSemantic);
  }

  Future<WidgetJson> _post(Session session, HttpRequest request) async {
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
    String content = await utf8.decoder.bind(request).join();
    session.log('MTM | Received POST request with body: $content',
        level: LogLevel.debug);
    try {
      DevicesEndpoint endpoint = DevicesEndpoint();
      Device device = Device.fromJson(json.decode(content));
      if ((await endpoint.readDevice(session, device)) != null) {
        request.response.statusCode = HttpStatus.conflict;
        request.response.reasonPhrase = 'Device already exists.';
        request.response.headers.contentType = ContentType.json;
        setHeaders(request.response.headers);
        return WidgetJson(object: {'error': 'Device already exists.'});
      }
      device = await endpoint.createDevice(session, device);
      session.log('MTM | Device created: ${device.macAddress}',
          level: LogLevel.debug);
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      if(isSemantic) return WidgetJson(object: transformBasicInfoJsonToWoT(device.toJson()));
      return WidgetJson(object: device.toJson());
    } catch (e, s) {
      session.log('MTM | Failed to create device',
          level: LogLevel.error, exception: e, stackTrace: s);
      request.response.statusCode = HttpStatus.badRequest;
      request.response.reasonPhrase = e.toString();
      request.response.headers.contentType = ContentType.json;
      setHeaders(request.response.headers);
      return WidgetJson(
          object: {'error': 'Failed to create device. ${e.toString()}'});
    }
  }
}
