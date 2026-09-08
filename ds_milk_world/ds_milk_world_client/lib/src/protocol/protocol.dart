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
import 'category.dart' as _i2;
import 'delivery_job.dart' as _i3;
import 'delivery_quote.dart' as _i4;
import 'order_event.dart' as _i5;
import 'order_item.dart' as _i6;
import 'order_record.dart' as _i7;
import 'outlet.dart' as _i8;
import 'payment_attempt.dart' as _i9;
import 'product.dart' as _i10;
import 'refund_record.dart' as _i11;
import 'store_catalog.dart' as _i12;
import 'package:ds_milk_world_client/src/protocol/order_event.dart' as _i13;
import 'package:ds_milk_world_client/src/protocol/order_record.dart' as _i14;
import 'package:ds_milk_world_client/src/protocol/order_item.dart' as _i15;
export 'category.dart';
export 'delivery_job.dart';
export 'delivery_quote.dart';
export 'order_event.dart';
export 'order_item.dart';
export 'order_record.dart';
export 'outlet.dart';
export 'payment_attempt.dart';
export 'product.dart';
export 'refund_record.dart';
export 'store_catalog.dart';
export 'client.dart';

class Protocol extends _i1.SerializationManager {
  Protocol._();

  factory Protocol() => _instance;

  static final Protocol _instance = Protocol._();

  @override
  T deserialize<T>(
    dynamic data, [
    Type? t,
  ]) {
    t ??= T;
    if (t == _i2.Category) {
      return _i2.Category.fromJson(data) as T;
    }
    if (t == _i3.DeliveryJob) {
      return _i3.DeliveryJob.fromJson(data) as T;
    }
    if (t == _i4.DeliveryQuote) {
      return _i4.DeliveryQuote.fromJson(data) as T;
    }
    if (t == _i5.OrderEvent) {
      return _i5.OrderEvent.fromJson(data) as T;
    }
    if (t == _i6.OrderItem) {
      return _i6.OrderItem.fromJson(data) as T;
    }
    if (t == _i7.OrderRecord) {
      return _i7.OrderRecord.fromJson(data) as T;
    }
    if (t == _i8.Outlet) {
      return _i8.Outlet.fromJson(data) as T;
    }
    if (t == _i9.PaymentAttempt) {
      return _i9.PaymentAttempt.fromJson(data) as T;
    }
    if (t == _i10.Product) {
      return _i10.Product.fromJson(data) as T;
    }
    if (t == _i11.RefundRecord) {
      return _i11.RefundRecord.fromJson(data) as T;
    }
    if (t == _i12.StoreCatalog) {
      return _i12.StoreCatalog.fromJson(data) as T;
    }
    if (t == _i1.getType<_i2.Category?>()) {
      return (data != null ? _i2.Category.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i3.DeliveryJob?>()) {
      return (data != null ? _i3.DeliveryJob.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i4.DeliveryQuote?>()) {
      return (data != null ? _i4.DeliveryQuote.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i5.OrderEvent?>()) {
      return (data != null ? _i5.OrderEvent.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i6.OrderItem?>()) {
      return (data != null ? _i6.OrderItem.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i7.OrderRecord?>()) {
      return (data != null ? _i7.OrderRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i8.Outlet?>()) {
      return (data != null ? _i8.Outlet.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i9.PaymentAttempt?>()) {
      return (data != null ? _i9.PaymentAttempt.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i10.Product?>()) {
      return (data != null ? _i10.Product.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i11.RefundRecord?>()) {
      return (data != null ? _i11.RefundRecord.fromJson(data) : null) as T;
    }
    if (t == _i1.getType<_i12.StoreCatalog?>()) {
      return (data != null ? _i12.StoreCatalog.fromJson(data) : null) as T;
    }
    if (t == List<_i6.OrderItem>) {
      return (data as List).map((e) => deserialize<_i6.OrderItem>(e)).toList()
          as T;
    }
    if (t == List<_i2.Category>) {
      return (data as List).map((e) => deserialize<_i2.Category>(e)).toList()
          as T;
    }
    if (t == List<_i10.Product>) {
      return (data as List).map((e) => deserialize<_i10.Product>(e)).toList()
          as T;
    }
    if (t == List<_i13.OrderEvent>) {
      return (data as List).map((e) => deserialize<_i13.OrderEvent>(e)).toList()
          as T;
    }
    if (t == List<_i14.OrderRecord>) {
      return (data as List)
          .map((e) => deserialize<_i14.OrderRecord>(e))
          .toList() as T;
    }
    if (t == List<_i15.OrderItem>) {
      return (data as List).map((e) => deserialize<_i15.OrderItem>(e)).toList()
          as T;
    }
    return super.deserialize<T>(data, t);
  }

  @override
  String? getClassNameForObject(Object? data) {
    String? className = super.getClassNameForObject(data);
    if (className != null) return className;
    if (data is _i2.Category) {
      return 'Category';
    }
    if (data is _i3.DeliveryJob) {
      return 'DeliveryJob';
    }
    if (data is _i4.DeliveryQuote) {
      return 'DeliveryQuote';
    }
    if (data is _i5.OrderEvent) {
      return 'OrderEvent';
    }
    if (data is _i6.OrderItem) {
      return 'OrderItem';
    }
    if (data is _i7.OrderRecord) {
      return 'OrderRecord';
    }
    if (data is _i8.Outlet) {
      return 'Outlet';
    }
    if (data is _i9.PaymentAttempt) {
      return 'PaymentAttempt';
    }
    if (data is _i10.Product) {
      return 'Product';
    }
    if (data is _i11.RefundRecord) {
      return 'RefundRecord';
    }
    if (data is _i12.StoreCatalog) {
      return 'StoreCatalog';
    }
    return null;
  }

  @override
  dynamic deserializeByClassName(Map<String, dynamic> data) {
    var dataClassName = data['className'];
    if (dataClassName is! String) {
      return super.deserializeByClassName(data);
    }
    if (dataClassName == 'Category') {
      return deserialize<_i2.Category>(data['data']);
    }
    if (dataClassName == 'DeliveryJob') {
      return deserialize<_i3.DeliveryJob>(data['data']);
    }
    if (dataClassName == 'DeliveryQuote') {
      return deserialize<_i4.DeliveryQuote>(data['data']);
    }
    if (dataClassName == 'OrderEvent') {
      return deserialize<_i5.OrderEvent>(data['data']);
    }
    if (dataClassName == 'OrderItem') {
      return deserialize<_i6.OrderItem>(data['data']);
    }
    if (dataClassName == 'OrderRecord') {
      return deserialize<_i7.OrderRecord>(data['data']);
    }
    if (dataClassName == 'Outlet') {
      return deserialize<_i8.Outlet>(data['data']);
    }
    if (dataClassName == 'PaymentAttempt') {
      return deserialize<_i9.PaymentAttempt>(data['data']);
    }
    if (dataClassName == 'Product') {
      return deserialize<_i10.Product>(data['data']);
    }
    if (dataClassName == 'RefundRecord') {
      return deserialize<_i11.RefundRecord>(data['data']);
    }
    if (dataClassName == 'StoreCatalog') {
      return deserialize<_i12.StoreCatalog>(data['data']);
    }
    return super.deserializeByClassName(data);
  }
}
