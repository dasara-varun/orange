import 'package:serverpod/serverpod.dart';
import '../generated/protocol.dart';
import '../services/order_service.dart';

class CheckoutEndpoint extends Endpoint {
  Future<PaymentAttempt> createCheckoutSession(
    Session session,
    String orderNumber,
    String paymentMethod,
  ) async {
    return OrderService.createCheckoutSession(
      orderNumber: orderNumber,
      paymentMethod: paymentMethod,
    );
  }
}