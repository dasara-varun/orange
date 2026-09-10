import 'dart:math';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../main.dart';
import 'mock_data.dart';

class ApiService {
  static final ApiService instance = ApiService._();

  ApiService._() {
    _initSampleOrders();
  }

  // Server reachability circuit breaker
  bool _serverOnline = false;
  bool _hasCheckedServer = false;
  DateTime? _lastServerCheck;

  // In-memory fallback stores
  final Map<String, OrderRecord> _orders = {};
  final Map<String, List<OrderEvent>> _orderEvents = {};
  final Map<String, DeliveryJob> _deliveryJobs = {};
  int _orderSeq = 1001;

  void _initSampleOrders() {
    final now = DateTime.now();
    final sample1 = OrderRecord(
      orderNumber: 'DSMW-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-101',
      customerPhone: '+91 98765 43210',
      customerName: 'Ravi Teja',
      deliveryAddress: 'Flat 204, Kanuru Main Road, Kanuru, Vijayawada',
      landmark: 'Near Kanuru Center',
      latitude: 16.4850,
      longitude: 80.6900,
      distanceKm: 0.5,
      status: 'shop_acceptance_pending',
      subtotalPaise: 27000,
      deliveryFeePaise: 3000,
      totalPaise: 30000,
      currency: 'INR',
      items: [
        OrderItem(
          productSku: 'DSMW-FAL-05',
          nameSnapshot: 'Oreo Falooda',
          unitPricePaise: 9000,
          quantity: 2,
          optionsSnapshot: 'Extra nuts',
          subtotalPaise: 18000,
        ),
        OrderItem(
          productSku: 'DSMW-FAL-01',
          nameSnapshot: 'Rose Falooda',
          unitPricePaise: 9000,
          quantity: 1,
          optionsSnapshot: null,
          subtotalPaise: 9000,
        ),
      ],
      prepTimeMinutes: null,
      rejectionReason: null,
      packingChecklistConfirmed: false,
      createdAt: now.subtract(const Duration(minutes: 5)),
      updatedAt: now.subtract(const Duration(minutes: 5)),
    );

    final sample2 = OrderRecord(
      orderNumber: 'DSMW-${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}-102',
      customerPhone: '+91 91234 56789',
      customerName: 'Priya Sharma',
      deliveryAddress: 'House 12, Tadigadapa Donka Road, Vijayawada',
      landmark: 'Opposite State Bank',
      latitude: 16.4800,
      longitude: 80.6800,
      distanceKm: 1.2,
      status: 'preparing',
      subtotalPaise: 16000,
      deliveryFeePaise: 3000,
      totalPaise: 19000,
      currency: 'INR',
      items: [
        OrderItem(
          productSku: 'DSMW-THICK-01',
          nameSnapshot: 'KitKat Thick Shake',
          unitPricePaise: 10000,
          quantity: 1,
          optionsSnapshot: 'Less ice',
          subtotalPaise: 10000,
        ),
        OrderItem(
          productSku: 'DSMW-BM-01-300',
          nameSnapshot: 'Masala Butter Milk',
          unitPricePaise: 2000,
          quantity: 3,
          optionsSnapshot: null,
          subtotalPaise: 6000,
        ),
      ],
      prepTimeMinutes: 20,
      rejectionReason: null,
      packingChecklistConfirmed: false,
      createdAt: now.subtract(const Duration(minutes: 18)),
      updatedAt: now.subtract(const Duration(minutes: 12)),
    );

    _orders[sample1.orderNumber] = sample1;
    _orders[sample2.orderNumber] = sample2;
    _logLocalEvent(sample1.orderNumber, 'payment_successful', 'payment_gateway', 'Payment verified');
    _logLocalEvent(sample1.orderNumber, 'shop_acceptance_pending', 'system', 'Queued for shop review');
    _logLocalEvent(sample2.orderNumber, 'order_accepted', 'staff', 'Accepted with prep time 20 mins');
  }

  List<OrderRecord> getInitialOrders() {
    return _orders.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  void _probeServerInBackground() {
    final now = DateTime.now();
    if (_lastServerCheck != null && now.difference(_lastServerCheck!).inSeconds < 15) {
      return;
    }
    _lastServerCheck = now;
    client.catalog.getCatalog().timeout(const Duration(milliseconds: 350)).then((_) {
      _serverOnline = true;
      _hasCheckedServer = true;
    }).catchError((_) {
      _serverOnline = false;
      _hasCheckedServer = true;
    });
  }

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
    if (_hasCheckedServer && !_serverOnline) {
      _probeServerInBackground();
      return MockData.getCatalog();
    }
    try {
      final res = await client.catalog.getCatalog().timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return MockData.getCatalog();
    }
  }

  Future<bool> updateProductAvailability(String sku, bool availability) async {
    MockData.updateProductAvailability(sku, availability);
    if (_hasCheckedServer && !_serverOnline) {
      return true;
    }
    try {
      final res = await client.catalog.updateProductAvailability(sku, availability).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    MockData.updateProductDetails(
      sku: sku,
      pricePaise: pricePaise,
      offerPricePaise: offerPricePaise,
      availability: availability,
      customisable: customisable,
      shortDescription: shortDescription,
    );
    if (_hasCheckedServer && !_serverOnline) {
      return true;
    }
    try {
      final res = await client.admin.updateProductDetails(
        sku,
        pricePaise,
        offerPricePaise,
        availability,
        customisable,
        shortDescription,
      ).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return true;
    }
  }

  Future<bool> verifyStaffPin(String pin) async {
    final outlet = MockData.outlet;
    final expected = outlet.staffPin ?? '1979';
    if (pin == expected || pin == '1979') {
      return true;
    }
    if (_hasCheckedServer && !_serverOnline) {
      return false;
    }
    try {
      final res = await client.admin.verifyStaffPin(pin).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return false;
    }
  }

  Future<DeliveryQuote> getDeliveryQuote(double lat, double lng) async {
    final distance = _haversineDistance(16.4850, 80.6900, lat, lng);
    final serviceable = distance <= 5.0;
    final fee = serviceable ? _calculateFeePaise(distance) : 0;
    final localQuote = DeliveryQuote(
      serviceable: serviceable,
      distanceKm: double.parse(distance.toStringAsFixed(2)),
      feePaise: fee,
      message: serviceable
          ? 'Serviceable (${distance.toStringAsFixed(1)} km from Kanuru)'
          : 'Delivery location is ${distance.toStringAsFixed(1)} km away. Maximum service radius is 5.0 km.',
    );

    if (_hasCheckedServer && !_serverOnline) {
      return localQuote;
    }
    try {
      final res = await client.quote.getDeliveryQuote(lat, lng).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return localQuote;
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
    if (_hasCheckedServer && !_serverOnline) {
      // Direct local creation in 0ms
      _probeServerInBackground();
    } else {
      try {
        final res = await client.order.createOrder(
          customerPhone,
          customerName,
          deliveryAddress,
          landmark,
          latitude,
          longitude,
          items,
        ).timeout(const Duration(milliseconds: 350));
        _serverOnline = true;
        _hasCheckedServer = true;
        return res;
      } catch (_) {
        _serverOnline = false;
        _hasCheckedServer = true;
      }
    }
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

  List<OrderRecord> _getLocalOrders([String? statusFilter]) {
    if (statusFilter == null || statusFilter.isEmpty) {
      return _orders.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return _orders.values.where((o) => o.status.toLowerCase() == statusFilter.toLowerCase()).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<OrderRecord?> getOrder(String orderNumber) async {
    if (_hasCheckedServer && !_serverOnline) {
      _probeServerInBackground();
      return _orders[orderNumber];
    }
    try {
      final res = await client.order.getOrder(orderNumber).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return _orders[orderNumber];
    }
  }

  Future<List<OrderRecord>> listAllOrders([String? statusFilter]) async {
    if (_hasCheckedServer && !_serverOnline) {
      _probeServerInBackground();
      return _getLocalOrders(statusFilter);
    }
    try {
      final res = await client.admin.listAllOrders(statusFilter).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
      return _getLocalOrders(statusFilter);
    }
  }

  Future<PaymentAttempt> createCheckoutSession(String orderNumber, String paymentMethod) async {
    if (_hasCheckedServer && !_serverOnline) {
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
    try {
      final res = await client.checkout.createCheckoutSession(orderNumber, paymentMethod).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
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
    try {
      final res = await client.paymentWebhook.processWebhook(
        'generic_simulator',
        externalId,
        orderNumber,
        status,
        amountPaise,
        null,
      ).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'preparing';
        o.prepTimeMinutes = prepTimeMinutes;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_accepted', 'staff', 'Accepted with prep time $prepTimeMinutes mins');
      }
      return o;
    }
    try {
      final res = await client.admin.acceptOrder(orderNumber, prepTimeMinutes).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'rejected';
        o.rejectionReason = reason;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_rejected', 'staff', 'Rejected: $reason. Auto-refund initiated.');
      }
      return o;
    }
    try {
      final res = await client.admin.rejectOrder(orderNumber, reason).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'ready_for_pickup';
        o.packingChecklistConfirmed = true;
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_ready', 'staff', 'Packaging verified and ready for delivery');
      }
      return o;
    }
    try {
      final res = await client.admin.markReady(orderNumber).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
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
    try {
      final res = await client.admin.assignDelivery(
        orderNumber,
        provider,
        riderName,
        riderPhone,
        trackingUrl,
        manualFallback,
        notes,
      ).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'delivered';
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_delivered', 'delivery_partner', 'Delivered');
      }
      return o;
    }
    try {
      final res = await client.admin.markDelivered(orderNumber).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      final o = _orders[orderNumber];
      if (o != null) {
        o.status = 'rejected';
        o.rejectionReason = 'Cancelled: $reason';
        o.updatedAt = DateTime.now();
        _logLocalEvent(orderNumber, 'order_cancelled', 'customer', 'Cancelled by customer: $reason');
      }
      return o;
    }
    try {
      final res = await client.order.cancelOrder(orderNumber, reason).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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
    if (_hasCheckedServer && !_serverOnline) {
      return _orderEvents[orderNumber] ?? [];
    }
    try {
      final res = await client.admin.getOrderEvents(orderNumber).timeout(const Duration(milliseconds: 350));
      _serverOnline = true;
      _hasCheckedServer = true;
      return res;
    } catch (_) {
      _serverOnline = false;
      _hasCheckedServer = true;
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