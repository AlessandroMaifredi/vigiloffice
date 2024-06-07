/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class MotionSensor
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  MotionSensor._({
    required this.value,
    required this.status,
    required this.enabled,
  });

  factory MotionSensor({
    required int value,
    required int status,
    required bool enabled,
  }) = _MotionSensorImpl;

  factory MotionSensor.fromJson(Map<String, dynamic> jsonSerialization) {
    return MotionSensor(
      value: jsonSerialization['value'] as int,
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
    );
  }

  int value;

  int status;

  bool enabled;

  MotionSensor copyWith({
    int? value,
    int? status,
    bool? enabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'value': value,
      'status': status,
      'enabled': enabled,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'value': value,
      'status': status,
      'enabled': enabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MotionSensorImpl extends MotionSensor {
  _MotionSensorImpl({
    required int value,
    required int status,
    required bool enabled,
  }) : super._(
          value: value,
          status: status,
          enabled: enabled,
        );

  @override
  MotionSensor copyWith({
    int? value,
    int? status,
    bool? enabled,
  }) {
    return MotionSensor(
      value: value ?? this.value,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
    );
  }
}
