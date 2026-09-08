import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/order_service.dart';

class AdminEndpoint extends Endpoint {
  Future<OrderRecord?> acceptOrder(
    Session session,
    String orderNumber,
    int prepTimeMinutes,
  ) async {
    return OrderService.acceptOrder(
      orderNumber: orderNumber,
      prepTimeMinutes: prepTimeMinutes,
    );
  }

  Future<OrderRecord?> rejectOrder(
    Session session,
    String orderNumber,
    String reason,
  ) async {
    return OrderService.rejectOrder(
      orderNumber: orderNumber,
      reason: reason,
    );
  }

  Future<OrderRecord?> markReady(
    Session session,
    String orderNumber,
  ) async {
    return OrderService.markReady(orderNumber);
  }

  Future<OrderRecord?> assignDelivery(
    Session session,
    String orderNumber,
    String provider,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
    bool manualFallback,
    String? notes,
  ) async {
    return OrderService.assignDelivery(
      orderNumber: orderNumber,
      provider: provider,
      riderName: riderName,
      riderPhone: riderPhone,
      trackingUrl: trackingUrl,
      manualFallback: manualFallback,
      notes: notes,
    );
  }

  Future<OrderRecord?> markDelivered(
    Session session,
    String orderNumber,
  ) async {
    return OrderService.markDelivered(orderNumber);
  }

  Future<DeliveryJob?> getDeliveryJob(
    Session session,
    String orderNumber,
  ) async {
    return OrderService.getDeliveryJob(orderNumber);
  }

  Future<RefundRecord?> createRefund(
    Session session,
    String orderNumber,
    int amountPaise,
    String reason,
  ) async {
    return OrderService.createRefund(
      orderNumber: orderNumber,
      amountPaise: amountPaise,
      reason: reason,
    );
  }

  Future<List<OrderEvent>> getOrderEvents(
    Session session,
    String orderNumber,
  ) async {
    return OrderService.getOrderEvents(orderNumber);
  }

  Future<List<OrderRecord>> listAllOrders(
    Session session,
    String? statusFilter,
  ) async {
    return OrderService.listAllOrders(statusFilter);
  }
}