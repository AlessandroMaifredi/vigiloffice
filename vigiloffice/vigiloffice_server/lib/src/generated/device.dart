/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: public_member_api_docs
// ignore_for_file: implementation_imports
// ignore_for_file: use_super_parameters
// ignore_for_file: type_literal_in_constant_pattern

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;
import 'protocol.dart' as _i2;

abstract class Device extends _i1.TableRow
    implements _i1.ProtocolSerialization {
  Device._({
    int? id,
    required this.type,
    required this.macAddress,
    this.status,
  }) : super(id);

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

  static final t = DeviceTable();

  static const db = DeviceRepository._();

  _i2.DeviceType type;

  String macAddress;

  _i2.DeviceStatus? status;

  @override
  _i1.Table get table => t;

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
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'type': type.toJson(),
      'macAddress': macAddress,
      if (status != null) 'status': status?.toJson(),
    };
  }

  static DeviceInclude include() {
    return DeviceInclude._();
  }

  static DeviceIncludeList includeList({
    _i1.WhereExpressionBuilder<DeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceTable>? orderByList,
    DeviceInclude? include,
  }) {
    return DeviceIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Device.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Device.t),
      include: include,
    );
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

class DeviceTable extends _i1.Table {
  DeviceTable({super.tableRelation}) : super(tableName: 'devices') {
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    macAddress = _i1.ColumnString(
      'macAddress',
      this,
    );
    status = _i1.ColumnEnum(
      'status',
      this,
      _i1.EnumSerialization.byName,
    );
  }

  late final _i1.ColumnEnum<_i2.DeviceType> type;

  late final _i1.ColumnString macAddress;

  late final _i1.ColumnEnum<_i2.DeviceStatus> status;

  @override
  List<_i1.Column> get columns => [
        id,
        type,
        macAddress,
        status,
      ];
}

class DeviceInclude extends _i1.IncludeObject {
  DeviceInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Device.t;
}

class DeviceIncludeList extends _i1.IncludeList {
  DeviceIncludeList._({
    _i1.WhereExpressionBuilder<DeviceTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Device.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Device.t;
}

class DeviceRepository {
  const DeviceRepository._();

  Future<List<Device>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeviceTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Device>(
      where: where?.call(Device.t),
      orderBy: orderBy?.call(Device.t),
      orderByList: orderByList?.call(Device.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Device?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeviceTable>? where,
    int? offset,
    _i1.OrderByBuilder<DeviceTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeviceTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Device>(
      where: where?.call(Device.t),
      orderBy: orderBy?.call(Device.t),
      orderByList: orderByList?.call(Device.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Device?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Device>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Device>> insert(
    _i1.Session session,
    List<Device> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Device>(
      rows,
      transaction: transaction,
    );
  }

  Future<Device> insertRow(
    _i1.Session session,
    Device row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Device>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Device>> update(
    _i1.Session session,
    List<Device> rows, {
    _i1.ColumnSelections<DeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Device>(
      rows,
      columns: columns?.call(Device.t),
      transaction: transaction,
    );
  }

  Future<Device> updateRow(
    _i1.Session session,
    Device row, {
    _i1.ColumnSelections<DeviceTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Device>(
      row,
      columns: columns?.call(Device.t),
      transaction: transaction,
    );
  }

  Future<List<Device>> delete(
    _i1.Session session,
    List<Device> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Device>(
      rows,
      transaction: transaction,
    );
  }

  Future<Device> deleteRow(
    _i1.Session session,
    Device row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Device>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Device>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DeviceTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Device>(
      where: where(Device.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeviceTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Device>(
      where: where?.call(Device.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
