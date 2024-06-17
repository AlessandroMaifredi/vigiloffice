import 'package:serverpod/serverpod.dart';

import 'src/constants.dart';
import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/influxdb/influxdb_manager.dart';
import 'src/mqtt/mqtt_manager.dart';
import 'src/telegram/telegram_manager.dart';
import 'src/web/routes/devices_route.dart';
import 'src/web/routes/hvacs_route.dart';
import 'src/web/routes/lamps_route.dart';
import 'src/web/routes/mtm/mtm_devices_route.dart';
import 'src/web/routes/mtm/mtm_hvacs_route.dart';
import 'src/web/routes/mtm/mtm_lamps_route.dart';
import 'src/web/routes/mtm/mtm_parkings_route.dart';
import 'src/web/routes/mtm/mtm_single_device_route.dart';
import 'src/web/routes/mtm/mtm_single_hvac_route.dart';
import 'src/web/routes/mtm/mtm_single_lamp_route.dart';
import 'src/web/routes/mtm/mtm_single_parking_route.dart';
import 'src/web/routes/mtm/mtm_status_route.dart';
import 'src/web/routes/parkings_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/routes/single_device_route.dart';
import 'src/web/routes/single_hvac_route.dart';
import 'src/web/routes/single_lamp_route.dart';
import 'src/web/routes/single_parking_route.dart';
import 'src/web/routes/status_route.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  final pod = Serverpod(
    args,
    Protocol(),
    Endpoints(),
  );

  final MqttManager mqttManager = MqttManager();

  final InfluxDBManager influxDBManager = InfluxDBManager();

  final TelegramManager telegramManager = TelegramManager();

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  // Machine to machine (MTM) routes.

  // Devices routes
  pod.webServer.addRoute(JsonDevicesRoute(), '$mtmPrefix/devices');
  pod.webServer.addRoute(JsonDevicesRoute(), '$mtmPrefix/devices/');
  pod.webServer.addRoute(JsonStatusRoute(), '$mtmPrefix/status');
  pod.webServer.addRoute(JsonStatusRoute(), '$mtmPrefix/status/');

  pod.webServer
      .addRoute(JsonDevicesRoute(isSemantic: true), '$wotPrefix/devices');
  pod.webServer
      .addRoute(JsonDevicesRoute(isSemantic: true), '$wotPrefix/devices/');
  pod.webServer
      .addRoute(JsonStatusRoute(isSemantic: true), '$wotPrefix/status');
  pod.webServer
      .addRoute(JsonStatusRoute(isSemantic: true), '$wotPrefix/status/');

  for (DeviceType type in DeviceType.values) {
    WidgetRoute statusListRoute = JsonDevicesRoute();
    WidgetRoute singleRoute = JsonDevicesRoute();
    WidgetRoute wotStatusListRoute = JsonDevicesRoute(isSemantic: true);
    WidgetRoute wotSingleRoute = JsonDevicesRoute(isSemantic: true);
    switch (type) {
      case DeviceType.lamp:
        singleRoute = JsonSingleLampRoute();
        statusListRoute = JsonLampsRoute();
        wotSingleRoute = JsonSingleLampRoute(isSemantic: true);
        wotStatusListRoute = JsonLampsRoute(isSemantic: true);
        break;
      case DeviceType.hvac:
        singleRoute = JsonSingleHvacRoute();
        statusListRoute = JsonHvacsRoute();
        wotSingleRoute = JsonSingleHvacRoute(isSemantic: true);
        wotStatusListRoute = JsonHvacsRoute(isSemantic: true);
        break;
      case DeviceType.parking:
        singleRoute = JsonSingleParkingRoute();
        statusListRoute = JsonParkingsRoute();
        wotSingleRoute = JsonSingleParkingRoute(isSemantic: true);
        wotStatusListRoute = JsonParkingsRoute(isSemantic: true);
        break;
    }
    pod.webServer.addRoute(statusListRoute, '$mtmPrefix/status/${type.name}s');
    pod.webServer
        .addRoute(wotStatusListRoute, '$wotPrefix/status/${type.name}s');

    pod.webServer.addRoute(statusListRoute, '$mtmPrefix/status/${type.name}s/');
    pod.webServer
        .addRoute(wotStatusListRoute, '$wotPrefix/status/${type.name}s/');

    pod.webServer.addRoute(singleRoute, '$mtmPrefix/status/${type.name}s/*');
    pod.webServer.addRoute(wotSingleRoute, '$wotPrefix/status/${type.name}s/*');

    pod.webServer.addRoute(
        JsonDevicesRoute(type: type), '$mtmPrefix/devices/${type.name}s');
    pod.webServer.addRoute(JsonDevicesRoute(type: type, isSemantic: true),
        '$wotPrefix/devices/${type.name}s');

    pod.webServer.addRoute(
        JsonDevicesRoute(type: type), '$mtmPrefix/devices/${type.name}s/');
    pod.webServer.addRoute(JsonDevicesRoute(type: type, isSemantic: true),
        '$wotPrefix/devices/${type.name}s/');

    pod.webServer.addRoute(
        JsonSingleDeviceRoute(), '$mtmPrefix/devices/${type.name}s/*');
    pod.webServer.addRoute(JsonSingleDeviceRoute(isSemantic: true),
        '$wotPrefix/devices/${type.name}s/*');
  }

  // Human to machine (HTM) routes.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  pod.webServer.addRoute(DevicesRoute(), '/devices/');
  pod.webServer.addRoute(DevicesRoute(), '/devices');
  pod.webServer.addRoute(StatusRoute(), '/status');
  pod.webServer.addRoute(StatusRoute(), '/status/');
  for (DeviceType type in DeviceType.values) {
    WidgetRoute listRoute = DevicesRoute();
    WidgetRoute singleRoute = DevicesRoute();
    switch (type) {
      case DeviceType.lamp:
        singleRoute = SingleLampRoute();
        listRoute = LampsRoute();
        break;
      case DeviceType.hvac:
        singleRoute = SingleHvacRoute();
        listRoute = HvacsRoute();
        break;
      case DeviceType.parking:
        singleRoute = SingleParkingRoute();
        listRoute = ParkingsRoute();
        break;
    }
    pod.webServer.addRoute(listRoute, '/status/${type.name}s');
    pod.webServer.addRoute(listRoute, '/status/${type.name}s/');
    pod.webServer.addRoute(singleRoute, '/status/${type.name}s/*');
    pod.webServer.addRoute(DevicesRoute(type: type), '/devices/${type.name}s');
    pod.webServer.addRoute(DevicesRoute(type: type), '/devices/${type.name}s/');
    pod.webServer.addRoute(SingleDeviceRoute(), '/devices/${type.name}s/*');
  }
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  try {
    await mqttManager.connect(
        pod.getPassword('mqttUsername')!, pod.getPassword('mqttPassword')!);
    try {
      await influxDBManager.connect(InfluxDBConnectionParameters(
        url: pod.getPassword('influxDbUrl')!,
        token: pod.getPassword('influxDbToken')!,
        org: pod.getPassword('influxDbOrg')!,
        bucket: pod.getPassword('influxDbBucket')!,
      ));
    } catch (e, s) {
      Session session = await pod.createSession();
      session.log('Failed to connect to InfluxDB: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      await session.close();
    }
    try {
      telegramManager.init(pod.getPassword('telegramBotToken')!);
    } on TelegramManagerException catch (e, s) {
      Session session = await pod.createSession();
      session.log('Failed to init Telegram bot: ${e.message}',
          stackTrace: s, level: LogLevel.error);
      await session.close();
    } catch (e, s) {
      Session session = await pod.createSession();
      session.log('Failed to init Telegram bot: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      await session.close();
    }
    // Start the server.
    await pod.start();
  } catch (e, s) {
    Session session = await pod.createSession();
    session.log("MQTT connection failed",
        exception: e, level: LogLevel.fatal, stackTrace: s);
    await session.close();
    await pod.shutdown();
  }
}
