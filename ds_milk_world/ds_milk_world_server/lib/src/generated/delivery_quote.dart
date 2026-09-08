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

abstract class DeliveryQuote
    implements _i1.SerializableModel, _i1.ProtocolSerialization {
  DeliveryQuote._({
    required this.serviceable,
    required this.distanceKm,
    required this.feePaise,
    this.message,
  });

  factory DeliveryQuote({
    required bool serviceable,
    required double distanceKm,
    required int feePaise,
    String? message,
  }) = _DeliveryQuoteImpl;

  factory DeliveryQuote.fromJson(Map<String, dynamic> jsonSerialization) {
    return DeliveryQuote(
      serviceable: jsonSerialization['serviceable'] as bool,
      distanceKm: (jsonSerialization['distanceKm'] as num).toDouble(),
      feePaise: jsonSerialization['feePaise'] as int,
      message: jsonSerialization['message'] as String?,
    );
  }

  bool serviceable;

  double distanceKm;

  int feePaise;

  String? message;

  /// Returns a shallow copy of this [DeliveryQuote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  DeliveryQuote copyWith({
    bool? serviceable,
    double? distanceKm,
    int? feePaise,
    String? message,
  });
  @override
  Map<String, dynamic> toJson() {
    return {
      'serviceable': serviceable,
      'distanceKm': distanceKm,
      'feePaise': feePaise,
      if (message != null) 'message': message,
    };
  }

  @override
  Map<String, dynamic> toJsonForProtocol() {
    return {
      'serviceable': serviceable,
      'distanceKm': distanceKm,
      'feePaise': feePaise,
      if (message != null) 'message': message,
    };
  }

  @override
  String toString() {
    return _i1.SerializationManager.encode(this);
  }
}

class _Undefined {}

class _DeliveryQuoteImpl extends DeliveryQuote {
  _DeliveryQuoteImpl({
    required bool serviceable,
    required double distanceKm,
    required int feePaise,
    String? message,
  }) : super._(
          serviceable: serviceable,
          distanceKm: distanceKm,
          feePaise: feePaise,
          message: message,
        );

  /// Returns a shallow copy of this [DeliveryQuote]
  /// with some or all fields replaced by the given arguments.
  @_i1.useResult
  @override
  DeliveryQuote copyWith({
    bool? serviceable,
    double? distanceKm,
    int? feePaise,
    Object? message = _Undefined,
  }) {
    return DeliveryQuote(
      serviceable: serviceable ?? this.serviceable,
      distanceKm: distanceKm ?? this.distanceKm,
      feePaise: feePaise ?? this.feePaise,
      message: message is String? ? message : this.message,
    );
  }
}
