/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

library protocol; // ignore_for_file: no_leading_underscores_for_library_prefixes

import 'package:serverpod/serverpod.dart' as _i1;
import 'package:serverpod/protocol.dart' as _i2;
import 'alarm.dart' as _i3;
import 'avoidance.dart' as _i4;
import 'device.dart' as _i5;
import 'device_type.dart' as _i6;
import 'flame_sensor.dart' as _i7;
import 'flooding.dart' as _i8;
import 'hvac.dart' as _i9;
import 'lamp.dart' as _i10;
import 'light_sensor.dart' as _i11;
import 'motion_sensor.dart' as _i12;
import 'mqtt_manager_exception.dart' as _i13;
import 'parking.dart' as _i14;
import 'rgb_led.dart' as _i15;
import 'temp_sensor.dart' as _i16;
import 'vent_actuator.dart' as _i17;
export 'alarm.dart';
export 'avoidance.dart';
export 'device.dart';
export 'device_type.dart';
export 'flame_sensor.dart';
export 'flooding.dart';
export 'hvac.dart';
export 'lamp.dart';
export 'light_sensor.dart';
export 'motion_sensor.dart';
export 'mqtt_manager_exception.dart';
export 'parking.dart';
export 'rgb_led.dart';
export 'temp_sensor.dart';
export 'vent_actuator.dart';

class Protocol extends _i1.SerializationManagerServer {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  static final List<_i2.TableDefinition> targetTableDefinitions = [
    _i2.TableDefinition(
      name: 'devices',
      dartName: 'Device',
      schema: 'public',
      module: 'vigiloffice',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'devices_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'type',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'protocol:DeviceType',
        ),
        _i2.ColumnDefinition(
          name: 'macAddress',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'devices_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'hvacs',
      dartName: 'Hvac',
      schema: 'public',
      module: 'vigiloffice',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'hvacs_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'macAddress',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'flameSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:FlameSensor',
        ),
        _i2.ColumnDefinition(
          name: 'tempSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:TempSensor',
        ),
        _i2.ColumnDefinition(
          name: 'ventActuator',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:VentActuator',
        ),
        _i2.ColumnDefinition(
          name: 'alarm',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:Alarm',
        ),
        _i2.ColumnDefinition(
          name: 'lastUpdate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'hvacs_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'lamps',
      dartName: 'Lamp',
      schema: 'public',
      module: 'vigiloffice',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'lamps_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'macAddress',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'lightSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:LightSensor',
        ),
        _i2.ColumnDefinition(
          name: 'motionSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:MotionSensor',
        ),
        _i2.ColumnDefinition(
          name: 'flameSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:FlameSensor',
        ),
        _i2.ColumnDefinition(
          name: 'rgbLed',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:RGBLed',
        ),
        _i2.ColumnDefinition(
          name: 'alarm',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:Alarm',
        ),
        _i2.ColumnDefinition(
          name: 'lastUpdate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'lamps_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    _i2.TableDefinition(
      name: 'parkings',
      dartName: 'Parking',
      schema: 'public',
      module: 'vigiloffice',
      columns: [
        _i2.ColumnDefinition(
          name: 'id',
          columnType: _i2.ColumnType.bigint,
          isNullable: false,
          dartType: 'int?',
          columnDefault: 'nextval(\'parkings_id_seq\'::regclass)',
        ),
        _i2.ColumnDefinition(
          name: 'macAddress',
          columnType: _i2.ColumnType.text,
          isNullable: false,
          dartType: 'String',
        ),
        _i2.ColumnDefinition(
          name: 'floodingSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:FloodingSensor',
        ),
        _i2.ColumnDefinition(
          name: 'flameSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:FlameSensor',
        ),
        _i2.ColumnDefinition(
          name: 'avoidanceSensor',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:AvoidanceSensor',
        ),
        _i2.ColumnDefinition(
          name: 'rgbLed',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:RGBLed',
        ),
        _i2.ColumnDefinition(
          name: 'alarm',
          columnType: _i2.ColumnType.json,
          isNullable: false,
          dartType: 'protocol:Alarm',
        ),
        _i2.ColumnDefinition(
          name: 'lastUpdate',
          columnType: _i2.ColumnType.timestampWithoutTimeZone,
          isNullable: true,
          dartType: 'DateTime?',
        ),
      ],
      foreignKeys: [],
      indexes: [
        _i2.IndexDefinition(
          indexName: 'parkings_pkey',
          tableSpace: null,
          elements: [
            _i2.IndexElementDefinition(
              type: _i2.IndexElementDefinitionType.column,
              definition: 'id',
            )
          ],
          type: 'btree',
          isUnique: true,
          isPrimary: true,
        )
      ],
      managed: true,
    ),
    ..._i2.Protocol.targetTableDefinitions,
  ];

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i3.Alarm) {
      return _i3.Alarm.fromJson(data) as T;
    }
    if (t == _i4.AvoidanceSensor) {
      return _i4.AvoidanceSensor.fromJson(data) as T;
    }
    if (t == _i5.Device) {
      return _i5.Device.fromJson(data) as T;
    }
    if (t == _i6.DeviceType) {
      return _i6.DeviceType.fromJson(data) as T;
    }
    if (t == _i7.FlameSensor) {
      return _i7.FlameSensor.fromJson(data) as T;
    }
    if (t == _i8.FloodingSensor) {
      return _i8.FloodingSensor.fromJson(data) as T;
    }
    if (t == _i9.Hvac) {
      return _i9.Hvac.fromJson(data) as T;
    }
    if (t == _i10.Lamp) {
      return _i10.Lamp.fromJson(data) as T;
    }
    if (t == _i11.LightSensor) {
      return _i11.LightSensor.fromJson(data) as T;
    }
    if (t == _i12.MotionSensor) {
      return _i12.MotionSensor.fromJson(data) as T;
    }
    if (t == _i13.MqttManagerException) {
      return _i13.MqttManagerException.fromJson(data) as T;
    }
    if (t == _i14.Parking) {
      return _i14.Parking.fromJson(data) as T;
    }
    if (t == _i15.RGBLed) {
      return _i15.RGBLed.fromJson(data) as T;
    }
    if (t == _i16.TempSensor) {
      return _i16.TempSensor.fromJson(data) as T;
    }
    if (t == _i17.VentActuator) {
      return _i17.VentActuator.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.Alarm?>()) {
      return (data != null ? _i3.Alarm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.AvoidanceSensor?>()) {
      return (data != null ? _i4.AvoidanceSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.Device?>()) {
      return (data != null ? _i5.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.DeviceType?>()) {
      return (data != null ? _i6.DeviceType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.FlameSensor?>()) {
      return (data != null ? _i7.FlameSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.FloodingSensor?>()) {
      return (data != null ? _i8.FloodingSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.Hvac?>()) {
      return (data != null ? _i9.Hvac.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Lamp?>()) {
      return (data != null ? _i10.Lamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.LightSensor?>()) {
      return (data != null ? _i11.LightSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.MotionSensor?>()) {
      return (data != null ? _i12.MotionSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i13.MqttManagerException?>()) {
      return (data != null ? _i13.MqttManagerException.fromJson(data) : null)
          as T;
    }
    if (t == _i1.getType<_i14.Parking?>()) {
      return (data != null ? _i14.Parking.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i15.RGBLed?>()) {
      return (data != null ? _i15.RGBLed.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i16.TempSensor?>()) {
      return (data != null ? _i16.TempSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i17.VentActuator?>()) {
      return (data != null ? _i17.VentActuator.fromJson(data) : null) as T;
    }
    try {
      return _i2.Protocol().deserialize<T>(data, t);
    } on _i1.DeserializationTypeNotFoundException catch (_) {}
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object data) {
    if (data is _i3.Alarm) {
      return 'Alarm';
    }
    if (data is _i4.AvoidanceSensor) {
      return 'AvoidanceSensor';
    }
    if (data is _i5.Device) {
      return 'Device';
    }
    if (data is _i6.DeviceType) {
      return 'DeviceType';
    }
    if (data is _i7.FlameSensor) {
      return 'FlameSensor';
    }
    if (data is _i8.FloodingSensor) {
      return 'FloodingSensor';
    }
    if (data is _i9.Hvac) {
      return 'Hvac';
    }
    if (data is _i10.Lamp) {
      return 'Lamp';
    }
    if (data is _i11.LightSensor) {
      return 'LightSensor';
    }
    if (data is _i12.MotionSensor) {
      return 'MotionSensor';
    }
    if (data is _i13.MqttManagerException) {
      return 'MqttManagerException';
    }
    if (data is _i14.Parking) {
      return 'Parking';
    }
    if (data is _i15.RGBLed) {
      return 'RGBLed';
    }
    if (data is _i16.TempSensor) {
      return 'TempSensor';
    }
    if (data is _i17.VentActuator) {
      return 'VentActuator';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Alarm') {
      return deserialize<_i3.Alarm>(data['data']);
    }
    if (data['className'] == 'AvoidanceSensor') {
      return deserialize<_i4.AvoidanceSensor>(data['data']);
    }
    if (data['className'] == 'Device') {
      return deserialize<_i5.Device>(data['data']);
    }
    if (data['className'] == 'DeviceType') {
      return deserialize<_i6.DeviceType>(data['data']);
    }
    if (data['className'] == 'FlameSensor') {
      return deserialize<_i7.FlameSensor>(data['data']);
    }
    if (data['className'] == 'FloodingSensor') {
      return deserialize<_i8.FloodingSensor>(data['data']);
    }
    if (data['className'] == 'Hvac') {
      return deserialize<_i9.Hvac>(data['data']);
    }
    if (data['className'] == 'Lamp') {
      return deserialize<_i10.Lamp>(data['data']);
    }
    if (data['className'] == 'LightSensor') {
      return deserialize<_i11.LightSensor>(data['data']);
    }
    if (data['className'] == 'MotionSensor') {
      return deserialize<_i12.MotionSensor>(data['data']);
    }
    if (data['className'] == 'MqttManagerException') {
      return deserialize<_i13.MqttManagerException>(data['data']);
    }
    if (data['className'] == 'Parking') {
      return deserialize<_i14.Parking>(data['data']);
    }
    if (data['className'] == 'RGBLed') {
      return deserialize<_i15.RGBLed>(data['data']);
    }
    if (data['className'] == 'TempSensor') {
      return deserialize<_i16.TempSensor>(data['data']);
    }
    if (data['className'] == 'VentActuator') {
      return deserialize<_i17.VentActuator>(data['data']);
    }
    return super.deserializeByClassName(data);
  }

  @override
  _i1.Table? getTableForType(Type t) {
    {
      var table = _i2.Protocol().getTableForType(t);
      if (table != null) {
        return table;
      }
    }
    switch (t) {
      case _i5.Device:
        return _i5.Device.t;
      case _i9.Hvac:
        return _i9.Hvac.t;
      case _i10.Lamp:
        return _i10.Lamp.t;
      case _i14.Parking:
        return _i14.Parking.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'vigiloffice';
}
