import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/lamps_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/default_page_widget.dart';
import '../widgets/status_not_found_page_widget.dart';
import '../widgets/single_lamp_page_widget.dart';

class SingleLampRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Lamp? lamp = await Lamp.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (lamp == null) {
      session.log('Lamp not found: $macAddress', level: LogLevel.warning);
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.notFound;
      setHeaders(request.response.headers);
      return StatusNotFoundPageWidget(
          type: DeviceType.lamp, macAddress: macAddress);
    }
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.html;
      request.response.headers.set('Allow', 'GET, PUT, DELETE, OPTIONS');
      setHeaders(request.response.headers);
    } else if (request.method == 'PUT') {
      String content = await utf8.decoder.bind(request).join();
      session.log('Received POST request with body: $content',
          level: LogLevel.debug);
      try {
        Lamp lampToUpdate = lamp.fromUrlEncodedParams(content);
        await LampsEndpoint().controlLamp(session, lampToUpdate);
        session.log('Updated lamp: ${lampToUpdate.macAddress}',
            level: LogLevel.debug);
        request.response.statusCode = HttpStatus.ok;
      } catch (e, s) {
        session.log('Failed to update lamp: ${lamp.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
        request.response.statusCode = HttpStatus.badGateway;
      } finally {
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
      }
    } else if (request.method == 'DELETE') {
      try {
        await LampsEndpoint().deleteLamp(session, lamp);
        session.log('Deleted lamp: ${lamp.macAddress}', level: LogLevel.info);
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
        return DefaultPageWidget();
      } catch (e, s) {
        session.log('Failed to delete lamp: ${lamp.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
        request.response.statusCode = HttpStatus.badRequest;
      } finally {
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
      }
    } else if (request.method == 'GET') {
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.ok;
      setHeaders(request.response.headers);
    } else {
      request.response.statusCode = HttpStatus.methodNotAllowed;
      request.response.headers.contentType = ContentType.html;
      setHeaders(request.response.headers);
    }
    return SingleLampPageWidget(lamp: lamp);
  }
}

extension LampUrlParser on Lamp {
  Map<String, dynamic> _paramsMapFromEncodedUrl(String unparsedParams) {
    Map<String, dynamic> params = {};
    unparsedParams = unparsedParams.replaceAll("%3A", ":");
    List<String> paramList = unparsedParams.split("&");
    for (String param in paramList) {
      List<String> keyValue = param.split("=");
      params[keyValue[0]] = keyValue[1];
    }
    return params;
  }

  Lamp fromUrlEncodedParams(String unparsedParams) {
    Map<String, dynamic> params = _paramsMapFromEncodedUrl(unparsedParams);
    return Lamp(
      type: DeviceType.lamp,
      macAddress: params['macAddress'],
      id: int.tryParse(params['id'] ?? ""),
      lastUpdate: params['lastUpdate'] != "null"
          ? DateTime.tryParse(params['lastUpdate'])
          : null,
      flameSensor: FlameSensor(
        enabled: params['flameStatus'] == 'true',
        status: int.parse(params['flameDropdown']),
        value: int.tryParse(params['flameValue'] ?? ""),
        interval: int.parse(params['flameIntervalSliderInput']),
      ),
      lightSensor: LightSensor(
        enabled: params['lightStatus'] == 'true',
        status: int.parse(params['lightDropdown']),
        value: int.tryParse(params['lightValue'] ?? ""),
        interval: int.parse(params['lightIntervalSliderInput']),
        lowThreshold: int.parse(params['lightSliderInput']),
      ),
      motionSensor: MotionSensor(
        enabled: params['motionStatus'] == 'true',
        status: int.parse(params['motionDropdown']),
        value: int.tryParse(params['motionValue'] ?? ""),
      ),
      rgbLed: RGBLed(
        enabled: params['rgbStatus'] == 'true',
        status: int.parse(params['rgbDropdown']),
        value: int.tryParse(params['rgbValue'] ?? ""),
      ),
      alarm: Alarm(
        enabled: params['alarmStatus'] == 'true',
        status: params['alarmDropdown'] == 'true',
      ),
    );
  }
}
