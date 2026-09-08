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

abstract class DeliveryJob
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  DeliveryJob._({
    this.id,
    required this.orderNumber,
    required this.provider,
    this.externalId,
    required this.quotePaise,
    required this.status,
    this.trackingUrl,
    this.riderName,
    this.riderPhone,
    required this.manualFallback,
    this.notes,
    required this.updatedAt,
  });

  factory DeliveryJob({
    int? id,
    required String orderNumber,
    required String provider,
    String? externalId,
    required int quotePaise,
    required String status,
    String? trackingUrl,
    String? riderName,
    String? riderPhone,
    required bool manualFallback,
    String? notes,
    required DateTime updatedAt,
  }) = _DeliveryJobImpl;

  factory DeliveryJob.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeliveryJob(
      id: jsonSerialization['id'] as int?,
      orderNumber: jsonSerialization['orderNumber'] as String,
      provider: jsonSerialization['provider'] as String,
      externalId: jsonSerialization['externalId'] as String?,
      quotePaise: jsonSerialization['quotePaise'] as int,
      status: jsonSerialization['status'] as String,
      trackingUrl: jsonSerialization['trackingUrl'] as String?,
      riderName: jsonSerialization['riderName'] as String?,
      riderPhone: jsonSerialization['riderPhone'] as String?,
      manualFallback: jsonSerialization['manualFallback'] as bool,
      notes: jsonSerialization['notes'] as String?,
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = DeliveryJobTable();

  static const db = DeliveryJobRepository._();

  @override
  int? id;

  String orderNumber;

  String provider;

  String? externalId;

  int quotePaise;

  String status;

  String? trackingUrl;

  String? riderName;

  String? riderPhone;

  bool manualFallback;

  String? notes;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [DeliveryJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeliveryJob copyWith({
    int? id,
    String? orderNumber,
    String? provider,
    String? externalId,
    int? quotePaise,
    String? status,
    String? trackingUrl,
    String? riderName,
    String? riderPhone,
    bool? manualFallback,
    String? notes,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'provider': provider,
      if (externalId != null) 'externalId': externalId,
      'quotePaise': quotePaise,
      'status': status,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
      if (riderName != null) 'riderName': riderName,
      if (riderPhone != null) 'riderPhone': riderPhone,
      'manualFallback': manualFallback,
      if (notes != null) 'notes': notes,
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'provider': provider,
      if (externalId != null) 'externalId': externalId,
      'quotePaise': quotePaise,
      'status': status,
      if (trackingUrl != null) 'trackingUrl': trackingUrl,
      if (riderName != null) 'riderName': riderName,
      if (riderPhone != null) 'riderPhone': riderPhone,
      'manualFallback': manualFallback,
      if (notes != null) 'notes': notes,
      'updatedAt': updatedAt.toJson(),
    };
  }

  static DeliveryJobInclude include() {
    return DeliveryJobInclude._();
  }

  static DeliveryJobIncludeList includeList({
    _i1.WhereExpressionBuilder<DeliveryJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeliveryJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeliveryJobTable>? orderByList,
    DeliveryJobInclude? include,
  }) {
    return DeliveryJobIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(DeliveryJob.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(DeliveryJob.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeliveryJobImpl extends DeliveryJob {
  _DeliveryJobImpl({
    int? id,
    required String orderNumber,
    required String provider,
    String? externalId,
    required int quotePaise,
    required String status,
    String? trackingUrl,
    String? riderName,
    String? riderPhone,
    required bool manualFallback,
    String? notes,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          orderNumber: orderNumber,
          provider: provider,
          externalId: externalId,
          quotePaise: quotePaise,
          status: status,
          trackingUrl: trackingUrl,
          riderName: riderName,
          riderPhone: riderPhone,
          manualFallback: manualFallback,
          notes: notes,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [DeliveryJob]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeliveryJob copyWith({
    Object? id = _Undefined,
    String? orderNumber,
    String? provider,
    Object? externalId = _Undefined,
    int? quotePaise,
    String? status,
    Object? trackingUrl = _Undefined,
    Object? riderName = _Undefined,
    Object? riderPhone = _Undefined,
    bool? manualFallback,
    Object? notes = _Undefined,
    DateTime? updatedAt,
  }) {
    return DeliveryJob(
      id: id is int? ? id : this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      provider: provider ?? this.provider,
      externalId: externalId is String? ? externalId : this.externalId,
      quotePaise: quotePaise ?? this.quotePaise,
      status: status ?? this.status,
      trackingUrl: trackingUrl is String? ? trackingUrl : this.trackingUrl,
      riderName: riderName is String? ? riderName : this.riderName,
      riderPhone: riderPhone is String? ? riderPhone : this.riderPhone,
      manualFallback: manualFallback ?? this.manualFallback,
      notes: notes is String? ? notes : this.notes,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class DeliveryJobTable extends _i1.Table<int?> {
  DeliveryJobTable({super.tableRelation}) : super(tableName: 'delivery_job') {
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
    quotePaise = _i1.ColumnInt(
      'quotePaise',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    trackingUrl = _i1.ColumnString(
      'trackingUrl',
      this,
    );
    riderName = _i1.ColumnString(
      'riderName',
      this,
    );
    riderPhone = _i1.ColumnString(
      'riderPhone',
      this,
    );
    manualFallback = _i1.ColumnBool(
      'manualFallback',
      this,
    );
    notes = _i1.ColumnString(
      'notes',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final _i1.ColumnString orderNumber;

  late final _i1.ColumnString provider;

  late final _i1.ColumnString externalId;

  late final _i1.ColumnInt quotePaise;

  late final _i1.ColumnString status;

  late final _i1.ColumnString trackingUrl;

  late final _i1.ColumnString riderName;

  late final _i1.ColumnString riderPhone;

  late final _i1.ColumnBool manualFallback;

  late final _i1.ColumnString notes;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        orderNumber,
        provider,
        externalId,
        quotePaise,
        status,
        trackingUrl,
        riderName,
        riderPhone,
        manualFallback,
        notes,
        updatedAt,
      ];
}

class DeliveryJobInclude extends _i1.IncludeObject {
  DeliveryJobInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => DeliveryJob.t;
}

class DeliveryJobIncludeList extends _i1.IncludeList {
  DeliveryJobIncludeList._({
    _i1.WhereExpressionBuilder<DeliveryJobTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(DeliveryJob.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => DeliveryJob.t;
}

class DeliveryJobRepository {
  const DeliveryJobRepository._();

  /// Returns a list of [DeliveryJob]s matching the given query parameters.
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
  Future<List<DeliveryJob>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeliveryJobTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<DeliveryJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeliveryJobTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<DeliveryJob>(
      where: where?.call(DeliveryJob.t),
      orderBy: orderBy?.call(DeliveryJob.t),
      orderByList: orderByList?.call(DeliveryJob.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [DeliveryJob] matching the given query parameters.
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
  Future<DeliveryJob?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeliveryJobTable>? where,
    int? offset,
    _i1.OrderByBuilder<DeliveryJobTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<DeliveryJobTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<DeliveryJob>(
      where: where?.call(DeliveryJob.t),
      orderBy: orderBy?.call(DeliveryJob.t),
      orderByList: orderByList?.call(DeliveryJob.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [DeliveryJob] by its [id] or null if no such row exists.
  Future<DeliveryJob?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<DeliveryJob>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [DeliveryJob]s in the list and returns the inserted rows.
  ///
  /// The returned [DeliveryJob]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<DeliveryJob>> insert(
    _i1.Session session,
    List<DeliveryJob> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<DeliveryJob>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [DeliveryJob] and returns the inserted row.
  ///
  /// The returned [DeliveryJob] will have its `id` field set.
  Future<DeliveryJob> insertRow(
    _i1.Session session,
    DeliveryJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<DeliveryJob>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [DeliveryJob]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<DeliveryJob>> update(
    _i1.Session session,
    List<DeliveryJob> rows, {
    _i1.ColumnSelections<DeliveryJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<DeliveryJob>(
      rows,
      columns: columns?.call(DeliveryJob.t),
      transaction: transaction,
    );
  }

  /// Updates a single [DeliveryJob]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<DeliveryJob> updateRow(
    _i1.Session session,
    DeliveryJob row, {
    _i1.ColumnSelections<DeliveryJobTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<DeliveryJob>(
      row,
      columns: columns?.call(DeliveryJob.t),
      transaction: transaction,
    );
  }

  /// Deletes all [DeliveryJob]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<DeliveryJob>> delete(
    _i1.Session session,
    List<DeliveryJob> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<DeliveryJob>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [DeliveryJob].
  Future<DeliveryJob> deleteRow(
    _i1.Session session,
    DeliveryJob row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<DeliveryJob>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<DeliveryJob>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<DeliveryJobTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<DeliveryJob>(
      where: where(DeliveryJob.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<DeliveryJobTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<DeliveryJob>(
      where: where?.call(DeliveryJob.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
