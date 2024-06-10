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

abstract class Hvac implements _i1.SerializableModel {
  Hvac._({
    this.id,
    required this.macAddress,
    required this.flameSensor,
    required this.tempSensor,
    required this.ventActuator,
    required this.alarm,
    this.lastUpdate,
  });

  factory Hvac({
    int? id,
    required String macAddress,
    required _i2.FlameSensor flameSensor,
    required _i2.TempSensor tempSensor,
    required _i2.VentActuator ventActuator,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) = _HvacImpl;

  factory Hvac.fromJson(Map<String, dynamic> jsonSerialization) {
    return Hvac(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      tempSensor: _i2.TempSensor.fromJson(
          (jsonSerialization['tempSensor'] as Map<String, dynamic>)),
      ventActuator: _i2.VentActuator.fromJson(
          (jsonSerialization['ventActuator'] as Map<String, dynamic>)),
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

  _i2.FlameSensor flameSensor;

  _i2.TempSensor tempSensor;

  _i2.VentActuator ventActuator;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  Hvac copyWith({
    int? id,
    String? macAddress,
    _i2.FlameSensor? flameSensor,
    _i2.TempSensor? tempSensor,
    _i2.VentActuator? ventActuator,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'flameSensor': flameSensor.toJson(),
      'tempSensor': tempSensor.toJson(),
      'ventActuator': ventActuator.toJson(),
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

class _HvacImpl extends Hvac {
  _HvacImpl({
    int? id,
    required String macAddress,
    required _i2.FlameSensor flameSensor,
    required _i2.TempSensor tempSensor,
    required _i2.VentActuator ventActuator,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) : super._(
          id: id,
          macAddress: macAddress,
          flameSensor: flameSensor,
          tempSensor: tempSensor,
          ventActuator: ventActuator,
          alarm: alarm,
          lastUpdate: lastUpdate,
        );

  @override
  Hvac copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.FlameSensor? flameSensor,
    _i2.TempSensor? tempSensor,
    _i2.VentActuator? ventActuator,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
  }) {
    return Hvac(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      tempSensor: tempSensor ?? this.tempSensor.copyWith(),
      ventActuator: ventActuator ?? this.ventActuator.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
    );
  }
}
