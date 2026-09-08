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

abstract class PaymentAttempt
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  PaymentAttempt._({
    this.id,
    required this.orderNumber,
    required this.provider,
    required this.externalId,
    required this.amountPaise,
    required this.status,
    this.paymentMethod,
    this.rawReference,
    required this.createdAt,
  });

  factory PaymentAttempt({
    int? id,
    required String orderNumber,
    required String provider,
    required String externalId,
    required int amountPaise,
    required String status,
    String? paymentMethod,
    String? rawReference,
    required DateTime createdAt,
  }) = _PaymentAttemptImpl;

  factory PaymentAttempt.fromJson(Map<String, dynamic> jsonSerialization) {
    return PaymentAttempt(
      id: jsonSerialization['id'] as int?,
      orderNumber: jsonSerialization['orderNumber'] as String,
      provider: jsonSerialization['provider'] as String,
      externalId: jsonSerialization['externalId'] as String,
      amountPaise: jsonSerialization['amountPaise'] as int,
      status: jsonSerialization['status'] as String,
      paymentMethod: jsonSerialization['paymentMethod'] as String?,
      rawReference: jsonSerialization['rawReference'] as String?,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
    );
  }

  static final t = PaymentAttemptTable();

  static const db = PaymentAttemptRepository._();

  @override
  int? id;

  String orderNumber;

  String provider;

  String externalId;

  int amountPaise;

  String status;

  String? paymentMethod;

  String? rawReference;

  DateTime createdAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [PaymentAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  PaymentAttempt copyWith({
    int? id,
    String? orderNumber,
    String? provider,
    String? externalId,
    int? amountPaise,
    String? status,
    String? paymentMethod,
    String? rawReference,
    DateTime? createdAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'provider': provider,
      'externalId': externalId,
      'amountPaise': amountPaise,
      'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (rawReference != null) 'rawReference': rawReference,
      'createdAt': createdAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'provider': provider,
      'externalId': externalId,
      'amountPaise': amountPaise,
      'status': status,
      if (paymentMethod != null) 'paymentMethod': paymentMethod,
      if (rawReference != null) 'rawReference': rawReference,
      'createdAt': createdAt.toJson(),
    };
  }

  static PaymentAttemptInclude include() {
    return PaymentAttemptInclude._();
  }

  static PaymentAttemptIncludeList includeList({
    _i1.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PaymentAttemptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    PaymentAttemptInclude? include,
  }) {
    return PaymentAttemptIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(PaymentAttempt.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _PaymentAttemptImpl extends PaymentAttempt {
  _PaymentAttemptImpl({
    int? id,
    required String orderNumber,
    required String provider,
    required String externalId,
    required int amountPaise,
    required String status,
    String? paymentMethod,
    String? rawReference,
    required DateTime createdAt,
  }) : super._(
          id: id,
          orderNumber: orderNumber,
          provider: provider,
          externalId: externalId,
          amountPaise: amountPaise,
          status: status,
          paymentMethod: paymentMethod,
          rawReference: rawReference,
          createdAt: createdAt,
        );

  /// Returns a shallow copy of this [PaymentAttempt]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  PaymentAttempt copyWith({
    Object? id = _Undefined,
    String? orderNumber,
    String? provider,
    String? externalId,
    int? amountPaise,
    String? status,
    Object? paymentMethod = _Undefined,
    Object? rawReference = _Undefined,
    DateTime? createdAt,
  }) {
    return PaymentAttempt(
      id: id is int? ? id : this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      provider: provider ?? this.provider,
      externalId: externalId ?? this.externalId,
      amountPaise: amountPaise ?? this.amountPaise,
      status: status ?? this.status,
      paymentMethod:
          paymentMethod is String? ? paymentMethod : this.paymentMethod,
      rawReference: rawReference is String? ? rawReference : this.rawReference,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}

class PaymentAttemptTable extends _i1.Table<int?> {
  PaymentAttemptTable({super.tableRelation})
      : super(tableName: 'payment_attempt') {
    orderNumber = _i1.ColumnString(
      'orderNumber',
      this,
    );
    provider = _i1.ColumnString(
      'provider',
      this,
    );
    externalId = _i1.ColumnString(
      'externalId',
      this,
    );
    amountPaise = _i1.ColumnInt(
      'amountPaise',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    paymentMethod = _i1.ColumnString(
      'paymentMethod',
      this,
    );
    rawReference = _i1.ColumnString(
      'rawReference',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
  }

  late final _i1.ColumnString orderNumber;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString externalId;

  late final _i1.ColumnInt amountPaise;

  late final _i1.ColumnString status;

  late final _i1.ColumnString paymentMethod;

  late final _i1.ColumnString rawReference;

  late final _i1.ColumnDateTime createdAt;

  @override
  List<_i1.Column> get columns => [
        id,
        orderNumber,
        provider,
        externalId,
        amountPaise,
        status,
        paymentMethod,
        rawReference,
        createdAt,
      ];
}

class PaymentAttemptInclude extends _i1.IncludeObject {
  PaymentAttemptInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => PaymentAttempt.t;
}

class PaymentAttemptIncludeList extends _i1.IncludeList {
  PaymentAttemptIncludeList._({
    _i1.WhereExpressionBuilder<PaymentAttemptTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(PaymentAttempt.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => PaymentAttempt.t;
}

class PaymentAttemptRepository {
  const PaymentAttemptRepository._();

  /// Returns a list of [PaymentAttempt]s matching the given query parameters.
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
  Future<List<PaymentAttempt>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<PaymentAttemptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [PaymentAttempt] matching the given query parameters.
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
  Future<PaymentAttempt?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? offset,
    _i1.OrderByBuilder<PaymentAttemptTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<PaymentAttemptTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      orderBy: orderBy?.call(PaymentAttempt.t),
      orderByList: orderByList?.call(PaymentAttempt.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [PaymentAttempt] by its [id] or null if no such row exists.
  Future<PaymentAttempt?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<PaymentAttempt>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [PaymentAttempt]s in the list and returns the inserted rows.
  ///
  /// The returned [PaymentAttempt]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<PaymentAttempt>> insert(
    _i1.Session session,
    List<PaymentAttempt> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<PaymentAttempt>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [PaymentAttempt] and returns the inserted row.
  ///
  /// The returned [PaymentAttempt] will have its `id` field set.
  Future<PaymentAttempt> insertRow(
    _i1.Session session,
    PaymentAttempt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<PaymentAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [PaymentAttempt]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<PaymentAttempt>> update(
    _i1.Session session,
    List<PaymentAttempt> rows, {
    _i1.ColumnSelections<PaymentAttemptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<PaymentAttempt>(
      rows,
      columns: columns?.call(PaymentAttempt.t),
      transaction: transaction,
    );
  }

  /// Updates a single [PaymentAttempt]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<PaymentAttempt> updateRow(
    _i1.Session session,
    PaymentAttempt row, {
    _i1.ColumnSelections<PaymentAttemptTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<PaymentAttempt>(
      row,
      columns: columns?.call(PaymentAttempt.t),
      transaction: transaction,
    );
  }

  /// Deletes all [PaymentAttempt]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<PaymentAttempt>> delete(
    _i1.Session session,
    List<PaymentAttempt> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<PaymentAttempt>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [PaymentAttempt].
  Future<PaymentAttempt> deleteRow(
    _i1.Session session,
    PaymentAttempt row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<PaymentAttempt>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<PaymentAttempt>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<PaymentAttemptTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<PaymentAttempt>(
      where: where(PaymentAttempt.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<PaymentAttemptTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<PaymentAttempt>(
      where: where?.call(PaymentAttempt.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
