import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/mqtt/mqtt_manager.dart';

import 'package:vigiloffice_server/src/web/routes/root.dart';

import 'src/generated/protocol.dart';
import 'src/generated/endpoints.dart';

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

  //TODO: IMPLEMENT WEB SERVER WITH MUSTACHE

  // Setup a default page at the web root.
  pod.webServer.addRoute(RouteRoot(), '/');
  pod.webServer.addRoute(RouteRoot(), '/index.html');
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
