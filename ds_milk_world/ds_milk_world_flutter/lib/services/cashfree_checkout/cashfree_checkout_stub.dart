class CashfreeCheckoutResult {
  final bool isSuccess;
  final bool isDismissed;
  final bool isRedirecting;
  final String? error;
  final String? rawResponse;

  CashfreeCheckoutResult({
    required this.isSuccess,
    this.isDismissed = false,
    this.isRedirecting = false,
    this.error,
    this.rawResponse,
  });
}

Future<CashfreeCheckoutResult> launchCashfreeWebCheckout({
  required String paymentSessionId,
  String redirectTarget = '_modal',
}) async {
  return CashfreeCheckoutResult(
    isSuccess: true,
    rawResponse: '{"stub": true}',
  );
}
