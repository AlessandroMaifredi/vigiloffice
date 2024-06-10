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
import '../endpoints/hvacs_endpoint.dart' as _i3;
import '../endpoints/lamps_endpoint.dart' as _i4;
import '../endpoints/parkings_endpoint.dart' as _i5;
import 'package:vigiloffice_server/src/generated/device.dart' as _i6;
import 'package:vigiloffice_server/src/generated/hvac.dart' as _i7;
import 'package:vigiloffice_server/src/generated/lamp.dart' as _i8;
import 'package:vigiloffice_server/src/generated/parking.dart' as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'devices': _i2.DevicesEndpoint()
        ..initialize(
          server,
          'devices',
          null,
        ),
      'hvacs': _i3.HvacsEndpoint()
        ..initialize(
          server,
          'hvacs',
          null,
        ),
      'lamps': _i4.LampsEndpoint()
        ..initialize(
          server,
          'lamps',
          null,
        ),
      'parkings': _i5.ParkingsEndpoint()
        ..initialize(
          server,
          'parkings',
          null,
        ),
    };
    connectors['devices'] = _i1.EndpointConnector(
      name: 'devices',
      endpoint: endpoints['devices']!,
      methodConnectors: {
        'createDevice': _i1.MethodConnector(
          name: 'createDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i6.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['devices'] as _i2.DevicesEndpoint).createDevice(
            session,
            params['device'],
          ),
        ),
        'readDevice': _i1.MethodConnector(
          name: 'readDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i6.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['devices'] as _i2.DevicesEndpoint).readDevice(
            session,
            params['device'],
          ),
        ),
        'updateDevice': _i1.MethodConnector(
          name: 'updateDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i6.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['devices'] as _i2.DevicesEndpoint).updateDevice(
            session,
            params['device'],
          ),
        ),
        'deleteDevice': _i1.MethodConnector(
          name: 'deleteDevice',
          params: {
            'device': _i1.ParameterDescription(
              name: 'device',
              type: _i1.getType<_i6.Device>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['devices'] as _i2.DevicesEndpoint).deleteDevice(
            session,
            params['device'],
          ),
        ),
      },
    );
    connectors['hvacs'] = _i1.EndpointConnector(
      name: 'hvacs',
      endpoint: endpoints['hvacs']!,
      methodConnectors: {
        'createHvac': _i1.MethodConnector(
          name: 'createHvac',
          params: {
            'hvac': _i1.ParameterDescription(
              name: 'hvac',
              type: _i1.getType<_i7.Hvac>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['hvacs'] as _i3.HvacsEndpoint).createHvac(
            session,
            params['hvac'],
          ),
        ),
        'readHvac': _i1.MethodConnector(
          name: 'readHvac',
          params: {
            'hvac': _i1.ParameterDescription(
              name: 'hvac',
              type: _i1.getType<_i7.Hvac>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['hvacs'] as _i3.HvacsEndpoint).readHvac(
            session,
            params['hvac'],
          ),
        ),
        'updateHvac': _i1.MethodConnector(
          name: 'updateHvac',
          params: {
            'hvac': _i1.ParameterDescription(
              name: 'hvac',
              type: _i1.getType<_i7.Hvac>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['hvacs'] as _i3.HvacsEndpoint).updateHvac(
            session,
            params['hvac'],
          ),
        ),
        'deleteHvac': _i1.MethodConnector(
          name: 'deleteHvac',
          params: {
            'hvac': _i1.ParameterDescription(
              name: 'hvac',
              type: _i1.getType<_i7.Hvac>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['hvacs'] as _i3.HvacsEndpoint).deleteHvac(
            session,
            params['hvac'],
          ),
        ),
        'controlHvac': _i1.MethodConnector(
          name: 'controlHvac',
          params: {
            'hvac': _i1.ParameterDescription(
              name: 'hvac',
              type: _i1.getType<_i7.Hvac>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['hvacs'] as _i3.HvacsEndpoint).controlHvac(
            session,
            params['hvac'],
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
              type: _i1.getType<_i8.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i4.LampsEndpoint).createLamp(
            session,
            params['lamp'],
          ),
        ),
        'readLamp': _i1.MethodConnector(
          name: 'readLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i8.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i4.LampsEndpoint).readLamp(
            session,
            params['lamp'],
          ),
        ),
        'updateLamp': _i1.MethodConnector(
          name: 'updateLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i8.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i4.LampsEndpoint).updateLamp(
            session,
            params['lamp'],
          ),
        ),
        'deleteLamp': _i1.MethodConnector(
          name: 'deleteLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i8.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i4.LampsEndpoint).deleteLamp(
            session,
            params['lamp'],
          ),
        ),
        'controlLamp': _i1.MethodConnector(
          name: 'controlLamp',
          params: {
            'lamp': _i1.ParameterDescription(
              name: 'lamp',
              type: _i1.getType<_i8.Lamp>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['lamps'] as _i4.LampsEndpoint).controlLamp(
            session,
            params['lamp'],
          ),
        ),
      },
    );
    connectors['parkings'] = _i1.EndpointConnector(
      name: 'parkings',
      endpoint: endpoints['parkings']!,
      methodConnectors: {
        'createParking': _i1.MethodConnector(
          name: 'createParking',
          params: {
            'parking': _i1.ParameterDescription(
              name: 'parking',
              type: _i1.getType<_i9.Parking>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['parkings'] as _i5.ParkingsEndpoint).createParking(
            session,
            params['parking'],
          ),
        ),
        'readParking': _i1.MethodConnector(
          name: 'readParking',
          params: {
            'parking': _i1.ParameterDescription(
              name: 'parking',
              type: _i1.getType<_i9.Parking>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['parkings'] as _i5.ParkingsEndpoint).readParking(
            session,
            params['parking'],
          ),
        ),
        'updateParking': _i1.MethodConnector(
          name: 'updateParking',
          params: {
            'parking': _i1.ParameterDescription(
              name: 'parking',
              type: _i1.getType<_i9.Parking>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['parkings'] as _i5.ParkingsEndpoint).updateParking(
            session,
            params['parking'],
          ),
        ),
        'deleteParking': _i1.MethodConnector(
          name: 'deleteParking',
          params: {
            'parking': _i1.ParameterDescription(
              name: 'parking',
              type: _i1.getType<_i9.Parking>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['parkings'] as _i5.ParkingsEndpoint).deleteParking(
            session,
            params['parking'],
          ),
        ),
        'controlParking': _i1.MethodConnector(
          name: 'controlParking',
          params: {
            'parking': _i1.ParameterDescription(
              name: 'parking',
              type: _i1.getType<_i9.Parking>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['parkings'] as _i5.ParkingsEndpoint).controlParking(
            session,
            params['parking'],
          ),
        ),
      },
    );
  }
}
