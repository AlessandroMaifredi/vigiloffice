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
import 'protocol.dart' as _i4;

/// {@category Endpoint}
class EndpointDevice extends _i1.EndpointRef {
  EndpointDevice(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'device';

  _i2.Future<_i3.Device> createDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'device',
        'createDevice',
        {'device': device},
      );

  _i2.Future<_i3.Device?> readDevice(int deviceMac) =>
      caller.callServerEndpoint<_i3.Device?>(
        'device',
        'readDevice',
        {'deviceMac': deviceMac},
      );

  _i2.Future<_i3.Device> updateDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'device',
        'updateDevice',
        {'device': device},
      );

  _i2.Future<_i3.Device> deleteDevice(_i3.Device device) =>
      caller.callServerEndpoint<_i3.Device>(
        'device',
        'deleteDevice',
        {'device': device},
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
          _i4.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
        ) {
    device = EndpointDevice(this);
  }

  late final EndpointDevice device;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {'device': device};

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
