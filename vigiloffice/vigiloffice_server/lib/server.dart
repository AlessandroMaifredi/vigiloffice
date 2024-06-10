import 'package:serverpod/serverpod.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/mqtt/mqtt_manager.dart';
import 'src/web/routes/devices_route.dart';
import 'src/web/routes/hvacs_route.dart';
import 'src/web/routes/lamps_route.dart';
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
  // If you are using any future calls, they need to be registered here.
  // pod.registerFutureCall(ExampleFutureCall(), 'exampleFutureCall');

  //TODO: IMPLEMENT MTM API
  //pod.webServer.addRoute(JsonDevicesRoot(), '$mtmPrefix/devices');
  //pod.webServer.addRoute(JsonDevicesRoot(), '$mtmPrefix/devices/');

  // Setup a default page at the web root.
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
      case DeviceType.hvac:
        singleRoute = SingleHvacRoute();
        listRoute = HvacsRoute();
      case DeviceType.parking:
        singleRoute = SingleParkingRoute();
        listRoute = ParkingsRoute();
    }
    pod.webServer.addRoute(listRoute, '/devices/${type.name}s');
    pod.webServer.addRoute(listRoute, '/devices/${type.name}s/');
    pod.webServer.addRoute(singleRoute, '/devices/${type.name}s/*');
  }
  // Serve all files in the /static directory.
  pod.webServer.addRoute(
    RouteStaticDirectory(serverDirectory: 'static', basePath: '/'),
    '/*',
  );

  try {
    await mqttManager.connect(
        pod.getPassword('mqttUsername')!, pod.getPassword('mqttPassword')!);
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
