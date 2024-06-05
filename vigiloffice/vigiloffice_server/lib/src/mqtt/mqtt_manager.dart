import 'package:mqtt_client/mqtt_client.dart';

/// A class that manages the MQTT connection and provides methods to handle events.
class MqttManager {
  final MqttClient _client;
  static final String _brokerUrl = '149.132.178.179';
  static final String _clientId = 'serverpod';
  static final int maxReconnectAttempts = 5;

  int timesConnected = 0;

  /// Creates a new instance of the [MqttManager] class.
  ///
  /// The [username] and [password] are used to authenticate with the MQTT broker.
  MqttManager(String username, String password)
      : _client = MqttClient(_brokerUrl, _clientId) {
    _connect(username, password);
  }

  /// Connects to the MQTT broker using the provided [username] and [password].
  Future<void> _connect(String username, String password) async {
    _client.logging(on: true);
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

  /// Handles the logic when the connection to the broker is established.
  void _onConnected() {
    // Handle the logic when the connection to the broker is established
    _client.subscribe("vigiloffice/welcome", MqttQos.atLeastOnce);
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
