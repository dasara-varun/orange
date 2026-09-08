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

abstract class Product implements _i1.SerializableModel {
  Product._({
    this.id,
    required this.categoryName,
    required this.sku,
    required this.name,
    this.shortDescription,
    this.sizeOrServing,
    required this.pricePaise,
    this.offerPricePaise,
    required this.availability,
    required this.customisable,
    required this.vegetarian,
    required this.sortOrder,
  });

  factory Product({
    int? id,
    required String categoryName,
    required String sku,
    required String name,
    String? shortDescription,
    String? sizeOrServing,
    required int pricePaise,
    int? offerPricePaise,
    required bool availability,
    required bool customisable,
    required bool vegetarian,
    required int sortOrder,
  }) = _ProductImpl;

  factory Product.fromJson(Map<String, dynamic> jsonSerialization) {
    return Product(
      id: jsonSerialization['id'] as int?,
      categoryName: jsonSerialization['categoryName'] as String,
      sku: jsonSerialization['sku'] as String,
      name: jsonSerialization['name'] as String,
      shortDescription: jsonSerialization['shortDescription'] as String?,
      sizeOrServing: jsonSerialization['sizeOrServing'] as String?,
      pricePaise: jsonSerialization['pricePaise'] as int,
      offerPricePaise: jsonSerialization['offerPricePaise'] as int?,
      availability: jsonSerialization['availability'] as bool,
      customisable: jsonSerialization['customisable'] as bool,
      vegetarian: jsonSerialization['vegetarian'] as bool,
      sortOrder: jsonSerialization['sortOrder'] as int,
    );
  }

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
  int? id;

  String categoryName;

  String sku;

  String name;

  String? shortDescription;

  String? sizeOrServing;

  int pricePaise;

  int? offerPricePaise;

  bool availability;

  bool customisable;

  bool vegetarian;

  int sortOrder;

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  Product copyWith({
    int? id,
    String? categoryName,
    String? sku,
    String? name,
    String? shortDescription,
    String? sizeOrServing,
    int? pricePaise,
    int? offerPricePaise,
    bool? availability,
    bool? customisable,
    bool? vegetarian,
    int? sortOrder,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'categoryName': categoryName,
      'sku': sku,
      'name': name,
      if (shortDescription != null) 'shortDescription': shortDescription,
      if (sizeOrServing != null) 'sizeOrServing': sizeOrServing,
      'pricePaise': pricePaise,
      if (offerPricePaise != null) 'offerPricePaise': offerPricePaise,
      'availability': availability,
      'customisable': customisable,
      'vegetarian': vegetarian,
      'sortOrder': sortOrder,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _ProductImpl extends Product {
  _ProductImpl({
    int? id,
    required String categoryName,
    required String sku,
    required String name,
    String? shortDescription,
    String? sizeOrServing,
    required int pricePaise,
    int? offerPricePaise,
    required bool availability,
    required bool customisable,
    required bool vegetarian,
    required int sortOrder,
  }) : super._(
          id: id,
          categoryName: categoryName,
          sku: sku,
          name: name,
          shortDescription: shortDescription,
          sizeOrServing: sizeOrServing,
          pricePaise: pricePaise,
          offerPricePaise: offerPricePaise,
          availability: availability,
          customisable: customisable,
          vegetarian: vegetarian,
          sortOrder: sortOrder,
        );

  /// Returns a shallow copy of this [Product]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  Product copyWith({
    Object? id = _Undefined,
    String? categoryName,
    String? sku,
    String? name,
    Object? shortDescription = _Undefined,
    Object? sizeOrServing = _Undefined,
    int? pricePaise,
    Object? offerPricePaise = _Undefined,
    bool? availability,
    bool? customisable,
    bool? vegetarian,
    int? sortOrder,
  }) {
    return Product(
      id: id is int? ? id : this.id,
      categoryName: categoryName ?? this.categoryName,
      sku: sku ?? this.sku,
      name: name ?? this.name,
      shortDescription: shortDescription is String?
          ? shortDescription
          : this.shortDescription,
      sizeOrServing:
          sizeOrServing is String? ? sizeOrServing : this.sizeOrServing,
      pricePaise: pricePaise ?? this.pricePaise,
      offerPricePaise:
          offerPricePaise is int? ? offerPricePaise : this.offerPricePaise,
      availability: availability ?? this.availability,
      customisable: customisable ?? this.customisable,
      vegetarian: vegetarian ?? this.vegetarian,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }
}
