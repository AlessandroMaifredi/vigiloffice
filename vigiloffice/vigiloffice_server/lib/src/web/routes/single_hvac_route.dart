import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/hvacs_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/default_page_widget.dart';
import '../widgets/single_hvac_page_widget.dart';
import '../widgets/status_not_found_page_widget.dart';

class SingleHvacRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Hvac? hvac = await Hvac.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (hvac == null) {
      session.log('Hvac not found: $macAddress', level: LogLevel.warning);
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.notFound;
      setHeaders(request.response.headers);
      return StatusNotFoundPageWidget(
          type: DeviceType.hvac, macAddress: macAddress);
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
        Hvac hvacToUpdate = hvac.fromUrlEncodedParams(content);
        await HvacsEndpoint().controlHvac(session, hvacToUpdate);
        session.log('Updated hvac: ${hvacToUpdate.macAddress}',
            level: LogLevel.debug);
        request.response.statusCode = HttpStatus.ok;
      } catch (e, s) {
        session.log('Failed to update hvac: ${hvac.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
        request.response.statusCode = HttpStatus.badRequest;
      } finally {
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
      }
    } else if (request.method == 'DELETE') {
      try {
        await HvacsEndpoint().deleteHvac(session, hvac);
        session.log('Deleted hvac: ${hvac.macAddress}', level: LogLevel.info);
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
        return DefaultPageWidget();
      } catch (e, s) {
        session.log('Failed to delete hvac: ${hvac.macAddress}',
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
    DeviceStatus deviceStatus = (await Device.db.findFirstRow(session,
                where: (o) => o.macAddress.equals(hvac.macAddress)))
            ?.status ??
        DeviceStatus.disconnected;
    return SingleHvacPageWidget(hvac: hvac, deviceStatus: deviceStatus);
  }
}

extension HvacUrlParser on Hvac {
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

  Hvac fromUrlEncodedParams(String unparsedParams) {
    Map<String, dynamic> params = _paramsMapFromEncodedUrl(unparsedParams);
    return Hvac(
      type: DeviceType.hvac,
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
      alarm: Alarm(
        enabled: params['alarmStatus'] == 'true',
        status: params['alarmDropdown'] == 'true',
      ),
      tempSensor: TempSensor(
        enabled: params['tempStatus'] == 'true',
        status: int.parse(params['tempDropdown']),
        tempValue: int.parse(params['tempValue']),
        humValue: int.parse(params['humValue']),
        interval: int.parse(params['tempIntervalSliderInput']),
        lowThreshold: int.parse(params['tempLowThresholdSliderInput']),
        highThreshold: int.parse(params['tempHighThresholdSliderInput']),
        target: int.parse(params['tempTargetSliderInput']),
      ),
      ventActuator: VentActuator(
        enabled: params['ventStatus'] == 'true',
      ),
    );
  }
}
