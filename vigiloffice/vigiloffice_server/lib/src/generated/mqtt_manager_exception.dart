/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class MqttManagerException
    implements
        _i1.SerializableException,
        _i1.SerializableModel,
        _i1.ProtocolSerialization {
  MqttManagerException._({required this.message});

  factory MqttManagerException({required String message}) =
      _MqttManagerExceptionImpl;

  factory MqttManagerException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return MqttManagerException(
        message: jsonSerialization['message'] as String);
  }

  String message;

  MqttManagerException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {'message': message};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _MqttManagerExceptionImpl extends MqttManagerException {
  _MqttManagerExceptionImpl({required String message})
      : super._(message: message);

  @override
  MqttManagerException copyWith({String? message}) {
    return MqttManagerException(message: message ?? this.message);
  }
}
