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

abstract class Lamp extends _i1.TableRow implements _i1.ProtocolSerialization {
  Lamp._({
    int? id,
    required this.macAddress,
    required this.type,
    required this.lightSensor,
    required this.motionSensor,
    required this.flameSensor,
    required this.rgbLed,
    required this.alarm,
    this.lastUpdate,
  }) : super(id);

  factory Lamp({
    int? id,
    required String macAddress,
    required _i2.DeviceType type,
    required _i2.LightSensor lightSensor,
    required _i2.MotionSensor motionSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) = _LampImpl;

  factory Lamp.fromJson(Map<String, dynamic> jsonSerialization) {
    return Lamp(
      id: jsonSerialization['id'] as int?,
      macAddress: jsonSerialization['macAddress'] as String,
      type: _i2.DeviceType.fromJson((jsonSerialization['type'] as String)),
      lightSensor: _i2.LightSensor.fromJson(
          (jsonSerialization['lightSensor'] as Map<String, dynamic>)),
      motionSensor: _i2.MotionSensor.fromJson(
          (jsonSerialization['motionSensor'] as Map<String, dynamic>)),
      flameSensor: _i2.FlameSensor.fromJson(
          (jsonSerialization['flameSensor'] as Map<String, dynamic>)),
      rgbLed: _i2.RGBLed.fromJson(
          (jsonSerialization['rgbLed'] as Map<String, dynamic>)),
      alarm: _i2.Alarm.fromJson(
          (jsonSerialization['alarm'] as Map<String, dynamic>)),
      lastUpdate: jsonSerialization['lastUpdate'] == null
          ? null
          : _i1.DateTimeJsonExtension.fromJson(jsonSerialization['lastUpdate']),
    );
  }

  static final t = LampTable();

  static const db = LampRepository._();

  String macAddress;

  _i2.DeviceType type;

  _i2.LightSensor lightSensor;

  _i2.MotionSensor motionSensor;

  _i2.FlameSensor flameSensor;

  _i2.RGBLed rgbLed;

  _i2.Alarm alarm;

  DateTime? lastUpdate;

  @override
  _i1.Table get table => t;

  Lamp copyWith({
    int? id,
    String? macAddress,
    _i2.DeviceType? type,
    _i2.LightSensor? lightSensor,
    _i2.MotionSensor? motionSensor,
    _i2.FlameSensor? flameSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    DateTime? lastUpdate,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'macAddress': macAddress,
      'type': type.toJson(),
      'lightSensor': lightSensor.toJson(),
      'motionSensor': motionSensor.toJson(),
      'flameSensor': flameSensor.toJson(),
      'rgbLed': rgbLed.toJson(),
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
      'lightSensor': lightSensor.toJsonForProtocol(),
      'motionSensor': motionSensor.toJsonForProtocol(),
      'flameSensor': flameSensor.toJsonForProtocol(),
      'rgbLed': rgbLed.toJsonForProtocol(),
      'alarm': alarm.toJsonForProtocol(),
      if (lastUpdate != null) 'lastUpdate': lastUpdate?.toJson(),
    };
  }

  static LampInclude include() {
    return LampInclude._();
  }

  static LampIncludeList includeList({
    _i1.WhereExpressionBuilder<LampTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LampTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LampTable>? orderByList,
    LampInclude? include,
  }) {
    return LampIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Lamp.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Lamp.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _LampImpl extends Lamp {
  _LampImpl({
    int? id,
    required String macAddress,
    required _i2.DeviceType type,
    required _i2.LightSensor lightSensor,
    required _i2.MotionSensor motionSensor,
    required _i2.FlameSensor flameSensor,
    required _i2.RGBLed rgbLed,
    required _i2.Alarm alarm,
    DateTime? lastUpdate,
  }) : super._(
          id: id,
          macAddress: macAddress,
          type: type,
          lightSensor: lightSensor,
          motionSensor: motionSensor,
          flameSensor: flameSensor,
          rgbLed: rgbLed,
          alarm: alarm,
          lastUpdate: lastUpdate,
        );

  @override
  Lamp copyWith({
    Object? id = _Undefined,
    String? macAddress,
    _i2.DeviceType? type,
    _i2.LightSensor? lightSensor,
    _i2.MotionSensor? motionSensor,
    _i2.FlameSensor? flameSensor,
    _i2.RGBLed? rgbLed,
    _i2.Alarm? alarm,
    Object? lastUpdate = _Undefined,
  }) {
    return Lamp(
      id: id is int? ? id : this.id,
      macAddress: macAddress ?? this.macAddress,
      type: type ?? this.type,
      lightSensor: lightSensor ?? this.lightSensor.copyWith(),
      motionSensor: motionSensor ?? this.motionSensor.copyWith(),
      flameSensor: flameSensor ?? this.flameSensor.copyWith(),
      rgbLed: rgbLed ?? this.rgbLed.copyWith(),
      alarm: alarm ?? this.alarm.copyWith(),
      lastUpdate: lastUpdate is DateTime? ? lastUpdate : this.lastUpdate,
    );
  }
}

class LampTable extends _i1.Table {
  LampTable({super.tableRelation}) : super(tableName: 'lamps') {
    macAddress = _i1.ColumnString(
      'macAddress',
      this,
    );
    type = _i1.ColumnEnum(
      'type',
      this,
      _i1.EnumSerialization.byName,
    );
    lightSensor = _i1.ColumnSerializable(
      'lightSensor',
      this,
    );
    motionSensor = _i1.ColumnSerializable(
      'motionSensor',
      this,
    );
    flameSensor = _i1.ColumnSerializable(
      'flameSensor',
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
  }

  late final _i1.ColumnString macAddress;

  late final _i1.ColumnEnum<_i2.DeviceType> type;

  late final _i1.ColumnSerializable lightSensor;

  late final _i1.ColumnSerializable motionSensor;

  late final _i1.ColumnSerializable flameSensor;

  late final _i1.ColumnSerializable rgbLed;

  late final _i1.ColumnSerializable alarm;

  late final _i1.ColumnDateTime lastUpdate;

  @override
  List<_i1.Column> get columns => [
        id,
        macAddress,
        type,
        lightSensor,
        motionSensor,
        flameSensor,
        rgbLed,
        alarm,
        lastUpdate,
      ];
}

class LampInclude extends _i1.IncludeObject {
  LampInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table get table => Lamp.t;
}

class LampIncludeList extends _i1.IncludeList {
  LampIncludeList._({
    _i1.WhereExpressionBuilder<LampTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Lamp.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table get table => Lamp.t;
}

class LampRepository {
  const LampRepository._();

  Future<List<Lamp>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LampTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<LampTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LampTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Lamp>(
      where: where?.call(Lamp.t),
      orderBy: orderBy?.call(Lamp.t),
      orderByList: orderByList?.call(Lamp.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Lamp?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LampTable>? where,
    int? offset,
    _i1.OrderByBuilder<LampTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<LampTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Lamp>(
      where: where?.call(Lamp.t),
      orderBy: orderBy?.call(Lamp.t),
      orderByList: orderByList?.call(Lamp.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  Future<Lamp?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Lamp>(
      id,
      transaction: transaction,
    );
  }

  Future<List<Lamp>> insert(
    _i1.Session session,
    List<Lamp> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Lamp>(
      rows,
      transaction: transaction,
    );
  }

  Future<Lamp> insertRow(
    _i1.Session session,
    Lamp row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Lamp>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Lamp>> update(
    _i1.Session session,
    List<Lamp> rows, {
    _i1.ColumnSelections<LampTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Lamp>(
      rows,
      columns: columns?.call(Lamp.t),
      transaction: transaction,
    );
  }

  Future<Lamp> updateRow(
    _i1.Session session,
    Lamp row, {
    _i1.ColumnSelections<LampTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Lamp>(
      row,
      columns: columns?.call(Lamp.t),
      transaction: transaction,
    );
  }

  Future<List<Lamp>> delete(
    _i1.Session session,
    List<Lamp> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Lamp>(
      rows,
      transaction: transaction,
    );
  }

  Future<Lamp> deleteRow(
    _i1.Session session,
    Lamp row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Lamp>(
      row,
      transaction: transaction,
    );
  }

  Future<List<Lamp>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<LampTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Lamp>(
      where: where(Lamp.t),
      transaction: transaction,
    );
  }

  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<LampTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Lamp>(
      where: where?.call(Lamp.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
