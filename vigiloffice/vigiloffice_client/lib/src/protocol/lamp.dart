/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'protocol.dart' as _i2;

abstract class Lamp implements _i1.SerializableModel {
  Lamp._({
    this.id,
    required this.macAddress,
    required this.lightSensor,
    required this.motionSensor,
    required this.flameSensor,
    required this.rgbLed,
    required this.alarm,
    this.lastUpdate,
  });

  factory Lamp({
    int? id,
    required String macAddress,
    required _i2.LightSensor lightSensor,
    required _i2.MotionSensor motionSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) = _LampImpl;

  factory Lamp.fromJson(Map<String, dynamic> jsonSerialization) {
    return Lamp(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      lightSensor: _i2.LightSensor.fromJson(
          (jsonSerialization['lightSensor'] as Map<String, dynamic>)),
      motionSensor: _i2.MotionSensor.fromJson(
          (jsonSerialization['motionSensor'] as Map<String, dynamic>)),
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      rgbLed: _i2.RGBLed.fromJson(
          (jsonSerialization['rgbLed'] as Map<String, dynamic>)),
      alarm: _i2.Alarm.fromJson(
          (jsonSerialization['alarm'] as Map<String, dynamic>)),
      lastUpdate: jsonSerialization['lastUpdate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUpdate']),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String macAddress;

  _i2.LightSensor lightSensor;

  _i2.MotionSensor motionSensor;

  _i2.FlameSensor flameSensor;

  _i2.RGBLed rgbLed;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  Lamp copyWith({
    int? id,
    String? macAddress,
    _i2.LightSensor? lightSensor,
    _i2.MotionSensor? motionSensor,
    _i2.FlameSensor? flameSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'lightSensor': lightSensor.toJson(),
      'motionSensor': motionSensor.toJson(),
      'flameSensor': flameSensor.toJson(),
      'rgbLed': rgbLed.toJson(),
      'alarm': alarm.toJson(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LampImpl extends Lamp {
  _LampImpl({
    int? id,
    required String macAddress,
    required _i2.LightSensor lightSensor,
    required _i2.MotionSensor motionSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) : super._(
          id: id,
          macAddress: macAddress,
          lightSensor: lightSensor,
          motionSensor: motionSensor,
          flameSensor: flameSensor,
          rgbLed: rgbLed,
          alarm: alarm,
          lastUpdate: lastUpdate,
        );

  @override
  Lamp copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.LightSensor? lightSensor,
    _i2.MotionSensor? motionSensor,
    _i2.FlameSensor? flameSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
  }) {
    return Lamp(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      lightSensor: lightSensor ?? this.lightSensor.copyWith(),
      motionSensor: motionSensor ?? this.motionSensor.copyWith(),
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      rgbLed: rgbLed ?? this.rgbLed.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
    );
  }
}
