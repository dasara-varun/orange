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

abstract class RefundRecord implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String orderNumber;

  int amountPaise;

  String reason;

  String status;

  String? providerReference;

  DateTime createdAt;

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
