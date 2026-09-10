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

abstract class Outlet implements _i1.TableRow<int?>, _i1.ProtocolSerialization {
  Outlet._({
    this.id,
    required this.name,
    required this.phone,
    required this.address,
    required this.latitude,
    required this.longitude,
    required this.status,
    required this.serviceRadiusM,
    required this.timezone,
    required this.openingTime,
    required this.closingTime,
    required this.minOrderPaise,
    this.staffPin,
  });

  factory Outlet({
    int? id,
    required String name,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required String status,
    required int serviceRadiusM,
    required String timezone,
    required String openingTime,
    required String closingTime,
    required int minOrderPaise,
    String? staffPin,
  }) = _OutletImpl;

  factory Outlet.fromJson(Map<String, dynamic> jsonSerialization) {
    return Outlet(
      id: jsonSerialization['id'] as int?,
      name: jsonSerialization['name'] as String,
      phone: jsonSerialization['phone'] as String,
      address: jsonSerialization['address'] as String,
      latitude: (jsonSerialization['latitude'] as num).toDouble(),
      longitude: (jsonSerialization['longitude'] as num).toDouble(),
      status: jsonSerialization['status'] as String,
      serviceRadiusM: jsonSerialization['serviceRadiusM'] as int,
      timezone: jsonSerialization['timezone'] as String,
      openingTime: jsonSerialization['openingTime'] as String,
      closingTime: jsonSerialization['closingTime'] as String,
      minOrderPaise: jsonSerialization['minOrderPaise'] as int,
      staffPin: jsonSerialization['staffPin'] as String?,
    );
  }

  static final t = OutletTable();

  static const db = OutletRepository._();

  @override
  int? id;

  String name;

  String phone;

  String address;

  double latitude;

  double longitude;

  String status;

  int serviceRadiusM;

  String timezone;

  String openingTime;

  String closingTime;

  int minOrderPaise;

  String? staffPin;

  @override
  _i1.Table<int?> get table => t;

  /// Returns a shallow copy of this [Outlet]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Outlet copyWith({
    int? id,
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? status,
    int? serviceRadiusM,
    String? timezone,
    String? openingTime,
    String? closingTime,
    int? minOrderPaise,
    String? staffPin,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'serviceRadiusM': serviceRadiusM,
      'timezone': timezone,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'minOrderPaise': minOrderPaise,
      if (staffPin != null) 'staffPin': staffPin,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      if (id != null) 'id': id,
      'name': name,
      'phone': phone,
      'address': address,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'serviceRadiusM': serviceRadiusM,
      'timezone': timezone,
      'openingTime': openingTime,
      'closingTime': closingTime,
      'minOrderPaise': minOrderPaise,
      if (staffPin != null) 'staffPin': staffPin,
    };
  }

  static OutletInclude include() {
    return OutletInclude._();
  }

  static OutletIncludeList includeList({
    _i1.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OutletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutletTable>? orderByList,
    OutletInclude? include,
  }) {
    return OutletIncludeList._(
      where: where,
      limit: limit,
      offset: offset,
      orderBy: orderBy?.call(Outlet.t),
      orderDescending: orderDescending,
      orderByList: orderByList?.call(Outlet.t),
      include: include,
    );
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OutletImpl extends Outlet {
  _OutletImpl({
    int? id,
    required String name,
    required String phone,
    required String address,
    required double latitude,
    required double longitude,
    required String status,
    required int serviceRadiusM,
    required String timezone,
    required String openingTime,
    required String closingTime,
    required int minOrderPaise,
    String? staffPin,
  }) : super._(
          id: id,
          name: name,
          phone: phone,
          address: address,
          latitude: latitude,
          longitude: longitude,
          status: status,
          serviceRadiusM: serviceRadiusM,
          timezone: timezone,
          openingTime: openingTime,
          closingTime: closingTime,
          minOrderPaise: minOrderPaise,
          staffPin: staffPin,
        );

  /// Returns a shallow copy of this [Outlet]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Outlet copyWith({
    Object? id = _Undefined,
    String? name,
    String? phone,
    String? address,
    double? latitude,
    double? longitude,
    String? status,
    int? serviceRadiusM,
    String? timezone,
    String? openingTime,
    String? closingTime,
    int? minOrderPaise,
    Object? staffPin = _Undefined,
  }) {
    return Outlet(
      id: id is int? ? id : this.id,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      address: address ?? this.address,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      serviceRadiusM: serviceRadiusM ?? this.serviceRadiusM,
      timezone: timezone ?? this.timezone,
      openingTime: openingTime ?? this.openingTime,
      closingTime: closingTime ?? this.closingTime,
      minOrderPaise: minOrderPaise ?? this.minOrderPaise,
      staffPin: staffPin is String? ? staffPin : this.staffPin,
    );
  }
}

class OutletTable extends _i1.Table<int?> {
  OutletTable({super.tableRelation}) : super(tableName: 'outlet') {
    name = _i1.ColumnString(
      'name',
      this,
    );
    phone = _i1.ColumnString(
      'phone',
      this,
    );
    address = _i1.ColumnString(
      'address',
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
    status = _i1.ColumnString(
      'status',
      this,
    );
    serviceRadiusM = _i1.ColumnInt(
      'serviceRadiusM',
      this,
    );
    timezone = _i1.ColumnString(
      'timezone',
      this,
    );
    openingTime = _i1.ColumnString(
      'openingTime',
      this,
    );
    closingTime = _i1.ColumnString(
      'closingTime',
      this,
    );
    minOrderPaise = _i1.ColumnInt(
      'minOrderPaise',
      this,
    );
    staffPin = _i1.ColumnString(
      'staffPin',
      this,
    );
  }

  late final _i1.ColumnString name;

  late final _i1.ColumnString phone;

  late final _i1.ColumnString address;

  late final _i1.ColumnDouble latitude;

  late final _i1.ColumnDouble longitude;

  late final _i1.ColumnString status;

  late final _i1.ColumnInt serviceRadiusM;

  late final _i1.ColumnString timezone;

  late final _i1.ColumnString openingTime;

  late final _i1.ColumnString closingTime;

  late final _i1.ColumnInt minOrderPaise;

  late final _i1.ColumnString staffPin;

  @override
  List<_i1.Column> get columns => [
        id,
        name,
        phone,
        address,
        latitude,
        longitude,
        status,
        serviceRadiusM,
        timezone,
        openingTime,
        closingTime,
        minOrderPaise,
        staffPin,
      ];
}

class OutletInclude extends _i1.IncludeObject {
  OutletInclude._();

  @override
  Map<String, _i1.Include?> get includes => {};

  @override
  _i1.Table<int?> get table => Outlet.t;
}

class OutletIncludeList extends _i1.IncludeList {
  OutletIncludeList._({
    _i1.WhereExpressionBuilder<OutletTable>? where,
    super.limit,
    super.offset,
    super.orderBy,
    super.orderDescending,
    super.orderByList,
    super.include,
  }) {
    super.where = where?.call(Outlet.t);
  }

  @override
  Map<String, _i1.Include?> get includes => include?.includes ?? {};

  @override
  _i1.Table<int?> get table => Outlet.t;
}

class OutletRepository {
  const OutletRepository._();

  /// Returns a list of [Outlet]s matching the given query parameters.
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
  Future<List<Outlet>> find(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    int? offset,
    _i1.OrderByBuilder<OutletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutletTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.find<Outlet>(
      where: where?.call(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      orderDescending: orderDescending,
      limit: limit,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Returns the first matching [Outlet] matching the given query parameters.
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
  Future<Outlet?> findFirstRow(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OutletTable>? where,
    int? offset,
    _i1.OrderByBuilder<OutletTable>? orderBy,
    bool orderDescending = false,
    _i1.OrderByListBuilder<OutletTable>? orderByList,
    _i1.Transaction? transaction,
  }) async {
    return session.db.findFirstRow<Outlet>(
      where: where?.call(Outlet.t),
      orderBy: orderBy?.call(Outlet.t),
      orderByList: orderByList?.call(Outlet.t),
      orderDescending: orderDescending,
      offset: offset,
      transaction: transaction,
    );
  }

  /// Finds a single [Outlet] by its [id] or null if no such row exists.
  Future<Outlet?> findById(
    _i1.Session session,
    int id, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.findById<Outlet>(
      id,
      transaction: transaction,
    );
  }

  /// Inserts all [Outlet]s in the list and returns the inserted rows.
  ///
  /// The returned [Outlet]s will have their `id` fields set.
  ///
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// insert, none of the rows will be inserted.
  Future<List<Outlet>> insert(
    _i1.Session session,
    List<Outlet> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insert<Outlet>(
      rows,
      transaction: transaction,
    );
  }

  /// Inserts a single [Outlet] and returns the inserted row.
  ///
  /// The returned [Outlet] will have its `id` field set.
  Future<Outlet> insertRow(
    _i1.Session session,
    Outlet row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.insertRow<Outlet>(
      row,
      transaction: transaction,
    );
  }

  /// Updates all [Outlet]s in the list and returns the updated rows. If
  /// [columns] is provided, only those columns will be updated. Defaults to
  /// all columns.
  /// This is an atomic operation, meaning that if one of the rows fails to
  /// update, none of the rows will be updated.
  Future<List<Outlet>> update(
    _i1.Session session,
    List<Outlet> rows, {
    _i1.ColumnSelections<OutletTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.update<Outlet>(
      rows,
      columns: columns?.call(Outlet.t),
      transaction: transaction,
    );
  }

  /// Updates a single [Outlet]. The row needs to have its id set.
  /// Optionally, a list of [columns] can be provided to only update those
  /// columns. Defaults to all columns.
  Future<Outlet> updateRow(
    _i1.Session session,
    Outlet row, {
    _i1.ColumnSelections<OutletTable>? columns,
    _i1.Transaction? transaction,
  }) async {
    return session.db.updateRow<Outlet>(
      row,
      columns: columns?.call(Outlet.t),
      transaction: transaction,
    );
  }

  /// Deletes all [Outlet]s in the list and returns the deleted rows.
  /// This is an atomic operation, meaning that if one of the rows fail to
  /// be deleted, none of the rows will be deleted.
  Future<List<Outlet>> delete(
    _i1.Session session,
    List<Outlet> rows, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.delete<Outlet>(
      rows,
      transaction: transaction,
    );
  }

  /// Deletes a single [Outlet].
  Future<Outlet> deleteRow(
    _i1.Session session,
    Outlet row, {
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteRow<Outlet>(
      row,
      transaction: transaction,
    );
  }

  /// Deletes all rows matching the [where] expression.
  Future<List<Outlet>> deleteWhere(
    _i1.Session session, {
    required _i1.WhereExpressionBuilder<OutletTable> where,
    _i1.Transaction? transaction,
  }) async {
    return session.db.deleteWhere<Outlet>(
      where: where(Outlet.t),
      transaction: transaction,
    );
  }

  /// Counts the number of rows matching the [where] expression. If omitted,
  /// will return the count of all rows in the table.
  Future<int> count(
    _i1.Session session, {
    _i1.WhereExpressionBuilder<OutletTable>? where,
    int? limit,
    _i1.Transaction? transaction,
  }) async {
    return session.db.count<Outlet>(
      where: where?.call(Outlet.t),
      limit: limit,
      transaction: transaction,
    );
  }
}
