/* AUTOMATICALLY GENERATED CODE DO NOT MODIFY */
/*   To generate run: "serverpod generate"    */

// ignore_for_file: implementation_imports
// ignore_for_file: library_private_types_in_public_api
// ignore_for_file: non_constant_identifier_names
// ignore_for_file: public_member_api_docs
// ignore_for_file: type_literal_in_constant_pattern
// ignore_for_file: use_super_parameters

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:serverpod_client/serverpod_client.dart' as _i1;
import 'order_item.dart' as _i2;

abstract class OrderRecord implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
