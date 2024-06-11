/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'protocol.dart' as _i2;

abstract class Device implements _i1.SerializableModel {
  Device._({
    this.id,
    required this.type,
    required this.macAddress,
    this.status,
  });

  factory Device({
    int? id,
    required _i2.DeviceType type,
    required String macAddress,
    _i2.DeviceStatus? status,
  }) = _DeviceImpl;

  factory Device.fromJson(Map<String, dynamic> jsonSerialization) {
    return Device(
      id: jsonSerialization['id'] as int?,
      type: _i2.DeviceType.fromJson((jsonSerialization['type'] as String)),
      macAddress: jsonSerialization['macAddress'] as String,
      status: jsonSerialization['status'] == null
          ? null
          : _i2.DeviceStatus.fromJson((jsonSerialization['status'] as String)),
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  _i2.DeviceType type;

  String macAddress;

  _i2.DeviceStatus? status;

  Device copyWith({
    int? id,
    _i2.DeviceType? type,
    String? macAddress,
    _i2.DeviceStatus? status,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'type': type.toJson(),
      'macAddress': macAddress,
      if (status != null) 'status': status?.toJson(),
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
    required _i2.DeviceType type,
    required String macAddress,
    _i2.DeviceStatus? status,
  }) : super._(
          id: id,
          type: type,
          macAddress: macAddress,
          status: status,
        );

  @override
  Device copyWith({
    Object? id = _Undefined,
    _i2.DeviceType? type,
    String? macAddress,
    Object? status = _Undefined,
  }) {
    return Device(
      id: id is int? ? id : this.id,
      type: type ?? this.type,
      macAddress: macAddress ?? this.macAddress,
      status: status is _i2.DeviceStatus? ? status : this.status,
    );
  }
}
