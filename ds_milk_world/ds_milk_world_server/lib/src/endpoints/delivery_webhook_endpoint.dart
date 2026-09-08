import 'package:serverpod/serverpod.dart';
import '../services/order_service.dart';

class DeliveryWebhookEndpoint extends Endpoint {
  Future<bool> processWebhook(
    Session session,
    String provider,
    String orderNumber,
    String eventType,
    String? riderName,
    String? riderPhone,
    String? trackingUrl,
    String? signature,
  ) async {
    return OrderService.handleDeliveryWebhook(
      orderNumber: orderNumber,
      provider: provider,
      eventType: eventType,
      riderName: riderName,
      riderPhone: riderPhone,
      trackingUrl: trackingUrl,
    );
  }
}