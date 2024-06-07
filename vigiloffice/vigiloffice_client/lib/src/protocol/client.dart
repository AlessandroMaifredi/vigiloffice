/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'dart:async' as _i2;
import 'package:vigiloffice_client/src/protocol/device.dart' as _i3;
import 'package:vigiloffice_client/src/protocol/lamp.dart' as _i4;
import 'protocol.dart' as _i5;

/// Endpoint for managing devices.
/// {@category Endpoint}
class EndpointDevice extends _i1.EndpointRef {
  EndpointDevice(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'device';

  /// Creates a new device.
  ///
  /// Returns the created device.
  _i2.Future<_i3.Device> createDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'device',
        'createDevice',
        {'device': device},
      );

  /// Reads a device by its MAC address.
  ///
  /// Returns the device with the specified MAC address, or `null` if not found.
  _i2.Future<_i3.Device?> readDevice(int deviceMac) =>
      caller.callServerEndpoint<_i3.Device?>(
        'device',
        'readDevice',
        {'deviceMac': deviceMac},
      );

  /// Updates an existing device.
  ///
  /// Returns the updated device.
  _i2.Future<_i3.Device> updateDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'device',
        'updateDevice',
        {'device': device},
      );

  /// Deletes a device.
  ///
  /// Returns the deleted device.
  _i2.Future<_i3.Device?> deleteDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device?>(
        'device',
        'deleteDevice',
        {'device': device},
      );
}

/// Endpoint for managing lamps.
/// {@category Endpoint}
class EndpointLamps extends _i1.EndpointRef {
  EndpointLamps(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'lamps';

  /// Creates a new lamp.
  ///
  /// Returns the created lamp.
  _i2.Future<_i4.Lamp> createLamp(_i4.Lamp lamp) =>
      caller.callServerEndpoint<_i4.Lamp>(
        'lamps',
        'createLamp',
        {'lamp': lamp},
      );

  /// Reads a lamp by its MAC address.
  ///
  /// Returns the lamp with the specified MAC address, or `null` if not found.
  _i2.Future<_i4.Lamp?> readLamp(int lampMac) =>
      caller.callServerEndpoint<_i4.Lamp?>(
        'lamps',
        'readLamp',
        {'lampMac': lampMac},
      );

  /// Updates an existing lamp on the database.
  ///
  /// Does not update the lamp on the MQTT broker. See [MqttManager.controlLamp] for that.
  ///
  /// Returns the updated lamp.
  _i2.Future<_i4.Lamp> updateLamp(_i4.Lamp lamp) =>
      caller.callServerEndpoint<_i4.Lamp>(
        'lamps',
        'updateLamp',
        {'lamp': lamp},
      );

  /// Deletes a lamp.
  ///
  /// Returns the deleted lamp.
  _i2.Future<_i4.Lamp> deleteLamp(_i4.Lamp lamp) =>
      caller.callServerEndpoint<_i4.Lamp>(
        'lamps',
        'deleteLamp',
        {'lamp': lamp},
      );

  /// Updates the state of a lamp on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateLamp] for updating the lamp on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated lamp.
  _i2.Future<_i4.Lamp> controlLamp(_i4.Lamp lamp) =>
      caller.callServerEndpoint<_i4.Lamp>(
        'lamps',
        'controlLamp',
        {'lamp': lamp},
      );
}

class Client extends _i1.ServerpodClient {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
  }) : super(
          host,
          _i5.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
        ) {
    device = EndpointDevice(this);
    lamps = EndpointLamps(this);
  }

  late final EndpointDevice device;

  late final EndpointLamps lamps;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'device': device,
        'lamps': lamps,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
