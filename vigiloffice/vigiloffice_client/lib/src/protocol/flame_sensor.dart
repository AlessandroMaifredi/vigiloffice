/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class FlameSensor implements _i1.SerializableModel {
  FlameSensor._({
    required this.value,
    required this.status,
    required this.enabled,
    required this.interval,
  });

  factory FlameSensor({
    required int value,
    required int status,
    required bool enabled,
    required int interval,
  }) = _FlameSensorImpl;

  factory FlameSensor.fromJson(Map<String, dynamic> jsonSerialization) {
    return FlameSensor(
      value: jsonSerialization['value'] as int,
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
      interval: jsonSerialization['interval'] as int,
    );
  }

  int value;

  int status;

  bool enabled;

  int interval;

  FlameSensor copyWith({
    int? value,
    int? status,
    bool? enabled,
    int? interval,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'status': status,
      'enabled': enabled,
      'interval': interval,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _FlameSensorImpl extends FlameSensor {
  _FlameSensorImpl({
    required int value,
    required int status,
    required bool enabled,
    required int interval,
  }) : super._(
          value: value,
          status: status,
          enabled: enabled,
          interval: interval,
        );

  @override
  FlameSensor copyWith({
    int? value,
    int? status,
    bool? enabled,
    int? interval,
  }) {
    return FlameSensor(
      value: value ?? this.value,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
    );
  }
}
