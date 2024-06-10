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
import 'package:vigiloffice_client/src/protocol/hvac.dart' as _i4;
import 'package:vigiloffice_client/src/protocol/lamp.dart' as _i5;
import 'package:vigiloffice_client/src/protocol/parking.dart' as _i6;
import 'protocol.dart' as _i7;

/// Endpoint for managing devices.
/// {@category Endpoint}
class EndpointDevices extends _i1.EndpointRef {
  EndpointDevices(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'devices';

  /// Creates a new device.
  ///
  /// Returns the created device.
  _i2.Future<_i3.Device> createDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'devices',
        'createDevice',
        {'device': device},
      );

  /// Reads a device by its MAC address.
  ///
  /// Returns the device with the specified MAC address, or `null` if not found.
  _i2.Future<_i3.Device?> readDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device?>(
        'devices',
        'readDevice',
        {'device': device},
      );

  /// Updates an existing device.
  ///
  /// Returns the updated device.
  _i2.Future<_i3.Device> updateDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'devices',
        'updateDevice',
        {'device': device},
      );

  /// Deletes a device.
  ///
  /// Returns the deleted device.
  _i2.Future<_i3.Device?> deleteDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device?>(
        'devices',
        'deleteDevice',
        {'device': device},
      );
}

/// Endpoint for managing hvacs.
/// {@category Endpoint}
class EndpointHvacs extends _i1.EndpointRef {
  EndpointHvacs(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'hvacs';

  /// Creates a new hvac.
  ///
  /// Returns the created hvac.
  _i2.Future<_i4.Hvac> createHvac(_i4.Hvac hvac) =>
      caller.callServerEndpoint<_i4.Hvac>(
        'hvacs',
        'createHvac',
        {'hvac': hvac},
      );

  /// Reads a hvac by its MAC address.
  ///
  /// Returns the hvac with the specified MAC address, or `null` if not found.
  _i2.Future<_i4.Hvac?> readHvac(_i4.Hvac hvac) =>
      caller.callServerEndpoint<_i4.Hvac?>(
        'hvacs',
        'readHvac',
        {'hvac': hvac},
      );

  /// Updates an existing hvac on the database.
  ///
  /// Does not update the hvac on the MQTT broker. See [MqttManager.controlHvac] for that.
  ///
  /// Returns the updated hvac.
  _i2.Future<_i4.Hvac> updateHvac(_i4.Hvac hvac) =>
      caller.callServerEndpoint<_i4.Hvac>(
        'hvacs',
        'updateHvac',
        {'hvac': hvac},
      );

  /// Deletes a hvac.
  ///
  /// Returns the deleted hvac.
  _i2.Future<_i4.Hvac> deleteHvac(_i4.Hvac hvac) =>
      caller.callServerEndpoint<_i4.Hvac>(
        'hvacs',
        'deleteHvac',
        {'hvac': hvac},
      );

  /// Updates the state of a hvac on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateHvac] for updating the hvac on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated hvac.
  _i2.Future<_i4.Hvac> controlHvac(_i4.Hvac hvac) =>
      caller.callServerEndpoint<_i4.Hvac>(
        'hvacs',
        'controlHvac',
        {'hvac': hvac},
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
  _i2.Future<_i5.Lamp> createLamp(_i5.Lamp lamp) =>
      caller.callServerEndpoint<_i5.Lamp>(
        'lamps',
        'createLamp',
        {'lamp': lamp},
      );

  /// Reads a lamp by its MAC address.
  ///
  /// Returns the lamp with the specified MAC address, or `null` if not found.
  _i2.Future<_i5.Lamp?> readLamp(_i5.Lamp lamp) =>
      caller.callServerEndpoint<_i5.Lamp?>(
        'lamps',
        'readLamp',
        {'lamp': lamp},
      );

  /// Updates an existing lamp on the database.
  ///
  /// Does not update the lamp on the MQTT broker. See [MqttManager.controlLamp] for that.
  ///
  /// Returns the updated lamp.
  _i2.Future<_i5.Lamp> updateLamp(_i5.Lamp lamp) =>
      caller.callServerEndpoint<_i5.Lamp>(
        'lamps',
        'updateLamp',
        {'lamp': lamp},
      );

  /// Deletes a lamp.
  ///
  /// Returns the deleted lamp.
  _i2.Future<_i5.Lamp> deleteLamp(_i5.Lamp lamp) =>
      caller.callServerEndpoint<_i5.Lamp>(
        'lamps',
        'deleteLamp',
        {'lamp': lamp},
      );

  /// Updates the state of a lamp on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateLamp] for updating the lamp on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated lamp.
  _i2.Future<_i5.Lamp> controlLamp(_i5.Lamp lamp) =>
      caller.callServerEndpoint<_i5.Lamp>(
        'lamps',
        'controlLamp',
        {'lamp': lamp},
      );
}

/// Endpoint for managing parkings.
/// {@category Endpoint}
class EndpointParkings extends _i1.EndpointRef {
  EndpointParkings(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'parkings';

  /// Creates a new parking.
  ///
  /// Returns the created parking.
  _i2.Future<_i6.Parking> createParking(_i6.Parking parking) =>
      caller.callServerEndpoint<_i6.Parking>(
        'parkings',
        'createParking',
        {'parking': parking},
      );

  /// Reads a parking by its MAC address.
  ///
  /// Returns the parking with the specified MAC address, or `null` if not found.
  _i2.Future<_i6.Parking?> readParking(_i6.Parking parking) =>
      caller.callServerEndpoint<_i6.Parking?>(
        'parkings',
        'readParking',
        {'parking': parking},
      );

  /// Updates an existing parking on the database.
  ///
  /// Does not update the parking on the MQTT broker. See [MqttManager.controlParking] for that.
  ///
  /// Returns the updated parking.
  _i2.Future<_i6.Parking> updateParking(_i6.Parking parking) =>
      caller.callServerEndpoint<_i6.Parking>(
        'parkings',
        'updateParking',
        {'parking': parking},
      );

  /// Deletes a parking.
  ///
  /// Returns the deleted parking.
  _i2.Future<_i6.Parking> deleteParking(_i6.Parking parking) =>
      caller.callServerEndpoint<_i6.Parking>(
        'parkings',
        'deleteParking',
        {'parking': parking},
      );

  /// Updates the state of a parking on the database and sends the new state to the MQTT broker.
  ///
  /// See [updateParking] for updating the parking on the database without sending the new state to the MQTT broker.
  ///
  /// Returns the updated parking.
  _i2.Future<_i6.Parking> controlParking(_i6.Parking parking) =>
      caller.callServerEndpoint<_i6.Parking>(
        'parkings',
        'controlParking',
        {'parking': parking},
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
          _i7.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
        ) {
    devices = EndpointDevices(this);
    hvacs = EndpointHvacs(this);
    lamps = EndpointLamps(this);
    parkings = EndpointParkings(this);
  }

  late final EndpointDevices devices;

  late final EndpointHvacs hvacs;

  late final EndpointLamps lamps;

  late final EndpointParkings parkings;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'devices': devices,
        'hvacs': hvacs,
        'lamps': lamps,
        'parkings': parkings,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
