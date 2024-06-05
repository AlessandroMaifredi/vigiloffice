import 'package:serverpod/serverpod.dart';
import 'mqtt_manager.dart';

/// Represents the MQTT serverpod, responsible for managing MQTT connections and configurations.
class MQTTServerpod extends Serverpod {
  MqttManager? mqttManager;

  /// Creates a new instance of the MQTTServerpod.
  ///
  /// The [args] parameter represents the arguments passed to the serverpod.
  /// The [serializationManager] parameter represents the serialization manager used for serializing and deserializing data.
  /// The [endpoints] parameter represents the list of endpoints available in the serverpod.
  MQTTServerpod(super.args, super.serializationManager, super.endpoints) {
    try {
      mqttManager = MqttManager(
        Serverpod.instance.getPassword("mqttUsername")!,
        Serverpod.instance.getPassword("mqttPassword")!,
      );
    } catch (e) {
      print('Failed to connect to the broker.');
      rethrow;
    }
  }
}
