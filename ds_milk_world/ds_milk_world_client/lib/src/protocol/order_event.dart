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

abstract class OrderEvent implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String orderNumber;

  String type;

  String actorType;

  String? actorId;

  String? payload;

  DateTime timestamp;

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
