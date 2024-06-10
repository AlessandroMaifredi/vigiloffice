import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/influxdb/influxdb_manager.dart';
import 'package:vigiloffice_server/src/web/routes/mtm/mtm_devices_route.dart';
import 'package:vigiloffice_server/src/web/routes/mtm/mtm_hvacs_route.dart';

import 'src/constants.dart';
import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/mqtt/mqtt_manager.dart';
import 'src/web/routes/devices_route.dart';
import 'src/web/routes/hvacs_route.dart';
import 'src/web/routes/lamps_route.dart';
import 'src/web/routes/mtm/mtm_lamps_route.dart';
import 'src/web/routes/mtm/mtm_parkings_route.dart';
import 'src/web/routes/mtm/mtm_single_hvac_route.dart';
import 'src/web/routes/mtm/mtm_single_lamp_route.dart';
import 'src/web/routes/mtm/mtm_single_parking_route.dart';
import 'src/web/routes/parkings_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/routes/single_hvac_route.dart';
import 'src/web/routes/single_lamp_route.dart';
import 'src/web/routes/single_parking_route.dart';

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

  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  // Machine to machine (MTM) routes.

  // Devices routes
  pod.webServer.addRoute(JsonDevicesRoute(), '$mtmPrefix/devices');
  pod.webServer.addRoute(JsonDevicesRoute(), '$mtmPrefix/devices/');
  for (DeviceType type in DeviceType.values) {
    WidgetRoute statusListRoute = JsonDevicesRoute();
    WidgetRoute singleRoute = JsonDevicesRoute();
    switch (type) {
      case DeviceType.lamp:
        singleRoute = JsonSingleLampRoute();
        statusListRoute = JsonLampsRoute();
        break;
      case DeviceType.hvac:
        singleRoute = JsonSingleHvacRoute();
        statusListRoute = JsonHvacsRoute();
        break;
      case DeviceType.parking:
        singleRoute = JsonSingleParkingRoute();
        statusListRoute = JsonParkingsRoute();
        break;
    }
    pod.webServer.addRoute(statusListRoute, '$mtmPrefix/status/${type.name}s');
    pod.webServer.addRoute(statusListRoute, '$mtmPrefix/status/${type.name}s/');
    pod.webServer.addRoute(singleRoute, '$mtmPrefix/status/${type.name}s/*');
    pod.webServer.addRoute(
        JsonDevicesRoute(type: type), '$mtmPrefix/devices/${type.name}s');
    pod.webServer.addRoute(
        JsonDevicesRoute(type: type), '$mtmPrefix/devices/${type.name}s/');
  }

  // Human to machine (HTM) routes.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
  pod.webServer.addRoute(DevicesRoute(), '/devices/');
  pod.webServer.addRoute(DevicesRoute(), '/devices');
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
  }
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  try {
    await mqttManager.connect(
        pod.getPassword('mqttUsername')!, pod.getPassword('mqttPassword')!);
    try{
    await influxDBManager.connect(InfluxDBConnectionParameters(
      url: pod.getPassword('influxDbUrl')!,
      token: pod.getPassword('influxDbToken')!,
      org: pod.getPassword('influxDbOrg')!,
      bucket: pod.getPassword('influxDbBucket')!,
    ));
    } catch (e, s) {
      pod.createSession().then((value) async {
        value.log('Failed to connect to InfluxDB: $e',
            level: LogLevel.error, exception: e, stackTrace: s);
        await value.close();
      });
    }
    // Start the server.
    await pod.start();
  } catch (e, s) {
    pod.createSession().then((value) async {
      value.log("MQTT connection failed",
          exception: e, level: LogLevel.fatal, stackTrace: s);
      await value.close();
      await pod.shutdown();
    });
  }
}
