/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import '../endpoints/device_endpoint.dart' as _i2;
import 'package:vigiloffice_server/src/generated/device.dart' as _i3;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'device': _i2.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        )
    };
    connectors['device'] = _i1.EndpointConnector(
      name: 'device',
      endpoint: endpoints['device']!,
      methodConnectors: {
        'createDevice': _i1.MethodConnector(
          name: 'createDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i3.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['device'] as _i2.DeviceEndpoint).createDevice(
            session,
            params['device'],
          ),
        ),
        'readDevice': _i1.MethodConnector(
          name: 'readDevice',
          params: {
            'deviceMac': _i1.ParameterDescription(
              name: 'deviceMac',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['device'] as _i2.DeviceEndpoint).readDevice(
            session,
            params['deviceMac'],
          ),
        ),
        'updateDevice': _i1.MethodConnector(
          name: 'updateDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i3.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['device'] as _i2.DeviceEndpoint).updateDevice(
            session,
            params['device'],
          ),
        ),
        'deleteDevice': _i1.MethodConnector(
          name: 'deleteDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i3.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['device'] as _i2.DeviceEndpoint).deleteDevice(
            session,
            params['device'],
          ),
        ),
      },
    );
  }
}
