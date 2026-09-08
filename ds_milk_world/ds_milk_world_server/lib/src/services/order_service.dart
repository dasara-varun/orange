import '../generated/protocol.dart';
import 'geo_service.dart';
import 'catalog_service.dart';

class OrderService {
  static final Map<String, OrderRecord> _orders = {};
  static final Map<String, List<PaymentAttempt>> _paymentAttempts = {};
  static final Map<String, DeliveryJob> _deliveryJobs = {};
  static final Map<String, List<RefundRecord>> _refunds = {};
  static final Map<String, List<OrderEvent>> _orderEvents = {};
  static int _orderSequence = 1001;

  static String _generateOrderNumber() {
    final now = DateTime.now();
    final dateStr = '${now.year}${now.month.toString().padLeft(2, '0')}${now.day.toString().padLeft(2, '0')}';
    final seq = _orderSequence++;
    return 'DSMW-$dateStr-$seq';
  }

  static void _logEvent({
    required String orderNumber,
    required String type,
    required String actorType,
    String? actorId,
    String? payload,
  }) {
    final event = OrderEvent(
      orderNumber: orderNumber,
      type: type,
      actorType: actorType,
      actorId: actorId,
      payload: payload,
      timestamp: DateTime.now(),
    );
    _orderEvents.putIfAbsent(orderNumber, () => []).add(event);
  }

  /// Creates a new order with server-calculated pricing and geo-validation
  static OrderRecord createOrder({
    required String customerPhone,
    String? customerName,
    required String deliveryAddress,
    String? landmark,
    required double latitude,
    required double longitude,
    required List<OrderItem> requestedItems,
  }) {
    if (requestedItems.isEmpty) {
      throw ArgumentError('Order must contain at least one item');
    }

    // 1. Geo-validation & distance calculation
    final distanceKm = GeoService.calculateDistanceKm(
      GeoService.outletLat,
      GeoService.outletLng,
      latitude,
      longitude,
    );

    if (distanceKm > GeoService.maxServiceRadiusKm) {
      throw ArgumentError(
        'Delivery location is ${(distanceKm).toStringAsFixed(1)} km away, exceeding maximum service radius of ${GeoService.maxServiceRadiusKm} km.',
      );
    }

    final deliveryFeePaise = GeoService.calculateDeliveryFeePaise(distanceKm);

    // 2. Server-side price calculation (strictly ignore any client pricing)
    int subtotalPaise = 0;
    final List<OrderItem> validatedItems = [];

    for (final reqItem in requestedItems) {
      final product = CatalogService.getProductBySku(reqItem.productSku);
      if (product == null) {
        throw ArgumentError('Product with SKU ${reqItem.productSku} not found');
      }
      if (!product.availability) {
        throw ArgumentError('Product "${product.name}" is currently out of stock');
      }
      if (reqItem.quantity <= 0) {
        throw ArgumentError('Quantity must be greater than 0');
      }

      final unitPrice = product.offerPricePaise ?? product.pricePaise;
      final itemSubtotal = unitPrice * reqItem.quantity;
      subtotalPaise += itemSubtotal;

      validatedItems.add(
        OrderItem(
          productSku: product.sku,
          nameSnapshot: product.name,
          unitPricePaise: unitPrice,
          quantity: reqItem.quantity,
          optionsSnapshot: reqItem.optionsSnapshot,
          subtotalPaise: itemSubtotal,
        ),
      );
    }

    final totalPaise = subtotalPaise + deliveryFeePaise;
    final orderNumber = _generateOrderNumber();
    final now = DateTime.now();

    final order = OrderRecord(
      orderNumber: orderNumber,
      customerPhone: customerPhone,
      customerName: customerName,
      deliveryAddress: deliveryAddress,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
      distanceKm: double.parse(distanceKm.toStringAsFixed(2)),
      status: 'awaiting_payment',
      subtotalPaise: subtotalPaise,
      deliveryFeePaise: deliveryFeePaise,
      totalPaise: totalPaise,
      currency: 'INR',
      items: validatedItems,
      prepTimeMinutes: null,
      rejectionReason: null,
      packingChecklistConfirmed: false,
      createdAt: now,
      updatedAt: now,
    );

    _orders[orderNumber] = order;

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_created',
      actorType: 'customer',
      payload: 'Created order with ${validatedItems.length} items, total: Rs ${(totalPaise / 100).toStringAsFixed(2)}',
    );

    return order;
  }

  static OrderRecord? getOrder(String orderNumber) {
    return _orders[orderNumber];
  }

  static List<OrderRecord> listActiveOrders() {
    return _orders.values.where((o) => o.status != 'delivered' && o.status != 'rejected').toList();
  }

  static List<OrderRecord> listAllOrders([String? statusFilter]) {
    if (statusFilter == null || statusFilter.isEmpty) {
      return _orders.values.toList()..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    }
    return _orders.values
        .where((o) => o.status.toLowerCase() == statusFilter.toLowerCase())
        .toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Create checkout session / payment attempt
  static PaymentAttempt createCheckoutSession({
    required String orderNumber,
    required String paymentMethod,
  }) {
    final order = _orders[orderNumber];
    if (order == null) {
      throw ArgumentError('Order $orderNumber not found');
    }

    if (order.status != 'awaiting_payment' && order.status != 'draft') {
      throw StateError('Order is in status ${order.status}, cannot initiate checkout');
    }

    final externalId = 'PAY-${DateTime.now().millisecondsSinceEpoch}';
    final attempt = PaymentAttempt(
      orderNumber: orderNumber,
      provider: 'generic_simulator',
      externalId: externalId,
      amountPaise: order.totalPaise,
      status: 'pending',
      paymentMethod: paymentMethod,
      rawReference: null,
      createdAt: DateTime.now(),
    );

    _paymentAttempts.putIfAbsent(orderNumber, () => []).add(attempt);

    _logEvent(
      orderNumber: orderNumber,
      type: 'payment_attempt_created',
      actorType: 'customer',
      payload: 'Attempt $externalId initiated via $paymentMethod',
    );

    return attempt;
  }

  /// Process payment webhook with strict idempotency
  static bool handlePaymentWebhook({
    required String provider,
    required String externalId,
    required String orderNumber,
    required String status,
    required int amountPaise,
    String? rawPayload,
  }) {
    final order = _orders[orderNumber];
    if (order == null) return false;

    // Check if order is already processed for payment (Idempotency)
    if (order.status != 'awaiting_payment' && order.status != 'draft') {
      // Already paid or further along in state machine; idempotently ignore
      return true;
    }

    final attempts = _paymentAttempts[orderNumber] ?? [];
    PaymentAttempt? matchingAttempt;
    try {
      matchingAttempt = attempts.firstWhere((a) => a.externalId == externalId);
    } catch (_) {
      matchingAttempt = null;
    }

    if (status.toLowerCase() == 'successful' || status.toLowerCase() == 'paid') {
      if (matchingAttempt != null) {
        matchingAttempt.status = 'success';
      }
      order.status = 'shop_acceptance_pending';
      order.updatedAt = DateTime.now();

      _logEvent(
        orderNumber: orderNumber,
        type: 'payment_successful',
        actorType: 'payment_gateway',
        payload: 'Amount: Rs ${(amountPaise / 100).toStringAsFixed(2)}, Ref: $externalId',
      );
      _logEvent(
        orderNumber: orderNumber,
        type: 'shop_acceptance_pending',
        actorType: 'system',
        payload: 'Order queued for shop review',
      );
      return true;
    } else {
      if (matchingAttempt != null) {
        matchingAttempt.status = 'failed';
      }
      _logEvent(
        orderNumber: orderNumber,
        type: 'payment_failed',
        actorType: 'payment_gateway',
        payload: 'Payment failed for $externalId',
      );
      return false;
    }
  }

  /// Staff: Accept order with estimated prep time
  static OrderRecord acceptOrder({
    required String orderNumber,
    required int prepTimeMinutes,
  }) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    if (order.status != 'shop_acceptance_pending' && order.status != 'paid') {
      throw StateError('Order status is ${order.status}, cannot accept');
    }

    order.status = 'preparing';
    order.prepTimeMinutes = prepTimeMinutes;
    order.updatedAt = DateTime.now();

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_accepted',
      actorType: 'staff',
      payload: 'Accepted with estimated prep time: $prepTimeMinutes mins',
    );

    return order;
  }

  /// Staff: Reject order with mandatory reason -> triggers refund
  static OrderRecord rejectOrder({
    required String orderNumber,
    required String reason,
  }) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    order.status = 'rejected';
    order.rejectionReason = reason;
    order.updatedAt = DateTime.now();

    // Auto-create refund record for paid orders
    final refund = RefundRecord(
      orderNumber: orderNumber,
      amountPaise: order.totalPaise,
      reason: 'Shop Rejected: $reason',
      status: 'completed',
      providerReference: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );
    _refunds.putIfAbsent(orderNumber, () => []).add(refund);

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_rejected',
      actorType: 'staff',
      payload: 'Rejected. Reason: $reason. Auto-refund initiated.',
    );

    return order;
  }

  /// Staff: Mark order ready for pickup (packing checklist confirmed)
  static OrderRecord markReady(String orderNumber) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    if (order.status != 'preparing') {
      throw StateError('Order status is ${order.status}, cannot mark ready');
    }

    order.status = 'ready_for_pickup';
    order.packingChecklistConfirmed = true;
    order.updatedAt = DateTime.now();

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_ready',
      actorType: 'staff',
      payload: 'Packaging checked and sealed. Ready for delivery pickup.',
    );

    return order;
  }

  /// Staff: Assign delivery (Rapido / Aggregator / Manual Fallback)
  static OrderRecord assignDelivery({
    required String orderNumber,
    required String provider,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
    bool manualFallback = false,
    String? notes,
  }) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    order.status = 'out_for_delivery';
    order.updatedAt = DateTime.now();

    final job = DeliveryJob(
      orderNumber: orderNumber,
      provider: provider,
      externalId: 'DEL-${DateTime.now().millisecondsSinceEpoch}',
      quotePaise: order.deliveryFeePaise,
      status: 'assigned',
      trackingUrl: trackingUrl,
      riderName: riderName,
      riderPhone: riderPhone,
      manualFallback: manualFallback,
      notes: notes,
      updatedAt: DateTime.now(),
    );

    _deliveryJobs[orderNumber] = job;

    _logEvent(
      orderNumber: orderNumber,
      type: 'delivery_dispatched',
      actorType: 'staff',
      payload: 'Dispatched via $provider. Rider: $riderName ($riderPhone)',
    );

    return order;
  }

  /// Staff: Mark order delivered
  static OrderRecord markDelivered(String orderNumber) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    order.status = 'delivered';
    order.updatedAt = DateTime.now();

    final job = _deliveryJobs[orderNumber];
    if (job != null) {
      job.status = 'delivered';
      job.updatedAt = DateTime.now();
    }

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_delivered',
      actorType: 'delivery_partner',
      payload: 'Order delivered successfully to customer',
    );

    return order;
  }

  /// Manual refund creation
  static RefundRecord createRefund({
    required String orderNumber,
    required int amountPaise,
    required String reason,
  }) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    final refund = RefundRecord(
      orderNumber: orderNumber,
      amountPaise: amountPaise,
      reason: reason,
      status: 'completed',
      providerReference: 'REF-${DateTime.now().millisecondsSinceEpoch}',
      createdAt: DateTime.now(),
    );

    _refunds.putIfAbsent(orderNumber, () => []).add(refund);

    _logEvent(
      orderNumber: orderNumber,
      type: 'refund_issued',
      actorType: 'staff',
      payload: 'Refunded Rs ${(amountPaise / 100).toStringAsFixed(2)}. Reason: $reason',
    );

    return refund;
  }

  /// Cancel order subject to policy (allowed before food prep begins)
  static OrderRecord cancelOrder({
    required String orderNumber,
    required String reason,
    String actorType = 'customer',
  }) {
    final order = _orders[orderNumber];
    if (order == null) throw ArgumentError('Order $orderNumber not found');

    if (order.status == 'preparing' ||
        order.status == 'ready_for_pickup' ||
        order.status == 'out_for_delivery' ||
        order.status == 'delivered') {
      throw StateError('Order is already in "${order.status}" stage; cannot cancel after kitchen has started.');
    }

    final previousStatus = order.status;
    order.status = 'rejected';
    order.rejectionReason = 'Cancelled ($actorType): $reason';
    order.updatedAt = DateTime.now();

    // If order was already paid, issue refund
    if (previousStatus == 'shop_acceptance_pending' || previousStatus == 'paid') {
      final refund = RefundRecord(
        orderNumber: orderNumber,
        amountPaise: order.totalPaise,
        reason: 'Order cancelled before prep: $reason',
        status: 'completed',
        providerReference: 'REF-${DateTime.now().millisecondsSinceEpoch}',
        createdAt: DateTime.now(),
      );
      _refunds.putIfAbsent(orderNumber, () => []).add(refund);
    }

    _logEvent(
      orderNumber: orderNumber,
      type: 'order_cancelled',
      actorType: actorType,
      payload: 'Cancelled ($actorType). Reason: $reason',
    );

    return order;
  }

  /// Process incoming delivery webhook event (rider assigned, picked up, delivered, failed)
  static bool handleDeliveryWebhook({
    required String orderNumber,
    required String provider,
    required String eventType,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
  }) {
    final order = _orders[orderNumber];
    if (order == null) return false;

    var job = _deliveryJobs[orderNumber];
    if (job == null) {
      job = DeliveryJob(
        orderNumber: orderNumber,
        provider: provider,
        quotePaise: order.deliveryFeePaise,
        status: eventType,
        riderName: riderName,
        riderPhone: riderPhone,
        trackingUrl: trackingUrl,
        manualFallback: false,
        updatedAt: DateTime.now(),
      );
      _deliveryJobs[orderNumber] = job;
    } else {
      job.status = eventType;
      if (riderName != null) job.riderName = riderName;
      if (riderPhone != null) job.riderPhone = riderPhone;
      if (trackingUrl != null) job.trackingUrl = trackingUrl;
      job.updatedAt = DateTime.now();
    }

    if (eventType == 'picked_up' || eventType == 'out_for_delivery') {
      order.status = 'out_for_delivery';
      order.updatedAt = DateTime.now();
    } else if (eventType == 'delivered') {
      order.status = 'delivered';
      order.updatedAt = DateTime.now();
    }

    _logEvent(
      orderNumber: orderNumber,
      type: 'delivery_webhook_$eventType',
      actorType: 'delivery_partner',
      payload: 'Delivery status updated to $eventType by $provider',
    );

    return true;
  }

  static DeliveryJob? getDeliveryJob(String orderNumber) {
    return _deliveryJobs[orderNumber];
  }

  static List<RefundRecord> getRefunds(String orderNumber) {
    return _refunds[orderNumber] ?? [];
  }

  static List<OrderEvent> getOrderEvents(String orderNumber) {
    return _orderEvents[orderNumber] ?? [];
  }
}