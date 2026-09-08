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
import 'dart:async' as _i2;
import 'package:ds_milk_world_client/src/protocol/order_record.dart' as _i3;
import 'package:ds_milk_world_client/src/protocol/delivery_job.dart' as _i4;
import 'package:ds_milk_world_client/src/protocol/refund_record.dart' as _i5;
import 'package:ds_milk_world_client/src/protocol/order_event.dart' as _i6;
import 'package:ds_milk_world_client/src/protocol/store_catalog.dart' as _i7;
import 'package:ds_milk_world_client/src/protocol/payment_attempt.dart' as _i8;
import 'package:ds_milk_world_client/src/protocol/order_item.dart' as _i9;
import 'package:ds_milk_world_client/src/protocol/delivery_quote.dart' as _i10;
import 'protocol.dart' as _i11;

/// {@category Endpoint}
class EndpointAdmin extends _i1.EndpointRef {
  EndpointAdmin(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'admin';

  _i2.Future<_i3.OrderRecord?> acceptOrder(
    String orderNumber,
    int prepTimeMinutes,
  ) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'admin',
        'acceptOrder',
        {
          'orderNumber': orderNumber,
          'prepTimeMinutes': prepTimeMinutes,
        },
      );

  _i2.Future<_i3.OrderRecord?> rejectOrder(
    String orderNumber,
    String reason,
  ) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'admin',
        'rejectOrder',
        {
          'orderNumber': orderNumber,
          'reason': reason,
        },
      );

  _i2.Future<_i3.OrderRecord?> markReady(String orderNumber) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'admin',
        'markReady',
        {'orderNumber': orderNumber},
      );

  _i2.Future<_i3.OrderRecord?> assignDelivery(
    String orderNumber,
    String provider,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
    bool manualFallback,
    String? notes,
  ) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'admin',
        'assignDelivery',
        {
          'orderNumber': orderNumber,
          'provider': provider,
          'riderName': riderName,
          'riderPhone': riderPhone,
          'trackingUrl': trackingUrl,
          'manualFallback': manualFallback,
          'notes': notes,
        },
      );

  _i2.Future<_i3.OrderRecord?> markDelivered(String orderNumber) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'admin',
        'markDelivered',
        {'orderNumber': orderNumber},
      );

  _i2.Future<_i4.DeliveryJob?> getDeliveryJob(String orderNumber) =>
      caller.callServerEndpoint<_i4.DeliveryJob?>(
        'admin',
        'getDeliveryJob',
        {'orderNumber': orderNumber},
      );

  _i2.Future<_i5.RefundRecord?> createRefund(
    String orderNumber,
    int amountPaise,
    String reason,
  ) =>
      caller.callServerEndpoint<_i5.RefundRecord?>(
        'admin',
        'createRefund',
        {
          'orderNumber': orderNumber,
          'amountPaise': amountPaise,
          'reason': reason,
        },
      );

  _i2.Future<List<_i6.OrderEvent>> getOrderEvents(String orderNumber) =>
      caller.callServerEndpoint<List<_i6.OrderEvent>>(
        'admin',
        'getOrderEvents',
        {'orderNumber': orderNumber},
      );

  _i2.Future<List<_i3.OrderRecord>> listAllOrders(String? statusFilter) =>
      caller.callServerEndpoint<List<_i3.OrderRecord>>(
        'admin',
        'listAllOrders',
        {'statusFilter': statusFilter},
      );
}

/// {@category Endpoint}
class EndpointCatalog extends _i1.EndpointRef {
  EndpointCatalog(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'catalog';

  _i2.Future<_i7.StoreCatalog> getCatalog() =>
      caller.callServerEndpoint<_i7.StoreCatalog>(
        'catalog',
        'getCatalog',
        {},
      );

  _i2.Future<bool> updateProductAvailability(
    String sku,
    bool availability,
  ) =>
      caller.callServerEndpoint<bool>(
        'catalog',
        'updateProductAvailability',
        {
          'sku': sku,
          'availability': availability,
        },
      );
}

/// {@category Endpoint}
class EndpointCheckout extends _i1.EndpointRef {
  EndpointCheckout(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'checkout';

  _i2.Future<_i8.PaymentAttempt> createCheckoutSession(
    String orderNumber,
    String paymentMethod,
  ) =>
      caller.callServerEndpoint<_i8.PaymentAttempt>(
        'checkout',
        'createCheckoutSession',
        {
          'orderNumber': orderNumber,
          'paymentMethod': paymentMethod,
        },
      );
}

/// {@category Endpoint}
class EndpointOrder extends _i1.EndpointRef {
  EndpointOrder(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'order';

  _i2.Future<_i3.OrderRecord> createOrder(
    String customerPhone,
    String? customerName,
    String deliveryAddress,
    String? landmark,
    double latitude,
    double longitude,
    List<_i9.OrderItem> items,
  ) =>
      caller.callServerEndpoint<_i3.OrderRecord>(
        'order',
        'createOrder',
        {
          'customerPhone': customerPhone,
          'customerName': customerName,
          'deliveryAddress': deliveryAddress,
          'landmark': landmark,
          'latitude': latitude,
          'longitude': longitude,
          'items': items,
        },
      );

  _i2.Future<_i3.OrderRecord?> getOrder(String orderNumber) =>
      caller.callServerEndpoint<_i3.OrderRecord?>(
        'order',
        'getOrder',
        {'orderNumber': orderNumber},
      );

  _i2.Future<List<_i3.OrderRecord>> listActiveOrders() =>
      caller.callServerEndpoint<List<_i3.OrderRecord>>(
        'order',
        'listActiveOrders',
        {},
      );
}

/// {@category Endpoint}
class EndpointPaymentWebhook extends _i1.EndpointRef {
  EndpointPaymentWebhook(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'paymentWebhook';

  _i2.Future<bool> processWebhook(
    String provider,
    String externalId,
    String orderNumber,
    String status,
    int amountPaise,
    String? signature,
  ) =>
      caller.callServerEndpoint<bool>(
        'paymentWebhook',
        'processWebhook',
        {
          'provider': provider,
          'externalId': externalId,
          'orderNumber': orderNumber,
          'status': status,
          'amountPaise': amountPaise,
          'signature': signature,
        },
      );
}

/// {@category Endpoint}
class EndpointQuote extends _i1.EndpointRef {
  EndpointQuote(_i1.EndpointCaller caller) : super(caller);

  @override
  String get name => 'quote';

  _i2.Future<_i10.DeliveryQuote> getDeliveryQuote(
    double latitude,
    double longitude,
  ) =>
      caller.callServerEndpoint<_i10.DeliveryQuote>(
        'quote',
        'getDeliveryQuote',
        {
          'latitude': latitude,
          'longitude': longitude,
        },
      );
}

class Client extends _i1.ServerpodClientShared {
  Client(
    String host, {
    dynamic securityContext,
    _i1.AuthenticationKeyManager? authenticationKeyManager,
    Duration? streamingConnectionTimeout,
    Duration? connectionTimeout,
    Function(
      _i1.MethodCallContext,
      Object,
      StackTrace,
    )? onFailedCall,
    Function(_i1.MethodCallContext)? onSucceededCall,
    bool? disconnectStreamsOnLostInternetConnection,
  }) : super(
          host,
          _i11.Protocol(),
          securityContext: securityContext,
          authenticationKeyManager: authenticationKeyManager,
          streamingConnectionTimeout: streamingConnectionTimeout,
          connectionTimeout: connectionTimeout,
          onFailedCall: onFailedCall,
          onSucceededCall: onSucceededCall,
          disconnectStreamsOnLostInternetConnection:
              disconnectStreamsOnLostInternetConnection,
        ) {
    admin = EndpointAdmin(this);
    catalog = EndpointCatalog(this);
    checkout = EndpointCheckout(this);
    order = EndpointOrder(this);
    paymentWebhook = EndpointPaymentWebhook(this);
    quote = EndpointQuote(this);
  }

  late final EndpointAdmin admin;

  late final EndpointCatalog catalog;

  late final EndpointCheckout checkout;

  late final EndpointOrder order;

  late final EndpointPaymentWebhook paymentWebhook;

  late final EndpointQuote quote;

  @override
  Map<String, _i1.EndpointRef> get endpointRefLookup => {
        'admin': admin,
        'catalog': catalog,
        'checkout': checkout,
        'order': order,
        'paymentWebhook': paymentWebhook,
        'quote': quote,
      };

  @override
  Map<String, _i1.ModuleEndpointCaller> get moduleLookup => {};
}
