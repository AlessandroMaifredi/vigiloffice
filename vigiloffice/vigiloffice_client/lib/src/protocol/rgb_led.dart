/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class RGBLed implements _i1.SerializableModel {
  RGBLed._({
    required this.value,
    required this.status,
    required this.enabled,
  });

  factory RGBLed({
    required int value,
    required int status,
    required bool enabled,
  }) = _RGBLedImpl;

  factory RGBLed.fromJson(Map<String, dynamic> jsonSerialization) {
    return RGBLed(
      value: jsonSerialization['value'] as int,
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
    );
  }

  int value;

  int status;

  bool enabled;

  RGBLed copyWith({
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
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _RGBLedImpl extends RGBLed {
  _RGBLedImpl({
    required int value,
    required int status,
    required bool enabled,
  }) : super._(
          value: value,
          status: status,
          enabled: enabled,
        );

  @override
  RGBLed copyWith({
    int? value,
    int? status,
    bool? enabled,
  }) {
    return RGBLed(
      value: value ?? this.value,
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
    );
  }
}
