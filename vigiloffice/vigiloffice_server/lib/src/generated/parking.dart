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

abstract class Parking extends _i1.TableRow
    implements _i1.ProtocolSerialization {
  Parking._({
    int? id,
    required this.macAddress,
    required this.floodingSensor,
    required this.flameSensor,
    required this.avoidanceSensor,
    required this.rgbLed,
    required this.alarm,
    this.lastUpdate,
    this.renterId,
  }) : super(id);

  factory Parking({
    int? id,
    required String macAddress,
    required _i2.FloodingSensor floodingSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.AvoidanceSensor avoidanceSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
    String? renterId,
  }) = _ParkingImpl;

  factory Parking.fromJson(Map<String, dynamic> jsonSerialization) {
    return Parking(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      floodingSensor: _i2.FloodingSensor.fromJson(
          (jsonSerialization['floodingSensor'] as Map<String, dynamic>)),
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      avoidanceSensor: _i2.AvoidanceSensor.fromJson(
          (jsonSerialization['avoidanceSensor'] as Map<String, dynamic>)),
      rgbLed: _i2.RGBLed.fromJson(
          (jsonSerialization['rgbLed'] as Map<String, dynamic>)),
      alarm: _i2.Alarm.fromJson(
          (jsonSerialization['alarm'] as Map<String, dynamic>)),
      lastUpdate: jsonSerialization['lastUpdate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUpdate']),
      renterId: jsonSerialization['renterId'] as String?,
    );
  }

  static final t = ParkingTable();

  static const db = ParkingRepository._();

  String macAddress;

  _i2.FloodingSensor floodingSensor;

  _i2.FlameSensor flameSensor;

  _i2.AvoidanceSensor avoidanceSensor;

  _i2.RGBLed rgbLed;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  String? renterId;

  @override
  _i1.Table get table => t;

  Parking copyWith({
    int? id,
    String? macAddress,
    _i2.FloodingSensor? floodingSensor,
    _i2.FlameSensor? flameSensor,
    _i2.AvoidanceSensor? avoidanceSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
    String? renterId,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'floodingSensor': floodingSensor.toJson(),
      'flameSensor': flameSensor.toJson(),
      'avoidanceSensor': avoidanceSensor.toJson(),
      'rgbLed': rgbLed.toJson(),
      'alarm': alarm.toJson(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
      if (renterId != null) 'renterId': renterId,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'floodingSensor': floodingSensor.toJsonForProtocol(),
      'flameSensor': flameSensor.toJsonForProtocol(),
      'avoidanceSensor': avoidanceSensor.toJsonForProtocol(),
      'rgbLed': rgbLed.toJsonForProtocol(),
      'alarm': alarm.toJsonForProtocol(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
    };
  }

  static ParkingInclude include() {
    return ParkingInclude._();
  }

  static ParkingIncludeList includeList({
    _i1.WhereExpressionBuilder<ParkingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ParkingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ParkingTable>? orderByList,
    ParkingInclude? include,
  }) {
    return ParkingIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Parking.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Parking.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ParkingImpl extends Parking {
  _ParkingImpl({
    int? id,
    required String macAddress,
    required _i2.FloodingSensor floodingSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.AvoidanceSensor avoidanceSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
    String? renterId,
  }) : super._(
          id: id,
          macAddress: macAddress,
          floodingSensor: floodingSensor,
          flameSensor: flameSensor,
          avoidanceSensor: avoidanceSensor,
          rgbLed: rgbLed,
          alarm: alarm,
          lastUpdate: lastUpdate,
          renterId: renterId,
        );

  @override
  Parking copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.FloodingSensor? floodingSensor,
    _i2.FlameSensor? flameSensor,
    _i2.AvoidanceSensor? avoidanceSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
    Object? renterId = _Undefined,
  }) {
    return Parking(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      floodingSensor: floodingSensor ?? this.floodingSensor.copyWith(),
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      avoidanceSensor: avoidanceSensor ?? this.avoidanceSensor.copyWith(),
      rgbLed: rgbLed ?? this.rgbLed.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
      renterId: renterId is String? ? renterId : this.renterId,
    );
  }
}

class ParkingTable extends _i1.Table {
  ParkingTable({super.tableRelation}) : super(tableName: 'parkings') {
    macAddress = _i1.ColumnString(
      'macAddress',
      this,
    );
    floodingSensor = _i1.ColumnSerializable(
      'floodingSensor',
      this,
    );
    flameSensor = _i1.ColumnSerializable(
      'flameSensor',
      this,
    );
    avoidanceSensor = _i1.ColumnSerializable(
      'avoidanceSensor',
      this,
    );
    rgbLed = _i1.ColumnSerializable(
      'rgbLed',
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
    renterId = _i1.ColumnString(
      'renterId',
      this,
    );
  }

  late final _i1.ColumnString macAddress;

  late final _i1.ColumnSerializable floodingSensor;

  late final _i1.ColumnSerializable flameSensor;

  late final _i1.ColumnSerializable avoidanceSensor;

  late final _i1.ColumnSerializable rgbLed;

  late final _i1.ColumnSerializable alarm;

  late final _i1.ColumnDateTime lastUpdate;

  late final _i1.ColumnString renterId;

  @override
  List<_i1.Column> get columns => [
        id,
        macAddress,
        floodingSensor,
        flameSensor,
        avoidanceSensor,
        rgbLed,
        alarm,
        lastUpdate,
        renterId,
      ];
}

class ParkingInclude extends _i1.IncludeObject {
  ParkingInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Parking.t;
}

class ParkingIncludeList extends _i1.IncludeList {
  ParkingIncludeList._({
    _i1.WhereExpressionBuilder<ParkingTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Parking.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Parking.t;
}

class ParkingRepository {
  const ParkingRepository._();

  Future<List<Parking>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ParkingTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<ParkingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ParkingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Parking>(
      where: where?.call(Parking.t),
      orderBy: orderBy?.call(Parking.t),
      orderByList: orderByList?.call(Parking.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Parking?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ParkingTable>? where,
    int? offset,
    _i1.OrderByBuilder<ParkingTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<ParkingTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Parking>(
      where: where?.call(Parking.t),
      orderBy: orderBy?.call(Parking.t),
      orderByList: orderByList?.call(Parking.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Parking?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Parking>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Parking>> insert(
    _i1.Session session,
    List<Parking> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Parking>(
      rows,
      transaction: transaction,
    );
  }

  Future<Parking> insertRow(
    _i1.Session session,
    Parking row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Parking>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Parking>> update(
    _i1.Session session,
    List<Parking> rows, {
    _i1.ColumnSelections<ParkingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Parking>(
      rows,
      columns: columns?.call(Parking.t),
      transaction: transaction,
    );
  }

  Future<Parking> updateRow(
    _i1.Session session,
    Parking row, {
    _i1.ColumnSelections<ParkingTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Parking>(
      row,
      columns: columns?.call(Parking.t),
      transaction: transaction,
    );
  }

  Future<List<Parking>> delete(
    _i1.Session session,
    List<Parking> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Parking>(
      rows,
      transaction: transaction,
    );
  }

  Future<Parking> deleteRow(
    _i1.Session session,
    Parking row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Parking>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Parking>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<ParkingTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Parking>(
      where: where(Parking.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<ParkingTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Parking>(
      where: where?.call(Parking.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
