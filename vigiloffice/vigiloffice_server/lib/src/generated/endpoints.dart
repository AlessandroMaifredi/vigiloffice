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
import '../endpoints/lamps_endpoint.dart' as _i3;
import 'package:vigiloffice_server/src/generated/device.dart' as _i4;
import 'package:vigiloffice_server/src/generated/lamp.dart' as _i5;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'device': _i2.DeviceEndpoint()
        ..initialize(
          server,
          'device',
          null,
        ),
      'lamps': _i3.LampsEndpoint()
        ..initialize(
          server,
          'lamps',
          null,
        ),
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
              type: _i1.getType<_i4.Device>(),
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
              type: _i1.getType<_i4.Device>(),
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
              type: _i1.getType<_i4.Device>(),
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
    connectors['lamps'] = _i1.EndpointConnector(
      name: 'lamps',
      endpoint: endpoints['lamps']!,
      methodConnectors: {
        'createLamp': _i1.MethodConnector(
          name: 'createLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i5.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i3.LampsEndpoint).createLamp(
            session,
            params['lamp'],
          ),
        ),
        'readLamp': _i1.MethodConnector(
          name: 'readLamp',
          params: {
            'lampMac': _i1.ParameterDescription(
              name: 'lampMac',
              type: _i1.getType<int>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i3.LampsEndpoint).readLamp(
            session,
            params['lampMac'],
          ),
        ),
        'updateLamp': _i1.MethodConnector(
          name: 'updateLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i5.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i3.LampsEndpoint).updateLamp(
            session,
            params['lamp'],
          ),
        ),
        'deleteLamp': _i1.MethodConnector(
          name: 'deleteLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i5.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i3.LampsEndpoint).deleteLamp(
            session,
            params['lamp'],
          ),
        ),
        'controlLamp': _i1.MethodConnector(
          name: 'controlLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i5.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i3.LampsEndpoint).controlLamp(
            session,
            params['lamp'],
          ),
        ),
      },
    );
  }
}
