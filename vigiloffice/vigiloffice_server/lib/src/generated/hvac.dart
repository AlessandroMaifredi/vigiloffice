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
import 'package:serverpod_serialization/serverpod_serialization.dart';

abstract class Hvac extends _i1.TableRow implements _i1.ProtocolSerialization {
  Hvac._({
    int? id,
    required this.macAddress,
    required this.type,
    required this.flameSensor,
    required this.tempSensor,
    required this.ventActuator,
    required this.alarm,
    this.lastUpdate,
  }) : super(id);

  factory Hvac({
    int? id,
    required String macAddress,
    required _i2.DeviceType type,
    required _i2.FlameSensor flameSensor,
    required _i2.TempSensor tempSensor,
    required _i2.VentActuator ventActuator,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) = _HvacImpl;

  factory Hvac.fromJson(Map<String, dynamic> jsonSerialization) {
    return Hvac(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      type: _i2.DeviceType.fromJson((jsonSerialization['type'] as String)),
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      tempSensor: _i2.TempSensor.fromJson(
          (jsonSerialization['tempSensor'] as Map<String, dynamic>)),
      ventActuator: _i2.VentActuator.fromJson(
          (jsonSerialization['ventActuator'] as Map<String, dynamic>)),
      alarm: _i2.Alarm.fromJson(
          (jsonSerialization['alarm'] as Map<String, dynamic>)),
      lastUpdate: jsonSerialization['lastUpdate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUpdate']),
    );
  }

  static final t = HvacTable();

  static const db = HvacRepository._();

  String macAddress;

  _i2.DeviceType type;

  _i2.FlameSensor flameSensor;

  _i2.TempSensor tempSensor;

  _i2.VentActuator ventActuator;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  @override
  _i1.Table get table => t;

  Hvac copyWith({
    int? id,
    String? macAddress,
    _i2.DeviceType? type,
    _i2.FlameSensor? flameSensor,
    _i2.TempSensor? tempSensor,
    _i2.VentActuator? ventActuator,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'type': type.toJson(),
      'flameSensor': flameSensor.toJson(),
      'tempSensor': tempSensor.toJson(),
      'ventActuator': ventActuator.toJson(),
      'alarm': alarm.toJson(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'type': type.toJson(),
      'flameSensor': flameSensor.toJsonForProtocol(),
      'tempSensor': tempSensor.toJsonForProtocol(),
      'ventActuator': ventActuator.toJsonForProtocol(),
      'alarm': alarm.toJsonForProtocol(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
    };
  }

  static HvacInclude include() {
    return HvacInclude._();
  }

  static HvacIncludeList includeList({
    _i1.WhereExpressionBuilder<HvacTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HvacTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HvacTable>? orderByList,
    HvacInclude? include,
  }) {
    return HvacIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Hvac.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Hvac.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _HvacImpl extends Hvac {
  _HvacImpl({
    int? id,
    required String macAddress,
    required _i2.DeviceType type,
    required _i2.FlameSensor flameSensor,
    required _i2.TempSensor tempSensor,
    required _i2.VentActuator ventActuator,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) : super._(
          id: id,
          macAddress: macAddress,
          type: type,
          flameSensor: flameSensor,
          tempSensor: tempSensor,
          ventActuator: ventActuator,
          alarm: alarm,
          lastUpdate: lastUpdate,
        );

  @override
  Hvac copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.DeviceType? type,
    _i2.FlameSensor? flameSensor,
    _i2.TempSensor? tempSensor,
    _i2.VentActuator? ventActuator,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
  }) {
    return Hvac(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      type: type ?? this.type,
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      tempSensor: tempSensor ?? this.tempSensor.copyWith(),
      ventActuator: ventActuator ?? this.ventActuator.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
    );
  }
}

class HvacTable extends _i1.Table {
  HvacTable({super.tableRelation}) : super(tableName: 'hvacs') {
    macAddress = _i1.ColumnString(
      'macAddress',
      this,
    );
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    flameSensor = _i1.ColumnSerializable(
      'flameSensor',
      this,
    );
    tempSensor = _i1.ColumnSerializable(
      'tempSensor',
      this,
    );
    ventActuator = _i1.ColumnSerializable(
      'ventActuator',
      this,
    );
    alarm = _i1.ColumnSerializable(
      'alarm',
      this,
    );
    lastUpdate = _i1.ColumnDateTime(
      'lastUpdate',
      this,
    );
  }

  late final _i1.ColumnString macAddress;

  late final _i1.ColumnEnum<_i2.DeviceType> type;

  late final _i1.ColumnSerializable flameSensor;

  late final _i1.ColumnSerializable tempSensor;

  late final _i1.ColumnSerializable ventActuator;

  late final _i1.ColumnSerializable alarm;

  late final _i1.ColumnDateTime lastUpdate;

  @override
  List<_i1.Column> get columns => [
        id,
        macAddress,
        type,
        flameSensor,
        tempSensor,
        ventActuator,
        alarm,
        lastUpdate,
      ];
}

class HvacInclude extends _i1.IncludeObject {
  HvacInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Hvac.t;
}

class HvacIncludeList extends _i1.IncludeList {
  HvacIncludeList._({
    _i1.WhereExpressionBuilder<HvacTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Hvac.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Hvac.t;
}

class HvacRepository {
  const HvacRepository._();

  Future<List<Hvac>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HvacTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<HvacTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HvacTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Hvac>(
      where: where?.call(Hvac.t),
      orderBy: orderBy?.call(Hvac.t),
      orderByList: orderByList?.call(Hvac.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Hvac?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HvacTable>? where,
    int? offset,
    _i1.OrderByBuilder<HvacTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<HvacTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Hvac>(
      where: where?.call(Hvac.t),
      orderBy: orderBy?.call(Hvac.t),
      orderByList: orderByList?.call(Hvac.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Hvac?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Hvac>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Hvac>> insert(
    _i1.Session session,
    List<Hvac> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Hvac>(
      rows,
      transaction: transaction,
    );
  }

  Future<Hvac> insertRow(
    _i1.Session session,
    Hvac row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Hvac>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Hvac>> update(
    _i1.Session session,
    List<Hvac> rows, {
    _i1.ColumnSelections<HvacTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Hvac>(
      rows,
      columns: columns?.call(Hvac.t),
      transaction: transaction,
    );
  }

  Future<Hvac> updateRow(
    _i1.Session session,
    Hvac row, {
    _i1.ColumnSelections<HvacTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Hvac>(
      row,
      columns: columns?.call(Hvac.t),
      transaction: transaction,
    );
  }

  Future<List<Hvac>> delete(
    _i1.Session session,
    List<Hvac> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Hvac>(
      rows,
      transaction: transaction,
    );
  }

  Future<Hvac> deleteRow(
    _i1.Session session,
    Hvac row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Hvac>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Hvac>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<HvacTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Hvac>(
      where: where(Hvac.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<HvacTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Hvac>(
      where: where?.call(Hvac.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
