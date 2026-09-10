import 'dart:math';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../main.dart';
import 'mock_data.dart';

class ApiService {
  static final ApiService instance = ApiService._();
  ApiService._();

  // In-memory fallback stores
  final Map<String, OrderRecord> _orders = {};
  final Map<String, List<OrderEvent>> _orderEvents = {};
  final Map<String, DeliveryJob> _deliveryJobs = {};
  int _orderSeq = 1001;

  double _haversineDistance(double lat1, double lon1, double lat2, double lon2) {
    const double r = 6371.0;
    final dLat = (lat2 - lat1) * pi / 180.0;
    final dLon = (lon2 - lon1) * pi / 180.0;
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(lat1 * pi / 180.0) * cos(lat2 * pi / 180.0) * sin(dLon / 2) * sin(dLon / 2);
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return r * c;
  }

  int _calculateFeePaise(double distanceKm) {
    if (distanceKm <= 2.0) return 3000;
    final extra = distanceKm - 2.0;
    return 3000 + (extra * 1000).ceil();
  }

  Future<StoreCatalog> getCatalog() async {
    try {
      return await client.catalog.getCatalog().timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      return MockData.getCatalog();
    }
  }

  Future<bool> updateProductAvailability(String sku, bool availability) async {
    try {
      return await client.catalog.updateProductAvailability(sku, availability).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      MockData.updateProductAvailability(sku, availability);
      return true;
    }
  }

  Future<bool> updateProductDetails({
    required String sku,
    int? pricePaise,
    int? offerPricePaise,
    bool? availability,
    bool? customisable,
    String? shortDescription,
  }) async {
    try {
      return await client.admin.updateProductDetails(
        sku,
        pricePaise,
        offerPricePaise,
        availability,
        customisable,
        shortDescription,
      ).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      return MockData.updateProductDetails(
        sku: sku,
        pricePaise: pricePaise,
        offerPricePaise: offerPricePaise,
        availability: availability,
        customisable: customisable,
        shortDescription: shortDescription,
      );
    }
  }

  Future<bool> verifyStaffPin(String pin) async {
    try {
      return await client.admin.verifyStaffPin(pin).timeout(const Duration(milliseconds: 2000));
    } catch (_) {
      final outlet = MockData.outlet;
      return (outlet.staffPin ?? '1979') == pin;
    }
  }

  Future<DeliveryQuote> getDeliveryQuote(double lat, double lng) async {
    try {
      return await client.quote.getDeliveryQuote(lat, lng).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final distance = _haversineDistance(16.4850, 80.6900, lat, lng);
      final serviceable = distance <= 5.0;
      final fee = serviceable ? _calculateFeePaise(distance) : 0;
      return DeliveryQuote(
        serviceable: serviceable,
        distanceKm: double.parse(distance.toStringAsFixed(2)),
        feePaise: fee,
        message: serviceable
            ? 'Serviceable (${distance.toStringAsFixed(1)} km from Kanuru)'
            : 'Delivery location is ${distance.toStringAsFixed(1)} km away. Maximum service radius is 5.0 km.',
      );
    }
  }

  Future<OrderRecord> createOrder({
    required String customerPhone,
    String? customerName,
    required String deliveryAddress,
    String? landmark,
    required double latitude,
    required double longitude,
    required List<OrderItem> items,
  }) async {
    try {
      return await client.order.createOrder(
        customerPhone,
        customerName,
        deliveryAddress,
        landmark,
        latitude,
        longitude,
        items,
      ).timeout(const Duration(milliseconds: 2000));
    } catch (_) {
      // Local fallback logic
      final dist = _haversineDistance(16.4850, 80.6900, latitude, longitude);
      if (dist > 5.0) {
        throw Exception('Location exceeds 5.0 km delivery radius.');
      }
      final fee = _calculateFeePaise(dist);
      int subtotal = 0;
      final List<OrderItem> validated = [];
      for (final item in items) {
        final prod = MockData.getProductBySku(item.productSku);
        if (prod != null) {
          final price = prod.offerPricePaise ?? prod.pricePaise;
          final itemTotal = price * item.quantity;
          subtotal += itemTotal;
          validated.add(OrderItem(
            productSku: prod.sku,
            nameSnapshot: prod.name,
            unitPricePaise: price,
            quantity: item.quantity,
            optionsSnapshot: item.optionsSnapshot,
            subtotalPaise: itemTotal,
          ));
        }
      }
      final now = DateTime.now();
      final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
      final orderNumber = 'DSMW-$dateStr-${_orderSeq++}';

      final record = OrderRecord(
        orderNumber: orderNumber,
        customerPhone: customerPhone,
        customerName: customerName,
        deliveryAddress: deliveryAddress,
        landmark: landmark,
        latitude: latitude,
        longitude: longitude,
        distanceKm: double.parse(dist.toStringAsFixed(2)),
        status: 'awaiting_payment',
        subtotalPaise: subtotal,
        deliveryFeePaise: fee,
        totalPaise: subtotal + fee,
        currency: 'INR',
        items: validated,
        prepTimeMinutes: null,
        rejectionReason: null,
        packingChecklistConfirmed: false,
        createdAt: now,
        updatedAt: now,
      );
      _orders[orderNumber] = record;
      _logLocalEvent(orderNumber, 'order_created', 'customer', 'Order created');
      return record;
    }
  }

  Future<OrderRecord?> getOrder(String orderNumber) async {
    try {
      return await client.order.getOrder(orderNumber).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      return _orders[orderNumber];
    }
  }

  Future<List<OrderRecord>> listAllOrders([String? statusFilter]) async {
    try {
      return await client.admin.listAllOrders(statusFilter).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      if (statusFilter == null || statusFilter.isEmpty) {
        return _orders.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      }
      return _orders.values.where((o) => o.status.toLowerCase() == statusFilter.toLowerCase()).toList()
        ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
  }

  Future<PaymentAttempt> createCheckoutSession(String orderNumber, String paymentMethod) async {
    try {
      return await client.checkout.createCheckoutSession(orderNumber, paymentMethod).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final order = _orders[orderNumber];
      return PaymentAttempt(
        orderNumber: orderNumber,
        provider: 'generic_simulator',
        externalId: 'PAY-${DateTime.now().millisecondsSinceEpoch}',
        amountPaise: order?.totalPaise ?? 0,
        status: 'pending',
        paymentMethod: paymentMethod,
        rawReference: null,
        createdAt: DateTime.now(),
      );
    }
  }

  Future<bool> processPaymentWebhook({
    required String orderNumber,
    required String externalId,
    required String status,
    required int amountPaise,
  }) async {
    try {
      return await client.paymentWebhook.processWebhook(
        'generic_simulator',
        externalId,
        orderNumber,
        status,
        amountPaise,
        null,
      ).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final order = _orders[orderNumber];
      if (order != null) {
        order.status = 'shop_acceptance_pending';
        order.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'payment_successful', 'payment_gateway', 'Payment verified');
        _logLocalEvent(orderNumber, 'shop_acceptance_pending', 'system', 'Queued for shop review');
        return true;
      }
      return false;
    }
  }

  Future<OrderRecord?> acceptOrder(String orderNumber, int prepTimeMinutes) async {
    try {
      return await client.admin.acceptOrder(orderNumber, prepTimeMinutes).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'preparing';
        o.prepTimeMinutes = prepTimeMinutes;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_accepted', 'staff', 'Accepted with prep time $prepTimeMinutes mins');
      }
      return o;
    }
  }

  Future<OrderRecord?> rejectOrder(String orderNumber, String reason) async {
    try {
      return await client.admin.rejectOrder(orderNumber, reason).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'rejected';
        o.rejectionReason = reason;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_rejected', 'staff', 'Rejected: $reason. Auto-refund initiated.');
      }
      return o;
    }
  }

  Future<OrderRecord?> markReady(String orderNumber) async {
    try {
      return await client.admin.markReady(orderNumber).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'ready_for_pickup';
        o.packingChecklistConfirmed = true;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_ready', 'staff', 'Packaging verified and ready for delivery');
      }
      return o;
    }
  }

  Future<OrderRecord?> assignDelivery({
    required String orderNumber,
    required String provider,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
    bool manualFallback = false,
    String? notes,
  }) async {
    try {
      return await client.admin.assignDelivery(
        orderNumber,
        provider,
        riderName,
        riderPhone,
        trackingUrl,
        manualFallback,
        notes,
      ).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'out_for_delivery';
        o.updatedAt = DateTime.now();
        _deliveryJobs[orderNumber] = DeliveryJob(
          orderNumber: orderNumber,
          provider: provider,
          externalId: 'DEL-${DateTime.now().millisecondsSinceEpoch}',
          quotePaise: o.deliveryFeePaise,
          status: 'assigned',
          trackingUrl: trackingUrl,
          riderName: riderName,
          riderPhone: riderPhone,
          manualFallback: manualFallback,
          notes: notes,
          updatedAt: DateTime.now(),
        );
        _logLocalEvent(orderNumber, 'delivery_dispatched', 'staff', 'Dispatched via $provider');
      }
      return o;
    }
  }

  Future<OrderRecord?> markDelivered(String orderNumber) async {
    try {
      return await client.admin.markDelivered(orderNumber).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'delivered';
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_delivered', 'delivery_partner', 'Delivered');
      }
      return o;
    }
  }

  Future<OrderRecord?> cancelOrder(String orderNumber, String reason) async {
    try {
      return await client.order.cancelOrder(orderNumber, reason).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'rejected';
        o.rejectionReason = 'Cancelled: $reason';
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_cancelled', 'customer', 'Cancelled by customer: $reason');
      }
      return o;
    }
  }

  Future<List<OrderEvent>> getOrderEvents(String orderNumber) async {
    try {
      return await client.admin.getOrderEvents(orderNumber).timeout(const Duration(milliseconds: 1500));
    } catch (_) {
      return _orderEvents[orderNumber] ?? [];
    }
  }

  void _logLocalEvent(String orderNumber, String type, String actorType, String payload) {
    final event = OrderEvent(
      orderNumber: orderNumber,
      type: type,
      actorType: actorType,
      actorId: null,
      payload: payload,
      timestamp: DateTime.now(),
    );
    _orderEvents.putIfAbsent(orderNumber, () => []).add(event);
  }
}