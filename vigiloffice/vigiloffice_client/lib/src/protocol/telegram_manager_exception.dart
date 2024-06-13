/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class TelegramManagerException
    implements _i1.SerializableException, _i1.SerializableModel {
  TelegramManagerException._({required this.message});

  factory TelegramManagerException({required String message}) =
      _TelegramManagerExceptionImpl;

  factory TelegramManagerException.fromJson(
      Map<String, dynamic> jsonSerialization) {
    return TelegramManagerException(
        message: jsonSerialization['message'] as String);
  }

  String message;

  TelegramManagerException copyWith({String? message});
  @override
  Map<String, dynamic> toJson() {
    return {'message': message};
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _TelegramManagerExceptionImpl extends TelegramManagerException {
  _TelegramManagerExceptionImpl({required String message})
      : super._(message: message);

  @override
  TelegramManagerException copyWith({String? message}) {
    return TelegramManagerException(message: message ?? this.message);
  }
}
