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

abstract class RefundRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  RefundRecord._({
    this.id,
    required this.orderNumber,
    required this.amountPaise,
    required this.reason,
    required this.status,
    this.providerReference,
    required this.createdAt,
  });

  factory RefundRecord({
    int? id,
    required String orderNumber,
    required int amountPaise,
    required String reason,
    required String status,
    String? providerReference,
    required DateTime createdAt,
  }) = _RefundRecordImpl;

  factory RefundRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return RefundRecord(
      id: jsonSerialization['id'] as int?,
      orderNumber: jsonSerialization['orderNumber'] as String,
      amountPaise: jsonSerialization['amountPaise'] as int,
      reason: jsonSerialization['reason'] as String,
      status: jsonSerialization['status'] as String,
      providerReference: jsonSerialization['providerReference'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = RefundRecordTable();

  static const db = RefundRecordRepository._();

  @override
  int? id;

  String orderNumber;

  int amountPaise;

  String reason;

  String status;

  String? providerReference;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [RefundRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  RefundRecord copyWith({
    int? id,
    String? orderNumber,
    int? amountPaise,
    String? reason,
    String? status,
    String? providerReference,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'amountPaise': amountPaise,
      'reason': reason,
      'status': status,
      if (providerReference != null) 'providerReference': providerReference,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'amountPaise': amountPaise,
      'reason': reason,
      'status': status,
      if (providerReference != null) 'providerReference': providerReference,
      'createdAt': createdAt.toJson(),
    };
  }

  static RefundRecordInclude include() {
    return RefundRecordInclude._();
  }

  static RefundRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<RefundRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RefundRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundRecordTable>? orderByList,
    RefundRecordInclude? include,
  }) {
    return RefundRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(RefundRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(RefundRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _RefundRecordImpl extends RefundRecord {
  _RefundRecordImpl({
    int? id,
    required String orderNumber,
    required int amountPaise,
    required String reason,
    required String status,
    String? providerReference,
    required DateTime createdAt,
  }) : super._(
          id: id,
          orderNumber: orderNumber,
          amountPaise: amountPaise,
          reason: reason,
          status: status,
          providerReference: providerReference,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [RefundRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  RefundRecord copyWith({
    Object? id = _Undefined,
    String? orderNumber,
    int? amountPaise,
    String? reason,
    String? status,
    Object? providerReference = _Undefined,
    DateTime? createdAt,
  }) {
    return RefundRecord(
      id: id is int? ? id : this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      amountPaise: amountPaise ?? this.amountPaise,
      reason: reason ?? this.reason,
      status: status ?? this.status,
      providerReference: providerReference is String?
          ? providerReference
          : this.providerReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class RefundRecordTable extends _i1.Table<int?> {
  RefundRecordTable({super.tableRelation}) : super(tableName: 'refund_record') {
    orderNumber = _i1.ColumnString(
      'orderNumber',
      this,
    );
    amountPaise = _i1.ColumnInt(
      'amountPaise',
      this,
    );
    reason = _i1.ColumnString(
      'reason',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    providerReference = _i1.ColumnString(
      'providerReference',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final _i1.ColumnString orderNumber;

  late final _i1.ColumnInt amountPaise;

  late final _i1.ColumnString reason;

  late final _i1.ColumnString status;

  late final _i1.ColumnString providerReference;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        orderNumber,
        amountPaise,
        reason,
        status,
        providerReference,
        createdAt,
      ];
}

class RefundRecordInclude extends _i1.IncludeObject {
  RefundRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => RefundRecord.t;
}

class RefundRecordIncludeList extends _i1.IncludeList {
  RefundRecordIncludeList._({
    _i1.WhereExpressionBuilder<RefundRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(RefundRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => RefundRecord.t;
}

class RefundRecordRepository {
  const RefundRecordRepository._();

  /// Returns a list of [RefundRecord]s matching the given query parameters.
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
  Future<List<RefundRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<RefundRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<RefundRecord>(
      where: where?.call(RefundRecord.t),
      orderBy: orderBy?.call(RefundRecord.t),
      orderByList: orderByList?.call(RefundRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [RefundRecord] matching the given query parameters.
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
  Future<RefundRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<RefundRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<RefundRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<RefundRecord>(
      where: where?.call(RefundRecord.t),
      orderBy: orderBy?.call(RefundRecord.t),
      orderByList: orderByList?.call(RefundRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [RefundRecord] by its [id] or null if no such row exists.
  Future<RefundRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<RefundRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [RefundRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [RefundRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<RefundRecord>> insert(
    _i1.Session session,
    List<RefundRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<RefundRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [RefundRecord] and returns the inserted row.
  ///
  /// The returned [RefundRecord] will have its `id` field set.
  Future<RefundRecord> insertRow(
    _i1.Session session,
    RefundRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<RefundRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [RefundRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<RefundRecord>> update(
    _i1.Session session,
    List<RefundRecord> rows, {
    _i1.ColumnSelections<RefundRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<RefundRecord>(
      rows,
      columns: columns?.call(RefundRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [RefundRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<RefundRecord> updateRow(
    _i1.Session session,
    RefundRecord row, {
    _i1.ColumnSelections<RefundRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<RefundRecord>(
      row,
      columns: columns?.call(RefundRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [RefundRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<RefundRecord>> delete(
    _i1.Session session,
    List<RefundRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<RefundRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [RefundRecord].
  Future<RefundRecord> deleteRow(
    _i1.Session session,
    RefundRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<RefundRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<RefundRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<RefundRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<RefundRecord>(
      where: where(RefundRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<RefundRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<RefundRecord>(
      where: where?.call(RefundRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
