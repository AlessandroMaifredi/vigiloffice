/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class TempSensor implements _i1.SerializableModel {
  TempSensor._({
    required this.tempValue,
    required this.humValue,
    required this.status,
    required this.enabled,
    required this.interval,
    required this.lowThreshold,
    required this.highThreshold,
    required this.target,
  });

  factory TempSensor({
    required int tempValue,
    required int humValue,
    required int status,
    required bool enabled,
    required int interval,
    required int lowThreshold,
    required int highThreshold,
    required int target,
  }) = _TempSensorImpl;

  factory TempSensor.fromJson(Map<String, dynamic> jsonSerialization) {
    return TempSensor(
      tempValue: jsonSerialization['tempValue'] as int,
      humValue: jsonSerialization['humValue'] as int,
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
      interval: jsonSerialization['interval'] as int,
      lowThreshold: jsonSerialization['lowThreshold'] as int,
      highThreshold: jsonSerialization['highThreshold'] as int,
      target: jsonSerialization['target'] as int,
    );
  }

  int tempValue;

  int humValue;

  int status;

  bool enabled;

  int interval;

  int lowThreshold;

  int highThreshold;

  int target;

  TempSensor copyWith({
    int? tempValue,
    int? humValue,
    int? status,
    bool? enabled,
    int? interval,
    int? lowThreshold,
    int? highThreshold,
    int? target,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'tempValue': tempValue,
      'humValue': humValue,
      'status': status,
      'enabled': enabled,
      'interval': interval,
      'lowThreshold': lowThreshold,
      'highThreshold': highThreshold,
      'target': target,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TempSensorImpl extends TempSensor {
  _TempSensorImpl({
    required int tempValue,
    required int humValue,
    required int status,
    required bool enabled,
    required int interval,
    required int lowThreshold,
    required int highThreshold,
    required int target,
  }) : super._(
          tempValue: tempValue,
          humValue: humValue,
          status: status,
          enabled: enabled,
          interval: interval,
          lowThreshold: lowThreshold,
          highThreshold: highThreshold,
          target: target,
        );

  @override
  TempSensor copyWith({
    int? tempValue,
    int? humValue,
    int? status,
    bool? enabled,
    int? interval,
    int? lowThreshold,
    int? highThreshold,
    int? target,
  }) {
    return TempSensor(
      tempValue: tempValue ?? this.tempValue,
      humValue: humValue ?? this.humValue,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
      lowThreshold: lowThreshold ?? this.lowThreshold,
      highThreshold: highThreshold ?? this.highThreshold,
      target: target ?? this.target,
    );
  }
}
