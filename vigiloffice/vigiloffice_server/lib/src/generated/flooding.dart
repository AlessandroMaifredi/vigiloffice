/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class FloodingSensor
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  FloodingSensor._({
    required this.status,
    required this.enabled,
    required this.interval,
    required this.highThreshold,
  });

  factory FloodingSensor({
    required int status,
    required bool enabled,
    required int interval,
    required int highThreshold,
  }) = _FloodingSensorImpl;

  factory FloodingSensor.fromJson(Map<String, dynamic> jsonSerialization) {
    return FloodingSensor(
      status: jsonSerialization['status'] as int,
      enabled: jsonSerialization['enabled'] as bool,
      interval: jsonSerialization['interval'] as int,
      highThreshold: jsonSerialization['highThreshold'] as int,
    );
  }

  int status;

  bool enabled;

  int interval;

  int highThreshold;

  FloodingSensor copyWith({
    int? status,
    bool? enabled,
    int? interval,
    int? highThreshold,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'enabled': enabled,
      'interval': interval,
      'highThreshold': highThreshold,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'status': status,
      'enabled': enabled,
      'interval': interval,
      'highThreshold': highThreshold,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _FloodingSensorImpl extends FloodingSensor {
  _FloodingSensorImpl({
    required int status,
    required bool enabled,
    required int interval,
    required int highThreshold,
  }) : super._(
          status: status,
          enabled: enabled,
          interval: interval,
          highThreshold: highThreshold,
        );

  @override
  FloodingSensor copyWith({
    int? status,
    bool? enabled,
    int? interval,
    int? highThreshold,
  }) {
    return FloodingSensor(
      status: status ?? this.status,
      enabled: enabled ?? this.enabled,
      interval: interval ?? this.interval,
      highThreshold: highThreshold ?? this.highThreshold,
    );
  }
}
