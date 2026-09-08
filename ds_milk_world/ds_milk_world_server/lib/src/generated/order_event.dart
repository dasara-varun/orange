/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod/serverpod.dart' as _i1;

abstract class OrderEvent
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OrderEvent._({
    this.id,
    required this.orderNumber,
    required this.type,
    required this.actorType,
    this.actorId,
    this.payload,
    required this.timestamp,
  });

  factory OrderEvent({
    int? id,
    required String orderNumber,
    required String type,
    required String actorType,
    String? actorId,
    String? payload,
    required DateTime timestamp,
  }) = _OrderEventImpl;

  factory OrderEvent.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderEvent(
      id: jsonSerialization['id'] as int?,
      orderNumber: jsonSerialization['orderNumber'] as String,
      type: jsonSerialization['type'] as String,
      actorType: jsonSerialization['actorType'] as String,
      actorId: jsonSerialization['actorId'] as String?,
      payload: jsonSerialization['payload'] as String?,
      timestamp:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['timestamp']),
    );
  }

  static final t = OrderEventTable();

  static const db = OrderEventRepository._();

  @override
  int? id;

  String orderNumber;

  String type;

  String actorType;

  String? actorId;

  String? payload;

  DateTime timestamp;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OrderEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderEvent copyWith({
    int? id,
    String? orderNumber,
    String? type,
    String? actorType,
    String? actorId,
    String? payload,
    DateTime? timestamp,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'type': type,
      'actorType': actorType,
      if (actorId != null) 'actorId': actorId,
      if (payload != null) 'payload': payload,
      'timestamp': timestamp.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'type': type,
      'actorType': actorType,
      if (actorId != null) 'actorId': actorId,
      if (payload != null) 'payload': payload,
      'timestamp': timestamp.toJson(),
    };
  }

  static OrderEventInclude include() {
    return OrderEventInclude._();
  }

  static OrderEventIncludeList includeList({
    _i1.WhereExpressionBuilder<OrderEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderEventTable>? orderByList,
    OrderEventInclude? include,
  }) {
    return OrderEventIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderEvent.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OrderEvent.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderEventImpl extends OrderEvent {
  _OrderEventImpl({
    int? id,
    required String orderNumber,
    required String type,
    required String actorType,
    String? actorId,
    String? payload,
    required DateTime timestamp,
  }) : super._(
          id: id,
          orderNumber: orderNumber,
          type: type,
          actorType: actorType,
          actorId: actorId,
          payload: payload,
          timestamp: timestamp,
        );

  /// Returns a shallow copy of this [OrderEvent]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderEvent copyWith({
    Object? id = _Undefined,
    String? orderNumber,
    String? type,
    String? actorType,
    Object? actorId = _Undefined,
    Object? payload = _Undefined,
    DateTime? timestamp,
  }) {
    return OrderEvent(
      id: id is int? ? id : this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      type: type ?? this.type,
      actorType: actorType ?? this.actorType,
      actorId: actorId is String? ? actorId : this.actorId,
      payload: payload is String? ? payload : this.payload,
      timestamp: timestamp ?? this.timestamp,
    );
  }
}

class OrderEventTable extends _i1.Table<int?> {
  OrderEventTable({super.tableRelation}) : super(tableName: 'order_event') {
    orderNumber = _i1.ColumnString(
      'orderNumber',
      this,
    );
    type = _i1.ColumnString(
      'type',
      this,
    );
    actorType = _i1.ColumnString(
      'actorType',
      this,
    );
    actorId = _i1.ColumnString(
      'actorId',
      this,
    );
    payload = _i1.ColumnString(
      'payload',
      this,
    );
    timestamp = _i1.ColumnDateTime(
      'timestamp',
      this,
    );
  }

  late final _i1.ColumnString orderNumber;

  late final _i1.ColumnString type;

  late final _i1.ColumnString actorType;

  late final _i1.ColumnString actorId;

  late final _i1.ColumnString payload;

  late final _i1.ColumnDateTime timestamp;

  @override
  List<_i1.Column> get columns => [
        id,
        orderNumber,
        type,
        actorType,
        actorId,
        payload,
        timestamp,
      ];
}

class OrderEventInclude extends _i1.IncludeObject {
  OrderEventInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OrderEvent.t;
}

class OrderEventIncludeList extends _i1.IncludeList {
  OrderEventIncludeList._({
    _i1.WhereExpressionBuilder<OrderEventTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OrderEvent.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OrderEvent.t;
}

class OrderEventRepository {
  const OrderEventRepository._();

  /// Returns a list of [OrderEvent]s matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order of the items use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// The maximum number of items can be set by [limit]. If no limit is set,
  /// all items matching the query will be returned.
  ///
  /// [offset] defines how many items to skip, after which [limit] (or all)
  /// items are read from the database.
  ///
  /// ```dart
  /// var persons = await Persons.db.find(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.firstName,
  ///   limit: 100,
  /// );
  /// ```
  Future<List<OrderEvent>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderEventTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<OrderEvent>(
      where: where?.call(OrderEvent.t),
      orderBy: orderBy?.call(OrderEvent.t),
      orderByList: orderByList?.call(OrderEvent.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [OrderEvent] matching the given query parameters.
  ///
  /// Use [where] to specify which items to include in the return value.
  /// If none is specified, all items will be returned.
  ///
  /// To specify the order use [orderBy] or [orderByList]
  /// when sorting by multiple columns.
  ///
  /// [offset] defines how many items to skip, after which the next one will be picked.
  ///
  /// ```dart
  /// var youngestPerson = await Persons.db.findFirstRow(
  ///   session,
  ///   where: (t) => t.lastName.equals('Jones'),
  ///   orderBy: (t) => t.age,
  /// );
  /// ```
  Future<OrderEvent?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderEventTable>? where,
    int? offset,
    _i1.OrderByBuilder<OrderEventTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderEventTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<OrderEvent>(
      where: where?.call(OrderEvent.t),
      orderBy: orderBy?.call(OrderEvent.t),
      orderByList: orderByList?.call(OrderEvent.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [OrderEvent] by its [id] or null if no such row exists.
  Future<OrderEvent?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<OrderEvent>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [OrderEvent]s in the list and returns the inserted rows.
  ///
  /// The returned [OrderEvent]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<OrderEvent>> insert(
    _i1.Session session,
    List<OrderEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<OrderEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [OrderEvent] and returns the inserted row.
  ///
  /// The returned [OrderEvent] will have its `id` field set.
  Future<OrderEvent> insertRow(
    _i1.Session session,
    OrderEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OrderEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OrderEvent]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OrderEvent>> update(
    _i1.Session session,
    List<OrderEvent> rows, {
    _i1.ColumnSelections<OrderEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OrderEvent>(
      rows,
      columns: columns?.call(OrderEvent.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrderEvent]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OrderEvent> updateRow(
    _i1.Session session,
    OrderEvent row, {
    _i1.ColumnSelections<OrderEventTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OrderEvent>(
      row,
      columns: columns?.call(OrderEvent.t),
      transaction: transaction,
    );
  }

  /// Deletes all [OrderEvent]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OrderEvent>> delete(
    _i1.Session session,
    List<OrderEvent> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OrderEvent>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OrderEvent].
  Future<OrderEvent> deleteRow(
    _i1.Session session,
    OrderEvent row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OrderEvent>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OrderEvent>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<OrderEventTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OrderEvent>(
      where: where(OrderEvent.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderEventTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OrderEvent>(
      where: where?.call(OrderEvent.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
