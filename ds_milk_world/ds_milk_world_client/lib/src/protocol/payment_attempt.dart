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

abstract class PaymentAttempt implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String orderNumber;

  String provider;

  String externalId;

  int amountPaise;

  String status;

  String? paymentMethod;

  String? rawReference;

  DateTime createdAt;

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
