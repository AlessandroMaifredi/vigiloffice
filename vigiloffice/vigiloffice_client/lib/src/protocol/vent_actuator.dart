/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class VentActuator implements _i1.SerializableModel {
  VentActuator._({required this.enabled});

  factory VentActuator({required bool enabled}) = _VentActuatorImpl;

  factory VentActuator.fromJson(Map<String, dynamic> jsonSerialization) {
    return VentActuator(enabled: jsonSerialization['enabled'] as bool);
  }

  bool enabled;

  VentActuator copyWith({bool? enabled});
  @override
  Map<String, dynamic> toJson() {
    return {'enabled': enabled};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _VentActuatorImpl extends VentActuator {
  _VentActuatorImpl({required bool enabled}) : super._(enabled: enabled);

  @override
  VentActuator copyWith({bool? enabled}) {
    return VentActuator(enabled: enabled ?? this.enabled);
  }
}
