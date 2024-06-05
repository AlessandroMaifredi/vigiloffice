/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Alarm implements _i1.SerializableModel {
  Alarm._({
    required this.status,
    required this.enabled,
  });

  factory Alarm({
    required bool status,
    required bool enabled,
  }) = _AlarmImpl;

  factory Alarm.fromJson(Map<String, dynamic> jsonSerialization) {
    return Alarm(
      status: jsonSerialization['status'] as bool,
      enabled: jsonSerialization['enabled'] as bool,
    );
  }

  bool status;

  bool enabled;

  Alarm copyWith({
    bool? status,
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

class _AlarmImpl extends Alarm {
  _AlarmImpl({
    required bool status,
    required bool enabled,
  }) : super._(
          status: status,
          enabled: enabled,
        );

  @override
  Alarm copyWith({
    bool? status,
    bool? enabled,
  }) {
    return Alarm(
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
    );
  }
}
