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

abstract class Outlet implements _i1.SerializableModel {
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

  /// The database id, set if the object has been inserted into the
  /// database or if it has been fetched from the database. Otherwise,
  /// the id will be null.
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
