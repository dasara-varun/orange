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
import 'order_item.dart' as _i2;

abstract class OrderRecord
    implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  OrderRecord._({
    this.id,
    required this.orderNumber,
    required this.customerPhone,
    this.customerName,
    required this.deliveryAddress,
    this.landmark,
    required this.latitude,
    required this.longitude,
    required this.distanceKm,
    required this.status,
    required this.subtotalPaise,
    required this.deliveryFeePaise,
    required this.totalPaise,
    required this.currency,
    required this.items,
    this.prepTimeMinutes,
    this.rejectionReason,
    required this.packingChecklistConfirmed,
    required this.createdAt,
    required this.updatedAt,
  });

  factory OrderRecord({
    int? id,
    required String orderNumber,
    required String customerPhone,
    String? customerName,
    required String deliveryAddress,
    String? landmark,
    required double latitude,
    required double longitude,
    required double distanceKm,
    required String status,
    required int subtotalPaise,
    required int deliveryFeePaise,
    required int totalPaise,
    required String currency,
    required List<_i2.OrderItem> items,
    int? prepTimeMinutes,
    String? rejectionReason,
    required bool packingChecklistConfirmed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) = _OrderRecordImpl;

  factory OrderRecord.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderRecord(
      id: jsonSerialization['id'] as int?,
      orderNumber: jsonSerialization['orderNumber'] as String,
      customerPhone: jsonSerialization['customerPhone'] as String,
      customerName: jsonSerialization['customerName'] as String?,
      deliveryAddress: jsonSerialization['deliveryAddress'] as String,
      landmark: jsonSerialization['landmark'] as String?,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      distanceKm: (jsonSerialization['distanceKm'] as num).toDouble(),
      status: jsonSerialization['status'] as String,
      subtotalPaise: jsonSerialization['subtotalPaise'] as int,
      deliveryFeePaise: jsonSerialization['deliveryFeePaise'] as int,
      totalPaise: jsonSerialization['totalPaise'] as int,
      currency: jsonSerialization['currency'] as String,
      items: (jsonSerialization['items'] as List)
          .map((e) => _i2.OrderItem.fromJson((e as Map<String, dynamic>)))
          .toList(),
      prepTimeMinutes: jsonSerialization['prepTimeMinutes'] as int?,
      rejectionReason: jsonSerialization['rejectionReason'] as String?,
      packingChecklistConfirmed:
          jsonSerialization['packingChecklistConfirmed'] as bool,
      createdAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['createdAt']),
      updatedAt:
          _i1.DateTimeJsonExtension.fromJson(jsonSerialization['updatedAt']),
    );
  }

  static final t = OrderRecordTable();

  static const db = OrderRecordRepository._();

  @override
  int? id;

  String orderNumber;

  String customerPhone;

  String? customerName;

  String deliveryAddress;

  String? landmark;

  double latitude;

  double longitude;

  double distanceKm;

  String status;

  int subtotalPaise;

  int deliveryFeePaise;

  int totalPaise;

  String currency;

  List<_i2.OrderItem> items;

  int? prepTimeMinutes;

  String? rejectionReason;

  bool packingChecklistConfirmed;

  DateTime createdAt;

  DateTime updatedAt;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [OrderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderRecord copyWith({
    int? id,
    String? orderNumber,
    String? customerPhone,
    String? customerName,
    String? deliveryAddress,
    String? landmark,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? status,
    int? subtotalPaise,
    int? deliveryFeePaise,
    int? totalPaise,
    String? currency,
    List<_i2.OrderItem>? items,
    int? prepTimeMinutes,
    String? rejectionReason,
    bool? packingChecklistConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'customerPhone': customerPhone,
      if (customerName != null) 'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      if (landmark != null) 'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'status': status,
      'subtotalPaise': subtotalPaise,
      'deliveryFeePaise': deliveryFeePaise,
      'totalPaise': totalPaise,
      'currency': currency,
      'items': items.toJson(valueToJson: (v) => v.toJson()),
      if (prepTimeMinutes != null) 'prepTimeMinutes': prepTimeMinutes,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'packingChecklistConfirmed': packingChecklistConfirmed,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'orderNumber': orderNumber,
      'customerPhone': customerPhone,
      if (customerName != null) 'customerName': customerName,
      'deliveryAddress': deliveryAddress,
      if (landmark != null) 'landmark': landmark,
      'latitude': latitude,
      'longitude': longitude,
      'distanceKm': distanceKm,
      'status': status,
      'subtotalPaise': subtotalPaise,
      'deliveryFeePaise': deliveryFeePaise,
      'totalPaise': totalPaise,
      'currency': currency,
      'items': items.toJson(valueToJson: (v) => v.toJsonForProtocol()),
      if (prepTimeMinutes != null) 'prepTimeMinutes': prepTimeMinutes,
      if (rejectionReason != null) 'rejectionReason': rejectionReason,
      'packingChecklistConfirmed': packingChecklistConfirmed,
      'createdAt': createdAt.toJson(),
      'updatedAt': updatedAt.toJson(),
    };
  }

  static OrderRecordInclude include() {
    return OrderRecordInclude._();
  }

  static OrderRecordIncludeList includeList({
    _i1.WhereExpressionBuilder<OrderRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderRecordTable>? orderByList,
    OrderRecordInclude? include,
  }) {
    return OrderRecordIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(OrderRecord.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(OrderRecord.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderRecordImpl extends OrderRecord {
  _OrderRecordImpl({
    int? id,
    required String orderNumber,
    required String customerPhone,
    String? customerName,
    required String deliveryAddress,
    String? landmark,
    required double latitude,
    required double longitude,
    required double distanceKm,
    required String status,
    required int subtotalPaise,
    required int deliveryFeePaise,
    required int totalPaise,
    required String currency,
    required List<_i2.OrderItem> items,
    int? prepTimeMinutes,
    String? rejectionReason,
    required bool packingChecklistConfirmed,
    required DateTime createdAt,
    required DateTime updatedAt,
  }) : super._(
          id: id,
          orderNumber: orderNumber,
          customerPhone: customerPhone,
          customerName: customerName,
          deliveryAddress: deliveryAddress,
          landmark: landmark,
          latitude: latitude,
          longitude: longitude,
          distanceKm: distanceKm,
          status: status,
          subtotalPaise: subtotalPaise,
          deliveryFeePaise: deliveryFeePaise,
          totalPaise: totalPaise,
          currency: currency,
          items: items,
          prepTimeMinutes: prepTimeMinutes,
          rejectionReason: rejectionReason,
          packingChecklistConfirmed: packingChecklistConfirmed,
          createdAt: createdAt,
          updatedAt: updatedAt,
        );

  /// Returns a shallow copy of this [OrderRecord]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderRecord copyWith({
    Object? id = _Undefined,
    String? orderNumber,
    String? customerPhone,
    Object? customerName = _Undefined,
    String? deliveryAddress,
    Object? landmark = _Undefined,
    double? latitude,
    double? longitude,
    double? distanceKm,
    String? status,
    int? subtotalPaise,
    int? deliveryFeePaise,
    int? totalPaise,
    String? currency,
    List<_i2.OrderItem>? items,
    Object? prepTimeMinutes = _Undefined,
    Object? rejectionReason = _Undefined,
    bool? packingChecklistConfirmed,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return OrderRecord(
      id: id is int? ? id : this.id,
      orderNumber: orderNumber ?? this.orderNumber,
      customerPhone: customerPhone ?? this.customerPhone,
      customerName: customerName is String? ? customerName : this.customerName,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      landmark: landmark is String? ? landmark : this.landmark,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      distanceKm: distanceKm ?? this.distanceKm,
      status: status ?? this.status,
      subtotalPaise: subtotalPaise ?? this.subtotalPaise,
      deliveryFeePaise: deliveryFeePaise ?? this.deliveryFeePaise,
      totalPaise: totalPaise ?? this.totalPaise,
      currency: currency ?? this.currency,
      items: items ?? this.items.map((e0) => e0.copyWith()).toList(),
      prepTimeMinutes:
          prepTimeMinutes is int? ? prepTimeMinutes : this.prepTimeMinutes,
      rejectionReason:
          rejectionReason is String? ? rejectionReason : this.rejectionReason,
      packingChecklistConfirmed:
          packingChecklistConfirmed ?? this.packingChecklistConfirmed,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}

class OrderRecordTable extends _i1.Table<int?> {
  OrderRecordTable({super.tableRelation}) : super(tableName: 'order_record') {
    orderNumber = _i1.ColumnString(
      'orderNumber',
      this,
    );
    customerPhone = _i1.ColumnString(
      'customerPhone',
      this,
    );
    customerName = _i1.ColumnString(
      'customerName',
      this,
    );
    deliveryAddress = _i1.ColumnString(
      'deliveryAddress',
      this,
    );
    landmark = _i1.ColumnString(
      'landmark',
      this,
    );
    latitude = _i1.ColumnDouble(
      'latitude',
      this,
    );
    longitude = _i1.ColumnDouble(
      'longitude',
      this,
    );
    distanceKm = _i1.ColumnDouble(
      'distanceKm',
      this,
    );
    status = _i1.ColumnString(
      'status',
      this,
    );
    subtotalPaise = _i1.ColumnInt(
      'subtotalPaise',
      this,
    );
    deliveryFeePaise = _i1.ColumnInt(
      'deliveryFeePaise',
      this,
    );
    totalPaise = _i1.ColumnInt(
      'totalPaise',
      this,
    );
    currency = _i1.ColumnString(
      'currency',
      this,
    );
    items = _i1.ColumnSerializable(
      'items',
      this,
    );
    prepTimeMinutes = _i1.ColumnInt(
      'prepTimeMinutes',
      this,
    );
    rejectionReason = _i1.ColumnString(
      'rejectionReason',
      this,
    );
    packingChecklistConfirmed = _i1.ColumnBool(
      'packingChecklistConfirmed',
      this,
    );
    createdAt = _i1.ColumnDateTime(
      'createdAt',
      this,
    );
    updatedAt = _i1.ColumnDateTime(
      'updatedAt',
      this,
    );
  }

  late final _i1.ColumnString orderNumber;

  late final _i1.ColumnString customerPhone;

  late final _i1.ColumnString customerName;

  late final _i1.ColumnString deliveryAddress;

  late final _i1.ColumnString landmark;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnDouble distanceKm;

  late final _i1.ColumnString status;

  late final _i1.ColumnInt subtotalPaise;

  late final _i1.ColumnInt deliveryFeePaise;

  late final _i1.ColumnInt totalPaise;

  late final _i1.ColumnString currency;

  late final _i1.ColumnSerializable items;

  late final _i1.ColumnInt prepTimeMinutes;

  late final _i1.ColumnString rejectionReason;

  late final _i1.ColumnBool packingChecklistConfirmed;

  late final _i1.ColumnDateTime createdAt;

  late final _i1.ColumnDateTime updatedAt;

  @override
  List<_i1.Column> get columns => [
        id,
        orderNumber,
        customerPhone,
        customerName,
        deliveryAddress,
        landmark,
        latitude,
        longitude,
        distanceKm,
        status,
        subtotalPaise,
        deliveryFeePaise,
        totalPaise,
        currency,
        items,
        prepTimeMinutes,
        rejectionReason,
        packingChecklistConfirmed,
        createdAt,
        updatedAt,
      ];
}

class OrderRecordInclude extends _i1.IncludeObject {
  OrderRecordInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => OrderRecord.t;
}

class OrderRecordIncludeList extends _i1.IncludeList {
  OrderRecordIncludeList._({
    _i1.WhereExpressionBuilder<OrderRecordTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(OrderRecord.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => OrderRecord.t;
}

class OrderRecordRepository {
  const OrderRecordRepository._();

  /// Returns a list of [OrderRecord]s matching the given query parameters.
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
  Future<List<OrderRecord>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderRecordTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OrderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<OrderRecord>(
      where: where?.call(OrderRecord.t),
      orderBy: orderBy?.call(OrderRecord.t),
      orderByList: orderByList?.call(OrderRecord.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [OrderRecord] matching the given query parameters.
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
  Future<OrderRecord?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderRecordTable>? where,
    int? offset,
    _i1.OrderByBuilder<OrderRecordTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OrderRecordTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<OrderRecord>(
      where: where?.call(OrderRecord.t),
      orderBy: orderBy?.call(OrderRecord.t),
      orderByList: orderByList?.call(OrderRecord.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [OrderRecord] by its [id] or null if no such row exists.
  Future<OrderRecord?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<OrderRecord>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [OrderRecord]s in the list and returns the inserted rows.
  ///
  /// The returned [OrderRecord]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<OrderRecord>> insert(
    _i1.Session session,
    List<OrderRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<OrderRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [OrderRecord] and returns the inserted row.
  ///
  /// The returned [OrderRecord] will have its `id` field set.
  Future<OrderRecord> insertRow(
    _i1.Session session,
    OrderRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<OrderRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [OrderRecord]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<OrderRecord>> update(
    _i1.Session session,
    List<OrderRecord> rows, {
    _i1.ColumnSelections<OrderRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<OrderRecord>(
      rows,
      columns: columns?.call(OrderRecord.t),
      transaction: transaction,
    );
  }

  /// Updates a single [OrderRecord]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<OrderRecord> updateRow(
    _i1.Session session,
    OrderRecord row, {
    _i1.ColumnSelections<OrderRecordTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<OrderRecord>(
      row,
      columns: columns?.call(OrderRecord.t),
      transaction: transaction,
    );
  }

  /// Deletes all [OrderRecord]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<OrderRecord>> delete(
    _i1.Session session,
    List<OrderRecord> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<OrderRecord>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [OrderRecord].
  Future<OrderRecord> deleteRow(
    _i1.Session session,
    OrderRecord row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<OrderRecord>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<OrderRecord>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<OrderRecordTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<OrderRecord>(
      where: where(OrderRecord.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OrderRecordTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<OrderRecord>(
      where: where?.call(OrderRecord.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
