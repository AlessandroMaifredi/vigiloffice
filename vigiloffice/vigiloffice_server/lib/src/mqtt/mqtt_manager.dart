import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/endpoints/device_endpoint.dart';
import 'package:vigiloffice_server/src/endpoints/lamps_endpoint.dart';

import '../endpoints/parkings_endpoint.dart';
import '../endpoints/hvacs_endpoint.dart';
import '../generated/protocol.dart';

/// A class that manages the MQTT connection and provides methods to handle events.
///
/// This class is responsible for establishing and maintaining the MQTT connection,
/// as well as handling various events related to the MQTT communication.
///
/// Example usage:
/// ```dart
/// MqttManager mqttManager = MqttManager();
/// mqttManager.connect();
/// ```
class MqttManager {
  static final MqttManager _instance = MqttManager._internal();
  factory MqttManager() => _instance;

  MqttServerClient? _client;
  static final String _brokerUrl = '149.132.178.179';
  static final String _clientId = 'serverpod';
  static final int maxReconnectAttempts = 5;
  int timesConnected = 0;
  static final LampsEndpoint _lampsEndpoint = LampsEndpoint();
  static final HvacsEndpoint _hvacEndpoint = HvacsEndpoint();
  static final ParkingsEndpoint _parkingEndopoint = ParkingsEndpoint();
  static final DevicesEndpoint _deviceEndpoint = DevicesEndpoint();

  MqttManager._internal();

  /// Ensures that the MQTT client is initialized.
  void ensureInitialized() {
    if (_client == null) {
      throw Exception('The MQTT client is not initialized.');
    }
  }

  /// Connects to the MQTT broker using the provided [username] and [password].
  ///
  /// This method establishes a connection to the MQTT broker using the specified
  /// [username] and [password]. It allows the client to authenticate with the
  /// broker and gain access to the MQTT services.
  ///
  /// Example usage:
  /// ```dart
  /// MqttManager mqttManager = MqttManager();
  /// mqttManager.connect(username: 'myUsername', password: 'myPassword');
  /// ```
  ///
  /// Throws an [MqttException] if the connection fails.
  Future<void> connect(String username, String password) async {
    try {
      if (_client != null &&
          _client?.connectionStatus != null &&
          _client!.connectionStatus!.state == MqttConnectionState.connected) {
        return;
      }
      _client = _client ?? MqttServerClient(_brokerUrl, _clientId);
      _client!.logging(on: false);
      _client!.onConnected = _onConnected;
      _client!.onSubscribeFail = _onSubscribeFail;
      _client!.onAutoReconnected = _onAutoReconnected;
      _client!.autoReconnect = true;

      try {
        await _client!.connect(username, password);
      } catch (e) {
        timesConnected++;
        if (timesConnected < maxReconnectAttempts) {
          await connect(username, password);
        } else {
          rethrow;
        }
      }
    } catch (e) {
      throw MqttManagerException(message: e.toString());
    }
  }

// === LAMP ===

  /// Controls the specified [lamp].
  ///
  /// This method sends a control message to the specified [lamp] to control its state.
  /// Throws an [Exception] if the MQTT client is not initialized.
  void controlLamp(Lamp lamp) {
    ensureInitialized();
    // Handle the logic to control the lamp
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(lamp.toJson()));
    _client!.publishMessage(
        "vigiloffice/${DeviceType.lamp}s/${lamp.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  void _handleLampStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    Map<String, dynamic> data = jsonDecode(payload);
    Lamp lamp = Lamp.fromJson(data);
    lamp.lastUpdate = DateTime.now();
    await _lampsEndpoint.updateLamp(session, lamp);
    session.close();
  }

//=== END LAMP ===

// === HVAC ===
  /// Controls the specified [hvac].
  ///
  /// This method sends a control message to the specified [hvac] to control its state.
  /// Throws an [Exception] if the MQTT client is not initialized.
  void controlHvac(Hvac hvac) {
    ensureInitialized();
    // Handle the logic to control the hvac
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(hvac.toJson()));
    _client!.publishMessage(
        "vigiloffice/${DeviceType.hvac}s/${hvac.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  void _handleHvacStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    Map<String, dynamic> data = jsonDecode(payload);
    Hvac hvac = Hvac.fromJson(data);
    hvac.lastUpdate = DateTime.now();
    await _hvacEndpoint.updateHvac(session, hvac);
    session.close();
  }

// === END HVAC ===

// === PARKING ===
  /// Controls the specified [parking].
  ///
  /// This method sends a control message to the specified [parking] to control its state.
  /// Throws an [Exception] if the MQTT client is not initialized.
  void controlParking(Parking parking) {
    ensureInitialized();
    // Handle the logic to control the hvac
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(parking.toJson()));
    _client!.publishMessage(
        "vigiloffice/${DeviceType.hvac}s/${parking.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  void _handleParkingStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    Map<String, dynamic> data = jsonDecode(payload);
    Parking parking = Parking.fromJson(data);
    parking.lastUpdate = DateTime.now();
    await _parkingEndopoint.updateParking(session, parking);
    session.close();
  }

// === END PARKING ===

  void _handleRegisterMessage(String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    Map<String, dynamic> data = jsonDecode(payload);
    Device device =
        await _deviceEndpoint.updateDevice(session, Device.fromJson(data));
    session.log("Device registered: ${device.id} (${device.macAddress})");
    session.close();
    String msg = jsonEncode({
      "statusTopic": "vigiloffice/${device.type}s/${device.macAddress}/status",
      "controlTopic": "vigiloffice/${device.type}s/${device.macAddress}/control"
    });
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(msg);
    _client!.publishMessage("vigiloffice/register/${device.macAddress}",
        MqttQos.atLeastOnce, builder.payload!);
    /* _client!.subscribe(
        "vigiloffice/${device.type}s/${device.macAddress}/status",
        MqttQos.atLeastOnce);
        */
  }

  /// Handles the logic when the connection to the broker is established.
  void _onConnected() async {
    InternalSession session = await Serverpod.instance.createSession();
    // Handle the logic when the connection to the broker is established
    try {
      session.log('Connected to the MQTT broker.');

      _setupConnection();
      session.log("Subscribed to topics");

      //TODO: move message configuration to a dedicated endpoint
      final Map<String, dynamic> welcomeMessage = {
        "apiServer":
            "${Serverpod.instance.config.apiServer.publicHost}:${Serverpod.instance.config.apiServer.publicPort}",
        "webServer":
            "${Serverpod.instance.config.webServer!.publicHost}:${Serverpod.instance.config.webServer!.publicPort}",
        "registerTopic": "vigiloffice/register",
      };
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(welcomeMessage));
      _client!.publishMessage(
          "vigiloffice/welcome", MqttQos.atLeastOnce, builder.payload!,
          retain: true);

      session.log("Welcome message published.");

      session.close();
    } catch (e, s) {
      session.log('Error: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      throw MqttManagerException(message: e.toString());
    }
  }

  void _setupConnection() {
    _client!.subscribe("vigiloffice/register", MqttQos.atLeastOnce);
    _client!.subscribe("vigiloffice/register/#", MqttQos.atLeastOnce);

    for (DeviceType type in DeviceType.values) {
      _client!
          .subscribe("vigiloffice/${type.name}s/+/status", MqttQos.atLeastOnce);
    }

    _client!.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      InternalSession msgSession = await Serverpod.instance.createSession();
      try {
        for (MqttReceivedMessage<MqttMessage> message in messages) {
          final MqttPublishMessage receivedMessage =
              message.payload as MqttPublishMessage;
          final String topic = message.topic;
          final String payload = MqttPublishPayload.bytesToStringAsString(
              receivedMessage.payload.message);
          final List<String> paths = topic.split('/');

          // Handle the incoming message logic here
          if (topic == 'vigiloffice/welcome') {
            msgSession.log('Received welcome message: $payload');
          } else if (topic == "vigiloffice/register") {
            msgSession.log('Received generic register message: $payload');
            _handleRegisterMessage(payload);
          } else if (topic.startsWith("vigiloffice/register/")) {
            final String macAddress = paths[2];
            msgSession.log(
                'Received device ($macAddress) register message: $payload');
          } else if (topic.endsWith("/status")) {
            msgSession.log('Received status message: $payload');
            DeviceType type =
                DeviceType.fromJson(paths[1].substring(0, paths[1].length - 1));
            String macAddress = paths[2];
            switch (type) {
              case DeviceType.lamp:
                _handleLampStatus(macAddress, payload);
                break;
              case DeviceType.hvac:
                _handleHvacStatus(macAddress, payload);
                break;
              case DeviceType.parking:
                _handleParkingStatus(macAddress, payload);
            }
          } else {
            // Handle unknown topic
            print('Unknown topic: $topic');
          }
        }
        msgSession.close();
      } catch (e, s) {
        msgSession.log('Error: $e',
            level: LogLevel.error, exception: e, stackTrace: s);
        throw MqttManagerException(message: e.toString());
      }
    });
  }

  /// Handles the logic when a subscription fails.
  void _onSubscribeFail(String topic) async {
    Serverpod.instance.createSession().then((session) {
      session.log("Failed to subscribe to topic: $topic");
      session.close();
    });
  }

  /// Handles the logic when the client successfully reconnects.
  void _onAutoReconnected() {
    _setupConnection();
  }
}
