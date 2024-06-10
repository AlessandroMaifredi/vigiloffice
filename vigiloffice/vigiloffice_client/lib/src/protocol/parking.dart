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

abstract class Parking implements _i1.SerializableModel {
  Parking._({
    this.id,
    required this.macAddress,
    required this.floodingSensor,
    required this.flameSensor,
    required this.avoidanceSensor,
    required this.rgbLed,
    required this.alarm,
    this.lastUpdate,
  });

  factory Parking({
    int? id,
    required String macAddress,
    required _i2.FloodingSensor floodingSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.AvoidanceSensor avoidanceSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) = _ParkingImpl;

  factory Parking.fromJson(Map<String, dynamic> jsonSerialization) {
    return Parking(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      floodingSensor: _i2.FloodingSensor.fromJson(
          (jsonSerialization['floodingSensor'] as Map<String, dynamic>)),
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      avoidanceSensor: _i2.AvoidanceSensor.fromJson(
          (jsonSerialization['avoidanceSensor'] as Map<String, dynamic>)),
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

  _i2.FloodingSensor floodingSensor;

  _i2.FlameSensor flameSensor;

  _i2.AvoidanceSensor avoidanceSensor;

  _i2.RGBLed rgbLed;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  Parking copyWith({
    int? id,
    String? macAddress,
    _i2.FloodingSensor? floodingSensor,
    _i2.FlameSensor? flameSensor,
    _i2.AvoidanceSensor? avoidanceSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'floodingSensor': floodingSensor.toJson(),
      'flameSensor': flameSensor.toJson(),
      'avoidanceSensor': avoidanceSensor.toJson(),
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

class _ParkingImpl extends Parking {
  _ParkingImpl({
    int? id,
    required String macAddress,
    required _i2.FloodingSensor floodingSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.AvoidanceSensor avoidanceSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) : super._(
          id: id,
          macAddress: macAddress,
          floodingSensor: floodingSensor,
          flameSensor: flameSensor,
          avoidanceSensor: avoidanceSensor,
          rgbLed: rgbLed,
          alarm: alarm,
          lastUpdate: lastUpdate,
        );

  @override
  Parking copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.FloodingSensor? floodingSensor,
    _i2.FlameSensor? flameSensor,
    _i2.AvoidanceSensor? avoidanceSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
  }) {
    return Parking(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      floodingSensor: floodingSensor ?? this.floodingSensor.copyWith(),
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      avoidanceSensor: avoidanceSensor ?? this.avoidanceSensor.copyWith(),
      rgbLed: rgbLed ?? this.rgbLed.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
    );
  }
}
