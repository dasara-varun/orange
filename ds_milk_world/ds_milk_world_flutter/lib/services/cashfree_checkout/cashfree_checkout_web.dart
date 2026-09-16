import 'dart:convert';
import 'dart:js_interop';
import 'cashfree_checkout_stub.dart';

@JS('launchCashfreeCheckout')
external JSPromise<JSString> _launchCashfreeCheckout(JSString sessionId, JSString redirectTarget);

Future<CashfreeCheckoutResult> launchCashfreeWebCheckout({
  required String paymentSessionId,
  String redirectTarget = '_modal',
}) async {
  try {
    final promise = _launchCashfreeCheckout(paymentSessionId.toJS, redirectTarget.toJS);
    final jsResult = await promise.toDart;
    final jsonStr = jsResult.toDart;
    final data = jsonDecode(jsonStr) as Map<String, dynamic>;

    if (data.containsKey('error')) {
      final err = data['error'];
      final msg = err is Map ? (err['message'] ?? 'Payment was not completed.') : err.toString();
      final isDismissed = msg.toString().toLowerCase().contains('dismiss') ||
          msg.toString().toLowerCase().contains('close') ||
          msg.toString().toLowerCase().contains('cancel') ||
          msg.toString().toLowerCase().contains('user');
      return CashfreeCheckoutResult(
        isSuccess: false,
        isDismissed: isDismissed,
        error: msg.toString(),
        rawResponse: jsonStr,
      );
    }

    if (data['redirect'] == true) {
      return CashfreeCheckoutResult(
        isSuccess: false,
        isRedirecting: true,
        rawResponse: jsonStr,
      );
    }

    if (data.containsKey('paymentDetails')) {
      return CashfreeCheckoutResult(
        isSuccess: true,
        rawResponse: jsonStr,
      );
    }

    return CashfreeCheckoutResult(
      isSuccess: true,
      rawResponse: jsonStr,
    );
  } catch (e) {
    return CashfreeCheckoutResult(
      isSuccess: false,
      error: e.toString(),
    );
  }
}
