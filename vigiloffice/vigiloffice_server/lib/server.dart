import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/constants.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';
import 'src/mqtt/mqtt_manager.dart';
import 'src/web/routes/devices_route.dart';
import 'src/web/routes/hvacs_route.dart';
import 'src/web/routes/lamps_route.dart';
import 'src/web/routes/root.dart';
import 'src/web/routes/single_hvac_route.dart';
import 'src/web/routes/single_lamp_route.dart';

// This is the starting point of your Serverpod server. In most cases, you will
// only need to make additions to this file if you add future calls,  are
// configuring Relic (Serverpod's web-server), or need custom setup work.

void run(List<String> args) async {
  // Initialize Serverpod and connect it with your generated code.
  for (String arg in args) {
    print(arg);
  }
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
  } catch (e) {
    print('Failed to connect to the broker.');
  }

  // Start the server.
  await pod.start();
}
