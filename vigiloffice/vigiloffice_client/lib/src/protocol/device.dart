/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;

abstract class Device implements _i1.SerializableModel {
  Device._({
    this.id,
    required this.type,
    required this.macAddress,
  });

  factory Device({
    int? id,
    required String type,
    required String macAddress,
  }) = _DeviceImpl;

  factory Device.fromJson(Map<String, dynamic> jsonSerialization) {
    return Device(
      id: jsonSerialization['id'] as int?,
      type: jsonSerialization['type'] as String,
      macAddress: jsonSerialization['macAddress'] as String,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String type;

  String macAddress;

  Device copyWith({
    int? id,
    String? type,
    String? macAddress,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type,
      'macAddress': macAddress,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeviceImpl extends Device {
  _DeviceImpl({
    int? id,
    required String type,
    required String macAddress,
  }) : super._(
          id: id,
          type: type,
          macAddress: macAddress,
        );

  @override
  Device copyWith({
    Object? id = _Undefined,
    String? type,
    String? macAddress,
  }) {
    return Device(
      id: id is int? ? id : this.id,
      type: type ?? this.type,
      macAddress: macAddress ?? this.macAddress,
    );
  }
}
