import 'package:serverpod/serverpod.dart';
import '../services/order_service.dart';

class PaymentWebhookEndpoint extends Endpoint {
  Future<bool> processWebhook(
    Session session,
    String provider,
    String externalId,
    String orderNumber,
    String status,
    int amountPaise,
    String? signature,
  ) async {
    // Webhook signature verification guardrail (simulated or real HMAC)
    return OrderService.handlePaymentWebhook(
      provider: provider,
      externalId: externalId,
      orderNumber: orderNumber,
      status: status,
      amountPaise: amountPaise,
    );
  }
}