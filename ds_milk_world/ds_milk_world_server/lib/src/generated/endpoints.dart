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
import '../endpoints/admin_endpoint.dart' as _i2;
import '../endpoints/catalog_endpoint.dart' as _i3;
import '../endpoints/checkout_endpoint.dart' as _i4;
import '../endpoints/delivery_webhook_endpoint.dart' as _i5;
import '../endpoints/order_endpoint.dart' as _i6;
import '../endpoints/payment_webhook_endpoint.dart' as _i7;
import '../endpoints/quote_endpoint.dart' as _i8;
import 'package:ds_milk_world_server/src/generated/order_item.dart' as _i9;

class Endpoints extends _i1.EndpointDispatch {
  @override
  void initializeEndpoints(_i1.Server server) {
    var endpoints = <String, _i1.Endpoint>{
      'admin': _i2.AdminEndpoint()
        ..initialize(
          server,
          'admin',
          null,
        ),
      'catalog': _i3.CatalogEndpoint()
        ..initialize(
          server,
          'catalog',
          null,
        ),
      'checkout': _i4.CheckoutEndpoint()
        ..initialize(
          server,
          'checkout',
          null,
        ),
      'deliveryWebhook': _i5.DeliveryWebhookEndpoint()
        ..initialize(
          server,
          'deliveryWebhook',
          null,
        ),
      'order': _i6.OrderEndpoint()
        ..initialize(
          server,
          'order',
          null,
        ),
      'paymentWebhook': _i7.PaymentWebhookEndpoint()
        ..initialize(
          server,
          'paymentWebhook',
          null,
        ),
      'quote': _i8.QuoteEndpoint()
        ..initialize(
          server,
          'quote',
          null,
        ),
    };
    connectors['admin'] = _i1.EndpointConnector(
      name: 'admin',
      endpoint: endpoints['admin']!,
      methodConnectors: {
        'acceptOrder': _i1.MethodConnector(
          name: 'acceptOrder',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'prepTimeMinutes': _i1.ParameterDescription(
              name: 'prepTimeMinutes',
              type: _i1.getType<int>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).acceptOrder(
            session,
            params['orderNumber'],
            params['prepTimeMinutes'],
          ),
        ),
        'rejectOrder': _i1.MethodConnector(
          name: 'rejectOrder',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).rejectOrder(
            session,
            params['orderNumber'],
            params['reason'],
          ),
        ),
        'markReady': _i1.MethodConnector(
          name: 'markReady',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).markReady(
            session,
            params['orderNumber'],
          ),
        ),
        'assignDelivery': _i1.MethodConnector(
          name: 'assignDelivery',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'provider': _i1.ParameterDescription(
              name: 'provider',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'riderName': _i1.ParameterDescription(
              name: 'riderName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'riderPhone': _i1.ParameterDescription(
              name: 'riderPhone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'trackingUrl': _i1.ParameterDescription(
              name: 'trackingUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'manualFallback': _i1.ParameterDescription(
              name: 'manualFallback',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
            'notes': _i1.ParameterDescription(
              name: 'notes',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).assignDelivery(
            session,
            params['orderNumber'],
            params['provider'],
            params['riderName'],
            params['riderPhone'],
            params['trackingUrl'],
            params['manualFallback'],
            params['notes'],
          ),
        ),
        'markDelivered': _i1.MethodConnector(
          name: 'markDelivered',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).markDelivered(
            session,
            params['orderNumber'],
          ),
        ),
        'getDeliveryJob': _i1.MethodConnector(
          name: 'getDeliveryJob',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).getDeliveryJob(
            session,
            params['orderNumber'],
          ),
        ),
        'createRefund': _i1.MethodConnector(
          name: 'createRefund',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amountPaise': _i1.ParameterDescription(
              name: 'amountPaise',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).createRefund(
            session,
            params['orderNumber'],
            params['amountPaise'],
            params['reason'],
          ),
        ),
        'getOrderEvents': _i1.MethodConnector(
          name: 'getOrderEvents',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).getOrderEvents(
            session,
            params['orderNumber'],
          ),
        ),
        'listAllOrders': _i1.MethodConnector(
          name: 'listAllOrders',
          params: {
            'statusFilter': _i1.ParameterDescription(
              name: 'statusFilter',
              type: _i1.getType<String?>(),
              nullable: true,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).listAllOrders(
            session,
            params['statusFilter'],
          ),
        ),
        'updateProductDetails': _i1.MethodConnector(
          name: 'updateProductDetails',
          params: {
            'sku': _i1.ParameterDescription(
              name: 'sku',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'pricePaise': _i1.ParameterDescription(
              name: 'pricePaise',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'offerPricePaise': _i1.ParameterDescription(
              name: 'offerPricePaise',
              type: _i1.getType<int?>(),
              nullable: true,
            ),
            'availability': _i1.ParameterDescription(
              name: 'availability',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'customisable': _i1.ParameterDescription(
              name: 'customisable',
              type: _i1.getType<bool?>(),
              nullable: true,
            ),
            'shortDescription': _i1.ParameterDescription(
              name: 'shortDescription',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).updateProductDetails(
            session,
            params['sku'],
            params['pricePaise'],
            params['offerPricePaise'],
            params['availability'],
            params['customisable'],
            params['shortDescription'],
          ),
        ),
        'verifyStaffPin': _i1.MethodConnector(
          name: 'verifyStaffPin',
          params: {
            'pin': _i1.ParameterDescription(
              name: 'pin',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['admin'] as _i2.AdminEndpoint).verifyStaffPin(
            session,
            params['pin'],
          ),
        ),
      },
    );
    connectors['catalog'] = _i1.EndpointConnector(
      name: 'catalog',
      endpoint: endpoints['catalog']!,
      methodConnectors: {
        'getCatalog': _i1.MethodConnector(
          name: 'getCatalog',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['catalog'] as _i3.CatalogEndpoint).getCatalog(session),
        ),
        'updateProductAvailability': _i1.MethodConnector(
          name: 'updateProductAvailability',
          params: {
            'sku': _i1.ParameterDescription(
              name: 'sku',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'availability': _i1.ParameterDescription(
              name: 'availability',
              type: _i1.getType<bool>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['catalog'] as _i3.CatalogEndpoint)
                  .updateProductAvailability(
            session,
            params['sku'],
            params['availability'],
          ),
        ),
      },
    );
    connectors['checkout'] = _i1.EndpointConnector(
      name: 'checkout',
      endpoint: endpoints['checkout']!,
      methodConnectors: {
        'createCheckoutSession': _i1.MethodConnector(
          name: 'createCheckoutSession',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'paymentMethod': _i1.ParameterDescription(
              name: 'paymentMethod',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['checkout'] as _i4.CheckoutEndpoint)
                  .createCheckoutSession(
            session,
            params['orderNumber'],
            params['paymentMethod'],
          ),
        )
      },
    );
    connectors['deliveryWebhook'] = _i1.EndpointConnector(
      name: 'deliveryWebhook',
      endpoint: endpoints['deliveryWebhook']!,
      methodConnectors: {
        'processWebhook': _i1.MethodConnector(
          name: 'processWebhook',
          params: {
            'provider': _i1.ParameterDescription(
              name: 'provider',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'eventType': _i1.ParameterDescription(
              name: 'eventType',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'riderName': _i1.ParameterDescription(
              name: 'riderName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'riderPhone': _i1.ParameterDescription(
              name: 'riderPhone',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'trackingUrl': _i1.ParameterDescription(
              name: 'trackingUrl',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['deliveryWebhook'] as _i5.DeliveryWebhookEndpoint)
                  .processWebhook(
            session,
            params['provider'],
            params['orderNumber'],
            params['eventType'],
            params['riderName'],
            params['riderPhone'],
            params['trackingUrl'],
            params['signature'],
          ),
        )
      },
    );
    connectors['order'] = _i1.EndpointConnector(
      name: 'order',
      endpoint: endpoints['order']!,
      methodConnectors: {
        'createOrder': _i1.MethodConnector(
          name: 'createOrder',
          params: {
            'customerPhone': _i1.ParameterDescription(
              name: 'customerPhone',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'customerName': _i1.ParameterDescription(
              name: 'customerName',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'deliveryAddress': _i1.ParameterDescription(
              name: 'deliveryAddress',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'landmark': _i1.ParameterDescription(
              name: 'landmark',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'items': _i1.ParameterDescription(
              name: 'items',
              type: _i1.getType<List<_i9.OrderItem>>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['order'] as _i6.OrderEndpoint).createOrder(
            session,
            params['customerPhone'],
            params['customerName'],
            params['deliveryAddress'],
            params['landmark'],
            params['latitude'],
            params['longitude'],
            params['items'],
          ),
        ),
        'getOrder': _i1.MethodConnector(
          name: 'getOrder',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            )
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['order'] as _i6.OrderEndpoint).getOrder(
            session,
            params['orderNumber'],
          ),
        ),
        'listActiveOrders': _i1.MethodConnector(
          name: 'listActiveOrders',
          params: {},
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['order'] as _i6.OrderEndpoint)
                  .listActiveOrders(session),
        ),
        'cancelOrder': _i1.MethodConnector(
          name: 'cancelOrder',
          params: {
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'reason': _i1.ParameterDescription(
              name: 'reason',
              type: _i1.getType<String>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['order'] as _i6.OrderEndpoint).cancelOrder(
            session,
            params['orderNumber'],
            params['reason'],
          ),
        ),
      },
    );
    connectors['paymentWebhook'] = _i1.EndpointConnector(
      name: 'paymentWebhook',
      endpoint: endpoints['paymentWebhook']!,
      methodConnectors: {
        'processWebhook': _i1.MethodConnector(
          name: 'processWebhook',
          params: {
            'provider': _i1.ParameterDescription(
              name: 'provider',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'externalId': _i1.ParameterDescription(
              name: 'externalId',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'orderNumber': _i1.ParameterDescription(
              name: 'orderNumber',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'status': _i1.ParameterDescription(
              name: 'status',
              type: _i1.getType<String>(),
              nullable: false,
            ),
            'amountPaise': _i1.ParameterDescription(
              name: 'amountPaise',
              type: _i1.getType<int>(),
              nullable: false,
            ),
            'signature': _i1.ParameterDescription(
              name: 'signature',
              type: _i1.getType<String?>(),
              nullable: true,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['paymentWebhook'] as _i7.PaymentWebhookEndpoint)
                  .processWebhook(
            session,
            params['provider'],
            params['externalId'],
            params['orderNumber'],
            params['status'],
            params['amountPaise'],
            params['signature'],
          ),
        )
      },
    );
    connectors['quote'] = _i1.EndpointConnector(
      name: 'quote',
      endpoint: endpoints['quote']!,
      methodConnectors: {
        'getDeliveryQuote': _i1.MethodConnector(
          name: 'getDeliveryQuote',
          params: {
            'latitude': _i1.ParameterDescription(
              name: 'latitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
            'longitude': _i1.ParameterDescription(
              name: 'longitude',
              type: _i1.getType<double>(),
              nullable: false,
            ),
          },
          call: (
            _i1.Session session,
            Map<String, dynamic> params,
          ) async =>
              (endpoints['quote'] as _i8.QuoteEndpoint).getDeliveryQuote(
            session,
            params['latitude'],
            params['longitude'],
          ),
        )
      },
    );
  }
}
