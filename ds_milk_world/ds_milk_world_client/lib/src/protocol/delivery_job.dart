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

abstract class DeliveryJob implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
