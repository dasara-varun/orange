import 'package:test/test.dart';
import 'package:ds_milk_world_server/src/generated/protocol.dart';
import 'package:ds_milk_world_server/src/services/catalog_service.dart';
import 'package:ds_milk_world_server/src/services/geo_service.dart';
import 'package:ds_milk_world_server/src/services/order_service.dart';

void main() {
  group('CatalogService Tests', () {
    test('Catalog contains 79 items and 8 categories', () {
      final catalog = CatalogService.getCatalog();
      expect(catalog.products.length, equals(79));
      expect(catalog.categories.length, equals(8));
      expect(catalog.outlet.name, equals('DS Milk World'));
    });

    test('All items have positive prices in paise', () {
      final catalog = CatalogService.getCatalog();
      for (final product in catalog.products) {
        expect(product.pricePaise, greaterThan(0));
        expect(product.sku.startsWith('DSMW-'), isTrue);
        expect(product.categoryName.isNotEmpty, isTrue);
      }
    });

    test('Oreo Falooda has SKU DSMW-001 and price 16000 paise (Rs 160)', () {
      final p = CatalogService.getProductBySku('DSMW-001');
      expect(p, isNotNull);
      expect(p!.name, equals('Oreo Falooda'));
      expect(p.pricePaise, equals(16000));
    });
  });

  group('GeoService Tests', () {
    test('Outlet location distance is 0 km', () {
      final dist = GeoService.calculateDistanceKm(
        GeoService.outletLat,
        GeoService.outletLng,
        GeoService.outletLat,
        GeoService.outletLng,
      );
      expect(dist, closeTo(0.0, 0.01));
    });

    test('Delivery fee within 2 km is base Rs 30 (3000 paise)', () {
      expect(GeoService.calculateDeliveryFeePaise(1.2), equals(3000));
      expect(GeoService.calculateDeliveryFeePaise(2.0), equals(3000));
    });

    test('Delivery fee beyond 2 km scales at Rs 10 per km', () {
      // 3.5 km -> 2.0 km base (3000) + 1.5 km (1500) = 4500 paise
      expect(GeoService.calculateDeliveryFeePaise(3.5), equals(4500));
      // 4.0 km -> 2.0 km base (3000) + 2.0 km (2000) = 5000 paise
      expect(GeoService.calculateDeliveryFeePaise(4.0), equals(5000));
    });
  });

  group('Order Lifecycle & Invariants Tests', () {
    test('Calculates order total strictly on server and validates radius', () {
      // Coordinate near Auto Nagar, ~1.5 km away
      const targetLat = 16.5050;
      const targetLng = 80.6700;

      final items = [
        OrderItem(
          productSku: 'DSMW-001', // Oreo Falooda, Rs 160
          nameSnapshot: 'Client Name Tamper',
          unitPricePaise: 99999, // Client attempt to tamper
          quantity: 2,
          optionsSnapshot: 'Extra nuts',
          subtotalPaise: 99999,
        ),
        OrderItem(
          productSku: 'DSMW-002', // Rose Falooda, Rs 130
          nameSnapshot: 'Client Name Tamper',
          unitPricePaise: 1, // Client attempt to tamper
          quantity: 1,
          optionsSnapshot: null,
          subtotalPaise: 1,
        ),
      ];

      final order = OrderService.createOrder(
        customerPhone: '+91 9876543210',
        customerName: 'Ravi Teja',
        deliveryAddress: 'Flat 402, Lotus Towers, Auto Nagar, Vijayawada',
        landmark: 'Opposite Water Tank',
        latitude: targetLat,
        longitude: targetLng,
        requestedItems: items,
      );

      expect(order.orderNumber.startsWith('DSMW-'), isTrue);
      // Subtotal should be (160 * 2) + 130 = Rs 450 = 45000 paise
      expect(order.subtotalPaise, equals(45000));
      // Delivery fee should be calculated based on distance
      expect(order.deliveryFeePaise, equals(GeoService.calculateDeliveryFeePaise(order.distanceKm)));
      expect(order.totalPaise, equals(order.subtotalPaise + order.deliveryFeePaise));
      expect(order.status, equals('awaiting_payment'));

      // Check item snapshots were populated from catalog
      expect(order.items[0].nameSnapshot, equals('Oreo Falooda'));
      expect(order.items[0].unitPricePaise, equals(16000));
      expect(order.items[0].subtotalPaise, equals(32000));
    });

    test('Rejects orders outside 5 km service radius', () {
      // Hyderabad or far away Vijayawada coordinate (e.g. 15 km away)
      const farLat = 16.7000;
      const farLng = 80.8000;

      expect(
        () => OrderService.createOrder(
          customerPhone: '+91 9876543210',
          deliveryAddress: 'Gannavaram Airport Area',
          latitude: farLat,
          longitude: farLng,
          requestedItems: [
            OrderItem(
              productSku: 'DSMW-001',
              nameSnapshot: 'Oreo Falooda',
              unitPricePaise: 16000,
              quantity: 1,
              subtotalPaise: 16000,
            ),
          ],
        ),
        throwsArgumentError,
      );
    });

    test('Full End-to-End State Machine: Order -> Payment -> Acceptance -> Ready -> Dispatch -> Delivery', () {
      // 1. Create order
      final order = OrderService.createOrder(
        customerPhone: '+91 9123456780',
        customerName: 'Ananya Rao',
        deliveryAddress: 'House 12, Road 4, Auto Nagar',
        latitude: 16.4970,
        longitude: 80.6680,
        requestedItems: [
          OrderItem(
            productSku: 'DSMW-003', // Badam Falooda
            nameSnapshot: 'Badam Falooda',
            unitPricePaise: 15000,
            quantity: 1,
            subtotalPaise: 15000,
          ),
        ],
      );

      final orderNum = order.orderNumber;
      expect(order.status, equals('awaiting_payment'));

      // 2. Initiate checkout
      final attempt = OrderService.createCheckoutSession(
        orderNumber: orderNum,
        paymentMethod: 'UPI_INTENT',
      );
      expect(attempt.status, equals('pending'));
      expect(attempt.amountPaise, equals(order.totalPaise));

      // 3. Process payment webhook
      final webhookResult = OrderService.handlePaymentWebhook(
        provider: 'generic_simulator',
        externalId: attempt.externalId,
        orderNumber: orderNum,
        status: 'successful',
        amountPaise: order.totalPaise,
      );
      expect(webhookResult, isTrue);

      final paidOrder = OrderService.getOrder(orderNum)!;
      expect(paidOrder.status, equals('shop_acceptance_pending'));

      // 4. Idempotent webhook check: Duplicate webhook must succeed without re-triggering
      final duplicateWebhook = OrderService.handlePaymentWebhook(
        provider: 'generic_simulator',
        externalId: attempt.externalId,
        orderNumber: orderNum,
        status: 'successful',
        amountPaise: order.totalPaise,
      );
      expect(duplicateWebhook, isTrue);

      // 5. Staff accepts order
      final acceptedOrder = OrderService.acceptOrder(
        orderNumber: orderNum,
        prepTimeMinutes: 20,
      );
      expect(acceptedOrder.status, equals('preparing'));
      expect(acceptedOrder.prepTimeMinutes, equals(20));

      // 6. Staff marks ready with packing checklist
      final readyOrder = OrderService.markReady(orderNum);
      expect(readyOrder.status, equals('ready_for_pickup'));
      expect(readyOrder.packingChecklistConfirmed, isTrue);

      // 7. Staff assigns delivery (manual fallback or partner)
      final dispatchedOrder = OrderService.assignDelivery(
        orderNumber: orderNum,
        provider: 'Rapido Delivery',
        riderName: 'Suresh V',
        riderPhone: '+91 9988776655',
        trackingUrl: 'https://track.example.com/del-123',
        manualFallback: false,
      );
      expect(dispatchedOrder.status, equals('out_for_delivery'));

      final job = OrderService.getDeliveryJob(orderNum);
      expect(job, isNotNull);
      expect(job!.riderName, equals('Suresh V'));

      // 8. Rider marks delivered
      final deliveredOrder = OrderService.markDelivered(orderNum);
      expect(deliveredOrder.status, equals('delivered'));

      // 9. Verify event audit trail
      final events = OrderService.getOrderEvents(orderNum);
      expect(events.length, greaterThanOrEqualTo(6));
      final eventTypes = events.map((e) => e.type).toList();
      expect(eventTypes, contains('order_created'));
      expect(eventTypes, contains('payment_successful'));
      expect(eventTypes, contains('shop_acceptance_pending'));
      expect(eventTypes, contains('order_accepted'));
      expect(eventTypes, contains('order_ready'));
      expect(eventTypes, contains('delivery_dispatched'));
      expect(eventTypes, contains('order_delivered'));
    });

    test('Staff rejection triggers auto-refund creation', () {
      final order = OrderService.createOrder(
        customerPhone: '+91 9123456781',
        customerName: 'Kalyan',
        deliveryAddress: 'Shop 5, Auto Nagar Commercial Area',
        latitude: 16.4960,
        longitude: 80.6660,
        requestedItems: [
          OrderItem(
            productSku: 'DSMW-005',
            nameSnapshot: 'Kulfi Falooda',
            unitPricePaise: 16000,
            quantity: 1,
            subtotalPaise: 16000,
          ),
        ],
      );

      // Pay order
      final attempt = OrderService.createCheckoutSession(
        orderNumber: order.orderNumber,
        paymentMethod: 'CARD',
      );
      OrderService.handlePaymentWebhook(
        provider: 'generic_simulator',
        externalId: attempt.externalId,
        orderNumber: order.orderNumber,
        status: 'successful',
        amountPaise: order.totalPaise,
      );

      // Staff rejects order
      final rejectedOrder = OrderService.rejectOrder(
        orderNumber: order.orderNumber,
        reason: 'Out of fresh kulfi stock for today',
      );

      expect(rejectedOrder.status, equals('rejected'));
      expect(rejectedOrder.rejectionReason, contains('Out of fresh kulfi'));

      // Verify refund record created
      final refunds = OrderService.getRefunds(order.orderNumber);
      expect(refunds.length, equals(1));
      expect(refunds[0].amountPaise, equals(order.totalPaise));
      expect(refunds[0].status, equals('completed'));
    });

    test('Customer cancellation before prep triggers auto-refund and blocks late cancellation', () {
      final order = OrderService.createOrder(
        customerPhone: '+91 9900011223',
        customerName: 'Pooja',
        deliveryAddress: 'Road 2, Auto Nagar',
        latitude: 16.4955,
        longitude: 80.6655,
        requestedItems: [
          OrderItem(
            productSku: 'DSMW-002',
            nameSnapshot: 'Rose Falooda',
            unitPricePaise: 13000,
            quantity: 1,
            subtotalPaise: 13000,
          ),
        ],
      );

      // Pay order
      final attempt = OrderService.createCheckoutSession(
        orderNumber: order.orderNumber,
        paymentMethod: 'UPI_QR',
      );
      OrderService.handlePaymentWebhook(
        provider: 'generic_simulator',
        externalId: attempt.externalId,
        orderNumber: order.orderNumber,
        status: 'successful',
        amountPaise: order.totalPaise,
      );

      // Cancel before shop accepts
      final cancelled = OrderService.cancelOrder(
        orderNumber: order.orderNumber,
        reason: 'Change of mind',
        actorType: 'customer',
      );
      expect(cancelled.status, equals('rejected'));
      expect(cancelled.rejectionReason, contains('Change of mind'));

      final refunds = OrderService.getRefunds(order.orderNumber);
      expect(refunds.length, equals(1));
      expect(refunds[0].amountPaise, equals(order.totalPaise));

      // Attempting to cancel an order already preparing throws StateError
      final order2 = OrderService.createOrder(
        customerPhone: '+91 9900011224',
        deliveryAddress: 'Road 3, Auto Nagar',
        latitude: 16.4955,
        longitude: 80.6655,
        requestedItems: [
          OrderItem(
            productSku: 'DSMW-002',
            nameSnapshot: 'Rose Falooda',
            unitPricePaise: 13000,
            quantity: 1,
            subtotalPaise: 13000,
          ),
        ],
      );
      final attempt2 = OrderService.createCheckoutSession(
        orderNumber: order2.orderNumber,
        paymentMethod: 'CARD',
      );
      OrderService.handlePaymentWebhook(
        provider: 'generic_simulator',
        externalId: attempt2.externalId,
        orderNumber: order2.orderNumber,
        status: 'successful',
        amountPaise: order2.totalPaise,
      );
      OrderService.acceptOrder(orderNumber: order2.orderNumber, prepTimeMinutes: 15);
      expect(
        () => OrderService.cancelOrder(
          orderNumber: order2.orderNumber,
          reason: 'Too late',
        ),
        throwsStateError,
      );
    });

    test('Delivery webhook updates rider details and transitions order status', () {
      final order = OrderService.createOrder(
        customerPhone: '+91 9888877777',
        deliveryAddress: 'Plot 10, Auto Nagar',
        latitude: 16.4960,
        longitude: 80.6660,
        requestedItems: [
          OrderItem(
            productSku: 'DSMW-004',
            nameSnapshot: 'Fruit Falooda',
            unitPricePaise: 14000,
            quantity: 1,
            subtotalPaise: 14000,
          ),
        ],
      );

      final success = OrderService.handleDeliveryWebhook(
        orderNumber: order.orderNumber,
        provider: 'Rapido Delivery',
        eventType: 'picked_up',
        riderName: 'Mahesh K',
        riderPhone: '+91 9876543210',
        trackingUrl: 'https://track.example.com/del-456',
      );

      expect(success, isTrue);
      final updatedOrder = OrderService.getOrder(order.orderNumber)!;
      expect(updatedOrder.status, equals('out_for_delivery'));

      final job = OrderService.getDeliveryJob(order.orderNumber)!;
      expect(job.riderName, equals('Mahesh K'));
      expect(job.status, equals('picked_up'));

      // Webhook delivers order
      OrderService.handleDeliveryWebhook(
        orderNumber: order.orderNumber,
        provider: 'Rapido Delivery',
        eventType: 'delivered',
      );
      expect(OrderService.getOrder(order.orderNumber)!.status, equals('delivered'));
    });
  });
}