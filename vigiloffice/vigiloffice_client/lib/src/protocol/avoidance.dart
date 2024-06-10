/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class AvoidanceSensor implements _i1.SerializableModel {
  AvoidanceSensor._({
    required this.status,
    required this.enabled,
  });

  factory AvoidanceSensor({
    required int status,
    required bool enabled,
  }) = _AvoidanceSensorImpl;

  factory AvoidanceSensor.fromJson(Map<String, dynamic> jsonSerialization) {
    return AvoidanceSensor(
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
    );
  }

  int status;

  bool enabled;

  AvoidanceSensor copyWith({
    int? status,
    bool? enabled,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'enabled': enabled,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _AvoidanceSensorImpl extends AvoidanceSensor {
  _AvoidanceSensorImpl({
    required int status,
    required bool enabled,
  }) : super._(
          status: status,
          enabled: enabled,
        );

  @override
  AvoidanceSensor copyWith({
    int? status,
    bool? enabled,
  }) {
    return AvoidanceSensor(
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
    );
  }
}
