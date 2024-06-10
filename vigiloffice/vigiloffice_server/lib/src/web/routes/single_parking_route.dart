import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/endpoints/device_endpoint.dart';
import 'package:vigiloffice_server/src/web/widgets/default_page_widget.dart';

import '../../endpoints/parkings_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/device_not_found_page_widget.dart';
import '../widgets/single_parking_page_widget.dart';

class SingleParkingRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String macAddress = request.uri.toString().split("/").last;
    Parking? parking = await Parking.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (parking == null) {
      session.log('Parking not found: $macAddress', level: LogLevel.warning);
      return DeviceNotFoundPageWidget(
          type: DeviceType.parking, macAddress: macAddress);
    }
    if (request.method == 'POST') {
      String content = await utf8.decoder.bind(request).join();
      session.log('Received POST request with body: $content',
          level: LogLevel.debug);
      try {
        Parking parkingToUpdate = parking.fromUrlEncodedParams(content);
        await ParkingsEndpoint().controlParking(session, parkingToUpdate);
        session.log('Updated parking: ${parkingToUpdate.macAddress}',
            level: LogLevel.debug);
      } catch (e, s) {
        session.log('Failed to update parking: ${parking.macAddress}',
            level: LogLevel.error,
            exception: e,
            stackTrace: s);
      }
    } else if (request.method == 'DELETE') {
      await DevicesEndpoint().deleteDevice(
          session, Device(type: DeviceType.parking, macAddress: macAddress));
      await ParkingsEndpoint().deleteParking(session, parking);
      session.log('Deleted parking: ${parking.macAddress}',
          level: LogLevel.info);
      return DefaultPageWidget();
    }
    return SingleParkingPageWidget(parking: parking);
  }
}

extension ParkingUrlParser on Parking {
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

  Parking fromUrlEncodedParams(String unparsedParams) {
    Map<String, dynamic> params = _paramsMapFromEncodedUrl(unparsedParams);
    return Parking(
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
      rgbLed: RGBLed(
        enabled: params['rgbStatus'] == 'true',
        status: int.parse(params['rgbDropdown']),
        value: int.tryParse(params['rgbValue'] ?? ""),
      ),
      floodingSensor: FloodingSensor(
        enabled: params['floodingStatus'] == 'true',
        status: int.parse(params['floodingDropdown']),
        interval: int.parse(params['floodingIntervalSliderInput']),
        highThreshold: int.parse(params['floodingSliderInput']),
      ),
      avoidanceSensor: AvoidanceSensor(
        enabled: params['avoidanceStatus'] == 'true',
        status: int.parse(params['avoidanceDropdown']),
      ),
      alarm: Alarm(
        enabled: params['alarmStatus'] == 'true',
        status: params['alarmDropdown'] == 'true',
      ),
    );
  }
}
