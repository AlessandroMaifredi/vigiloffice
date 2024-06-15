import 'dart:io';

import 'package:serverpod/serverpod.dart';

import '../../endpoints/device_endpoint.dart';
import '../../generated/protocol.dart';
import '../widgets/default_page_widget.dart';
import '../widgets/device_not_found_page_widget.dart';
import '../widgets/single_device_widget.dart';

class SingleDeviceRoute extends WidgetRoute {
  SingleDeviceRoute() : super();

  @override
  Future<Widget> build(Session session, HttpRequest request) async {
    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      request.response.headers.contentType = ContentType.html;
      request.response.headers.set('Allow', 'GET, DELETE, OPTIONS');
      setHeaders(request.response.headers);
    } else {
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.ok;
      setHeaders(request.response.headers);
    }
    String uri = request.uri.toString();
    if (uri.endsWith('/')) {
      uri = uri.substring(0, uri.length - 1);
    }
    String macAddress = uri.split("/").last;
    Device? device = await Device.db
        .findFirstRow(session, where: (o) => o.macAddress.equals(macAddress));
    if (device == null) {
      request.response.headers.contentType = ContentType.html;
      request.response.statusCode = HttpStatus.notFound;
      setHeaders(request.response.headers);
      return DeviceNotFoundPageWidget(macAddress: macAddress);
    }

    if (request.method == 'DELETE') {
      try {
        await DevicesEndpoint().deleteDevice(session, device);
        session.log('Deleted device: ${device.macAddress}',
            level: LogLevel.info);
        request.response.statusCode = HttpStatus.ok;
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
        return DefaultPageWidget();
      } catch (e, s) {
        session.log('Failed to delete device: ${device.macAddress}',
            level: LogLevel.error, exception: e, stackTrace: s);
        request.response.statusCode = HttpStatus.badRequest;
      } finally {
        request.response.headers.contentType = ContentType.html;
        setHeaders(request.response.headers);
      }
    }

    bool statusAvailable = false;
    switch (device.type) {
      case DeviceType.lamp:
        statusAvailable = (await Lamp.db.findFirstRow(session,
                where: (o) => o.macAddress.equals(macAddress))) !=
            null;
        break;
      case DeviceType.hvac:
        statusAvailable = (await Hvac.db.findFirstRow(session,
                where: (o) => o.macAddress.equals(macAddress))) !=
            null;
        break;
      case DeviceType.parking:
        statusAvailable = (await Parking.db.findFirstRow(session,
                where: (o) => o.macAddress.equals(macAddress))) !=
            null;
        break;
    }
    statusAvailable =
        statusAvailable && device.status != DeviceStatus.disconnected;
    return SingleDevicePageWidget(
        device: device, statusAvailable: statusAvailable);
  }
}
