import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/hvacs_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/device_not_found_page_widget.dart';
import '../widgets/single_hvac_page_widget.dart';

class SingleHvacRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String macAddress = request.uri.toString().split("/").last;
    Hvac? hvac = await Hvac.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (hvac == null) {
      session.log('Hvac not found: $macAddress', level: LogLevel.warning);
      return DeviceNotFoundPageWidget(
          type: DeviceType.hvac, macAddress: macAddress);
    }
    if (request.method == 'POST') {
      String content = await utf8.decoder.bind(request).join();
      session.log('Received POST request with body: $content',
          level: LogLevel.debug);
      try {
        Hvac hvacToUpdate = hvac.fromUrlEncodedParams(content);
        await HvacsEndpoint().controlHvac(session, hvacToUpdate);
        session.log('Updated hvac: ${hvacToUpdate.macAddress}',
            level: LogLevel.debug);
      } catch (e, s) {
        session.log('Failed to update hvac: ${hvac.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
      }
    }
    return SingleHvacPageWidget(hvac: hvac);
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
      macAddress: params['macAddress'],
      id: int.tryParse(params['id']),
      lastUpdate: params['lastUpdate'] != "null"
          ? DateTime.tryParse(params['lastUpdate'])
          : null,
      flameSensor: FlameSensor(
        enabled: params['flameStatus'] == 'true',
        status: int.parse(params['flameDropdown']),
        value: int.parse(params['flameValue']),
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