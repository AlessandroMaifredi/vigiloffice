import 'dart:convert';

import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'package:serverpod/serverpod.dart';
import 'package:vigiloffice_server/src/endpoints/lamps_endpoint.dart';

import '../generated/protocol.dart';

/// A class that manages the MQTT connection and provides methods to handle events.
class MqttManager {
  final MqttServerClient _client;
  static final String _brokerUrl = '149.132.178.179';
  static final String _clientId = 'serverpod';
  static final int maxReconnectAttempts = 5;
  int timesConnected = 0;

  /// Creates a new instance of the [MqttManager] class.
  ///
  /// The [username] and [password] are used to authenticate with the MQTT broker.
  MqttManager(String username, String password)
      : _client = MqttServerClient(_brokerUrl, _clientId) {
    _connect(username, password);
  }

  /// Connects to the MQTT broker using the provided [username] and [password].
  Future<void> _connect(String username, String password) async {
    _client.logging(on: false);
    _client.onConnected = _onConnected;
    _client.onDisconnected = _onDisconnected;
    _client.onSubscribed = _onSubscribed;
    _client.onSubscribeFail = _onSubscribeFail;
    _client.onAutoReconnect = _onAutoReconnect;
    _client.onAutoReconnected = _onAutoReconnected;
    _client.autoReconnect = true;
    try {
      await _client.connect(username, password);
    } catch (e) {
      timesConnected++;
      if (timesConnected < maxReconnectAttempts) {
        _connect(username, password);
      } else {
        print('Failed to connect to the broker.');
        rethrow;
      }
    }
  }

  void _handleLampStatus(String macAddress, String payload) async {
    InternalSession session = await Serverpod.instance.createSession();
    var endpoint = LampsEndpoint();
    Map<String, dynamic> data = jsonDecode(payload);
    await endpoint.updateLamp(session, Lamp.fromJson(data));
    session.close();
  }

  void _handleHVACStatus(String macAddress, String payload) {
    // Handle the HVAC status message
  }

  /// Handles the logic when the connection to the broker is established.
  void _onConnected() async {
    InternalSession session = await Serverpod.instance.createSession();
    // Handle the logic when the connection to the broker is established
    _client.subscribe("vigiloffice/welcome", MqttQos.atLeastOnce);

    _client.updates!
        .listen((List<MqttReceivedMessage<MqttMessage>> messages) async {
      InternalSession msgSession = await Serverpod.instance.createSession();
      for (MqttReceivedMessage<MqttMessage> message in messages) {
        final MqttPublishMessage receivedMessage =
            message.payload as MqttPublishMessage;
        final String topic = message.topic;
        final String payload = MqttPublishPayload.bytesToStringAsString(
            receivedMessage.payload.message);
        final String macAddress = topic.split('/')[2];
        // Handle the incoming message logic here
        switch (topic) {
          case 'vigiloffice/lamps/+/status':
            msgSession.log('Received lamp status message: $payload');
            _handleLampStatus(macAddress, payload);
            break;
          case 'vigiloffice/hvac/+/status':
            msgSession.log('Received hvac status message: $payload');
            _handleHVACStatus(macAddress, payload);
            break;
          default:
            // Handle unknown topic
            print('Unknown topic: $topic');
            break;
        }
      }
      msgSession.close();
    });
    session.log('Connected to the broker.');
    session.close();
  }

  /// Handles the logic when the connection to the broker is lost.
  ///
  /// Implement automatic reconnection logic here.
  void _onDisconnected() {
    // Handle the logic when the connection to the broker is lost
  }

  /// Handles the logic when a subscription is successful.
  void _onSubscribed(String topic) {
    // Handle the logic when a subscription is successful
  }

  /// Handles the logic when a subscription fails.
  void _onSubscribeFail(String topic) {
    // Handle the logic when a subscription fails
  }

  /// Handles the logic when the client is attempting to reconnect.
  void _onAutoReconnect() {
    // Handle the logic when the client is attempting to reconnect
  }

  /// Handles the logic when the client successfully reconnects.
  void _onAutoReconnected() {
    // Handle the logic when the client successfully reconnects
  }

  // Add your methods and properties here
}
