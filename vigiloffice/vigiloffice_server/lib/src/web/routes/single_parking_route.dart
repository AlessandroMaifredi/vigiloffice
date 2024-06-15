import 'dart:convert';
import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/parkings_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/default_page_widget.dart';
import '../widgets/status_not_found_page_widget.dart';
import '../widgets/single_parking_page_widget.dart';

class SingleParkingRoute extends WidgetRoute {
  @override
  Future<AbstractWidget> build(Session session, HttpRequest request) async {
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Parking? parking = await Parking.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (parking == null) {
      session.log('Parking not found: $macAddress', level: LogLevel.warning);
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.notFound;
      setHeaders(request.response.headers);
      return StatusNotFoundPageWidget(
          type: DeviceType.parking, macAddress: macAddress);
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
        Parking parkingToUpdate = parking.fromUrlEncodedParams(content);
        await ParkingsEndpoint().controlParking(session, parkingToUpdate);
        session.log('Updated parking: ${parkingToUpdate.macAddress}',
            level: LogLevel.debug);
        request.response.statusCode = HttpStatus.ok;
      } catch (e, s) {
        session.log('Failed to update parking: ${parking.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
        request.response.statusCode = HttpStatus.badRequest;
      } finally {
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
      }
    } else if (request.method == 'DELETE') {
      try {
        await ParkingsEndpoint().deleteParking(session, parking);
        session.log('Deleted parking: ${parking.macAddress}',
            level: LogLevel.info);
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
        return DefaultPageWidget();
      } catch (e, s) {
        session.log('Failed to delete parking: ${parking.macAddress}',
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
                where: (o) => o.macAddress.equals(parking.macAddress)))
            ?.status ??
        DeviceStatus.disconnected;
    return SingleParkingPageWidget(
        parking: parking, deviceStatus: deviceStatus);
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
      type: DeviceType.parking,
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
