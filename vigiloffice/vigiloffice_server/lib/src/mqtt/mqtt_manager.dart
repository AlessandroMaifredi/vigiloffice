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
  static String homeTopic = 'vigiloffice';
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
        "$homeTopic/${DeviceType.lamp}s/${lamp.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  Future<void> _handleLampStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      Lamp lamp = Lamp.fromJson(data);
      lamp.lastUpdate = DateTime.now();
      await _lampsEndpoint.updateLamp(session, lamp);
    } catch (e, s) {
      session.log('Error while handling lamp status: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
    } finally {
      await session.close();
    }
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
        "$homeTopic/${DeviceType.hvac}s/${hvac.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  Future<void> _handleHvacStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      Hvac hvac = Hvac.fromJson(data);
      hvac.lastUpdate = DateTime.now();
      await _hvacEndpoint.updateHvac(session, hvac);
    } catch (e, s) {
      session.log('Error while handling hvac status: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
    } finally {
      await session.close();
    }
  }

// === END HVAC ===

// === PARKING ===
  /// Controls the specified [parking].
  ///
  /// This method sends a control message to the specified [parking] to control its state.
  /// Throws an [Exception] if the MQTT client is not initialized.
  void controlParking(Parking parking) {
    ensureInitialized();
    // Handle the logic to control the parking
    MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
    builder.addString(jsonEncode(parking.toJson()));
    _client!.publishMessage(
        "$homeTopic/${DeviceType.parking}s/${parking.macAddress}/control",
        MqttQos.atLeastOnce,
        builder.payload!);
  }

  Future<void> _handleParkingStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    Map<String, dynamic> data = jsonDecode(payload);
    Parking parking = Parking.fromJson(data);
    parking.lastUpdate = DateTime.now();
    await _parkingEndopoint.updateParking(session, parking);
    await session.close();
  }

// === END PARKING ===

  Future<void> _handleRegisterMessage(String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      Device device =
          await _deviceEndpoint.updateDevice(session, Device.fromJson(data));
      session.log("Device registered: ${device.id} (${device.macAddress})");
      String msg = jsonEncode({
        "statusTopic": "$homeTopic/${device.type}s/${device.macAddress}/status",
        "controlTopic":
            "$homeTopic/${device.type}s/${device.macAddress}/control"
      });
      MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(msg);
      _client!.publishMessage("$homeTopic/register/${device.macAddress}",
          MqttQos.exactlyOnce, builder.payload!);
    } catch (e, s) {
      session.log('Error while handling register message: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
    } finally {
      await session.close();
    }
  }

  Future<void> _handleLwtMessage(String topic, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    if (payload.isEmpty) {
      session.log("LWT from $topic skipped.", level: LogLevel.info);
      await session.close();
      return;
    }
    try {
      Map<String, dynamic> data = jsonDecode(payload);
      DeviceType type = DeviceType.fromJson(data['type']);
      Device device = Device(
          macAddress: data['macAddress'],
          type: type,
          status: DeviceStatus.disconnected);
      switch (type) {
        case DeviceType.lamp:
          await _handleLampStatus(data['macAddress'], payload);
          break;
        case DeviceType.hvac:
          await _handleHvacStatus(data['macAddress'], payload);
          break;
        case DeviceType.parking:
          await _handleParkingStatus(data['macAddress'], payload);
          break;
      }
      device = await _deviceEndpoint.updateDevice(session, device);
      session.log("Device LWT: ${device.id} (${device.macAddress})");
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString("");
      try {
        _client!.publishMessage(topic, MqttQos.atLeastOnce, builder.payload!,
            retain: true);
      } catch (e) {
        session.log(
          "Retain message removed for topic: $topic.",
          level: LogLevel.info,
        );
      }
    } catch (e, s) {
      session.log('Error while handling LWT message: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
    } finally {
      await session.close();
    }
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
        "registerTopic": "$homeTopic/register",
      };
      final MqttClientPayloadBuilder builder = MqttClientPayloadBuilder();
      builder.addString(jsonEncode(welcomeMessage));
      _client!.publishMessage(
          "$homeTopic/welcome", MqttQos.atLeastOnce, builder.payload!,
          retain: true);

      session.log("Welcome message published.");
    } catch (e, s) {
      session.log('Error: $e',
          level: LogLevel.error, exception: e, stackTrace: s);
      throw MqttManagerException(message: e.toString());
    } finally {
      await session.close();
    }
  }

  void _setupConnection() {
    _client!.subscribe("$homeTopic/register", MqttQos.atLeastOnce);
    _client!.subscribe("$homeTopic/register/#", MqttQos.atLeastOnce);
    _client!.subscribe("$homeTopic/lwt/#", MqttQos.atLeastOnce);

    for (DeviceType type in DeviceType.values) {
      _client!
          .subscribe("$homeTopic/${type.name}s/+/status", MqttQos.atMostOnce);
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
          if (topic == '$homeTopic/welcome') {
            msgSession.log('Received welcome message: $payload');
          } else if (topic == "$homeTopic/register") {
            msgSession.log('Received generic register message: $payload');
            await _handleRegisterMessage(payload);
          } else if (topic.startsWith("$homeTopic/register/")) {
            final String macAddress = paths[2];
            msgSession.log(
                'Received device ($macAddress) register message: $payload');
          } else if (topic.startsWith("$homeTopic/lwt/")) {
            msgSession.log('Received LWT message: $payload');
            await _handleLwtMessage(topic, payload);
          } else if (topic.endsWith("/status")) {
            msgSession.log('Received status message: $payload');
            DeviceType type =
                DeviceType.fromJson(paths[1].substring(0, paths[1].length - 1));
            String macAddress = paths[2];
            switch (type) {
              case DeviceType.lamp:
                await _handleLampStatus(macAddress, payload);
                break;
              case DeviceType.hvac:
                await _handleHvacStatus(macAddress, payload);
                break;
              case DeviceType.parking:
                await _handleParkingStatus(macAddress, payload);
            }
          } else {
            // Handle unknown topic
            print('Unknown topic: $topic');
          }
        }
      } catch (e, s) {
        msgSession.log('Error: $e',
            level: LogLevel.error, exception: e, stackTrace: s);
        throw MqttManagerException(message: e.toString());
      } finally {
        await msgSession.close();
      }
    });
  }

  /// Handles the logic when a subscription fails.
  void _onSubscribeFail(String topic) async {
    Session session = await Serverpod.instance.createSession();
    session.log("Failed to subscribe to topic: $topic");
    await session.close();
  }

  /// Handles the logic when the client successfully reconnects.
  void _onAutoReconnected() {
    _setupConnection();
  }
}
