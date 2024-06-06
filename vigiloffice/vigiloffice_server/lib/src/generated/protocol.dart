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
import 'device.dart' as _i4;
import 'device_type.dart' as _i5;
import 'flame_sensor.dart' as _i6;
import 'lamp.dart' as _i7;
import 'light_sensor.dart' as _i8;
import 'motion_sensor.dart' as _i9;
import 'rgb_led.dart' as _i10;
export 'alarm.dart';
export 'device.dart';
export 'device_type.dart';
export 'flame_sensor.dart';
export 'lamp.dart';
export 'light_sensor.dart';
export 'motion_sensor.dart';
export 'rgb_led.dart';

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
    if (t == _i4.Device) {
      return _i4.Device.fromJson(data) as T;
    }
    if (t == _i5.DeviceType) {
      return _i5.DeviceType.fromJson(data) as T;
    }
    if (t == _i6.FlameSensor) {
      return _i6.FlameSensor.fromJson(data) as T;
    }
    if (t == _i7.Lamp) {
      return _i7.Lamp.fromJson(data) as T;
    }
    if (t == _i8.LightSensor) {
      return _i8.LightSensor.fromJson(data) as T;
    }
    if (t == _i9.MotionSensor) {
      return _i9.MotionSensor.fromJson(data) as T;
    }
    if (t == _i10.RGBLed) {
      return _i10.RGBLed.fromJson(data) as T;
    }
    if (t == _i1.getType<_i3.Alarm?>()) {
      return (data != null ? _i3.Alarm.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.Device?>()) {
      return (data != null ? _i4.Device.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.DeviceType?>()) {
      return (data != null ? _i5.DeviceType.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.FlameSensor?>()) {
      return (data != null ? _i6.FlameSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.Lamp?>()) {
      return (data != null ? _i7.Lamp.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.LightSensor?>()) {
      return (data != null ? _i8.LightSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.MotionSensor?>()) {
      return (data != null ? _i9.MotionSensor.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.RGBLed?>()) {
      return (data != null ? _i10.RGBLed.fromJson(data) : null) as T;
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
    if (data is _i4.Device) {
      return 'Device';
    }
    if (data is _i5.DeviceType) {
      return 'DeviceType';
    }
    if (data is _i6.FlameSensor) {
      return 'FlameSensor';
    }
    if (data is _i7.Lamp) {
      return 'Lamp';
    }
    if (data is _i8.LightSensor) {
      return 'LightSensor';
    }
    if (data is _i9.MotionSensor) {
      return 'MotionSensor';
    }
    if (data is _i10.RGBLed) {
      return 'RGBLed';
    }
    return super.getClassNameForObject(data);
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    if (data['className'] == 'Alarm') {
      return deserialize<_i3.Alarm>(data['data']);
    }
    if (data['className'] == 'Device') {
      return deserialize<_i4.Device>(data['data']);
    }
    if (data['className'] == 'DeviceType') {
      return deserialize<_i5.DeviceType>(data['data']);
    }
    if (data['className'] == 'FlameSensor') {
      return deserialize<_i6.FlameSensor>(data['data']);
    }
    if (data['className'] == 'Lamp') {
      return deserialize<_i7.Lamp>(data['data']);
    }
    if (data['className'] == 'LightSensor') {
      return deserialize<_i8.LightSensor>(data['data']);
    }
    if (data['className'] == 'MotionSensor') {
      return deserialize<_i9.MotionSensor>(data['data']);
    }
    if (data['className'] == 'RGBLed') {
      return deserialize<_i10.RGBLed>(data['data']);
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
      case _i4.Device:
        return _i4.Device.t;
      case _i7.Lamp:
        return _i7.Lamp.t;
    }
    return null;
  }

  @override
  List<_i2.TableDefinition> getTargetTableDefinitions() =>
      targetTableDefinitions;

  @override
  String getModuleName() => 'vigiloffice';
}
