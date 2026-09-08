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
import 'outlet.dart' as _i2;
import 'category.dart' as _i3;
import 'product.dart' as _i4;

abstract class StoreCatalog implements _i1.SerializableModel {
  StoreCatalog._({
    required this.outlet,
    required this.categories,
    required this.products,
  });

  factory StoreCatalog({
    required _i2.Outlet outlet,
    required List<_i3.Category> categories,
    required List<_i4.Product> products,
  }) = _StoreCatalogImpl;

  factory StoreCatalog.fromJson(Map<String, dynamic> jsonSerialization) {
    return StoreCatalog(
      outlet: _i2.Outlet.fromJson(
          (jsonSerialization['outlet'] as Map<String, dynamic>)),
      categories: (jsonSerialization['categories'] as List)
          .map((e) => _i3.Category.fromJson((e as Map<String, dynamic>)))
          .toList(),
      products: (jsonSerialization['products'] as List)
          .map((e) => _i4.Product.fromJson((e as Map<String, dynamic>)))
          .toList(),
    );
  }

  _i2.Outlet outlet;

  List<_i3.Category> categories;

  List<_i4.Product> products;

  /// Returns a shallow copy of this [StoreCatalog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  StoreCatalog copyWith({
    _i2.Outlet? outlet,
    List<_i3.Category>? categories,
    List<_i4.Product>? products,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'outlet': outlet.toJson(),
      'categories': categories.toJson(valueToJson: (v) => v.toJson()),
      'products': products.toJson(valueToJson: (v) => v.toJson()),
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _StoreCatalogImpl extends StoreCatalog {
  _StoreCatalogImpl({
    required _i2.Outlet outlet,
    required List<_i3.Category> categories,
    required List<_i4.Product> products,
  }) : super._(
          outlet: outlet,
          categories: categories,
          products: products,
        );

  /// Returns a shallow copy of this [StoreCatalog]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  StoreCatalog copyWith({
    _i2.Outlet? outlet,
    List<_i3.Category>? categories,
    List<_i4.Product>? products,
  }) {
    return StoreCatalog(
      outlet: outlet ?? this.outlet.copyWith(),
      categories:
          categories ?? this.categories.map((e0) => e0.copyWith()).toList(),
      products: products ?? this.products.map((e0) => e0.copyWith()).toList(),
    );
  }
}
