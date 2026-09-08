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

abstract class OrderItem implements _i1.SerializableModel {
  OrderItem._({
    this.id,
    required this.productSku,
    required this.nameSnapshot,
    required this.unitPricePaise,
    required this.quantity,
    this.optionsSnapshot,
    required this.subtotalPaise,
  });

  factory OrderItem({
    int? id,
    required String productSku,
    required String nameSnapshot,
    required int unitPricePaise,
    required int quantity,
    String? optionsSnapshot,
    required int subtotalPaise,
  }) = _OrderItemImpl;

  factory OrderItem.fromJson(Map<String, dynamic> jsonSerialization) {
    return OrderItem(
      id: jsonSerialization['id'] as int?,
      productSku: jsonSerialization['productSku'] as String,
      nameSnapshot: jsonSerialization['nameSnapshot'] as String,
      unitPricePaise: jsonSerialization['unitPricePaise'] as int,
      quantity: jsonSerialization['quantity'] as int,
      optionsSnapshot: jsonSerialization['optionsSnapshot'] as String?,
      subtotalPaise: jsonSerialization['subtotalPaise'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String productSku;

  String nameSnapshot;

  int unitPricePaise;

  int quantity;

  String? optionsSnapshot;

  int subtotalPaise;

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  OrderItem copyWith({
    int? id,
    String? productSku,
    String? nameSnapshot,
    int? unitPricePaise,
    int? quantity,
    String? optionsSnapshot,
    int? subtotalPaise,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'productSku': productSku,
      'nameSnapshot': nameSnapshot,
      'unitPricePaise': unitPricePaise,
      'quantity': quantity,
      if (optionsSnapshot != null) 'optionsSnapshot': optionsSnapshot,
      'subtotalPaise': subtotalPaise,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _OrderItemImpl extends OrderItem {
  _OrderItemImpl({
    int? id,
    required String productSku,
    required String nameSnapshot,
    required int unitPricePaise,
    required int quantity,
    String? optionsSnapshot,
    required int subtotalPaise,
  }) : super._(
          id: id,
          productSku: productSku,
          nameSnapshot: nameSnapshot,
          unitPricePaise: unitPricePaise,
          quantity: quantity,
          optionsSnapshot: optionsSnapshot,
          subtotalPaise: subtotalPaise,
        );

  /// Returns a shallow copy of this [OrderItem]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  OrderItem copyWith({
    Object? id = _Undefined,
    String? productSku,
    String? nameSnapshot,
    int? unitPricePaise,
    int? quantity,
    Object? optionsSnapshot = _Undefined,
    int? subtotalPaise,
  }) {
    return OrderItem(
      id: id is int? ? id : this.id,
      productSku: productSku ?? this.productSku,
      nameSnapshot: nameSnapshot ?? this.nameSnapshot,
      unitPricePaise: unitPricePaise ?? this.unitPricePaise,
      quantity: quantity ?? this.quantity,
      optionsSnapshot:
          optionsSnapshot is String? ? optionsSnapshot : this.optionsSnapshot,
      subtotalPaise: subtotalPaise ?? this.subtotalPaise,
    );
  }
}
