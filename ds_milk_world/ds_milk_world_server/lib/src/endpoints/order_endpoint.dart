import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/order_service.dart';

class OrderEndpoint extends Endpoint {
  Future<OrderRecord> createOrder(
    Session session,
    String customerPhone,
    String? customerName,
    String deliveryAddress,
    String? landmark,
    double latitude,
    double longitude,
    List<OrderItem> items,
  ) async {
    return OrderService.createOrder(
      customerPhone: customerPhone,
      customerName: customerName,
      deliveryAddress: deliveryAddress,
      landmark: landmark,
      latitude: latitude,
      longitude: longitude,
      requestedItems: items,
    );
  }

  Future<OrderRecord?> getOrder(Session session, String orderNumber) async {
    return OrderService.getOrder(orderNumber);
  }

  Future<List<OrderRecord>> listActiveOrders(Session session) async {
    return OrderService.listActiveOrders();
  }

  Future<OrderRecord?> cancelOrder(
    Session session,
    String orderNumber,
    String reason,
  ) async {
    return OrderService.cancelOrder(
      orderNumber: orderNumber,
      reason: reason,
      actorType: 'customer',
    );
  }
}