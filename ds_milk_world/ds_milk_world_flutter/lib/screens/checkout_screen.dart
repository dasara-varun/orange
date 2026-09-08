import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../services/api_service.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final OrderRecord order;

  const CheckoutScreen({super.key, required this.order});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  String _paymentMethod = 'UPI_QR';
  bool _isProcessing = false;
  String? _processingStep;

  void _copyToClipboard(String text, String label) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('$label copied to clipboard!'),
        duration: const Duration(seconds: 2),
        backgroundColor: AppTheme.mint,
      ),
    );
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _processingStep = 'Connecting to payment provider...';
    });

    try {
      // 1. Create Checkout Session
      final attempt = await ApiService.instance.createCheckoutSession(
        widget.order.orderNumber,
        _paymentMethod,
      );

      // 2. Simulated payment gateway interaction / bank confirmation delay
      await Future.delayed(const Duration(milliseconds: 1200));
      if (!mounted) return;
      setState(() {
        _processingStep = 'We are confirming payment with your bank...';
      });
      await Future.delayed(const Duration(milliseconds: 1500));

      // 3. Process webhook idempotently
      await ApiService.instance.processPaymentWebhook(
        orderNumber: widget.order.orderNumber,
        externalId: attempt.externalId,
        status: 'successful',
        amountPaise: widget.order.totalPaise,
      );

      // 4. Clear customer shopping cart
      CartState.instance.clearCart();

      if (!mounted) return;
      // 5. Navigate to live order tracking screen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => OrderTrackingScreen(orderNumber: widget.order.orderNumber),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isProcessing = false;
        _processingStep = null;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment Error: $e'),
          backgroundColor: AppTheme.error,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final order = widget.order;

    if (_isProcessing) {
      return Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(16),
                  child: Image.asset(
                    'assets/images/ds_logo_square.png',
                    width: 72,
                    height: 72,
                    fit: BoxFit.cover,
                  ),
                ),
                const SizedBox(height: 20),
                const SizedBox(
                  width: 36,
                  height: 36,
                  child: CircularProgressIndicator(
                    color: AppTheme.saffronDark,
                    strokeWidth: 3,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  _processingStep ?? 'Processing...',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.cocoa,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Please do not press back or refresh while we verify transaction status.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                'assets/images/ds_logo_icon.png',
                width: 22,
                height: 22,
                fit: BoxFit.cover,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Payment & Handoff'),
          ],
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Order details summary
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          ClipRRect(
                            borderRadius: BorderRadius.circular(4),
                            child: Image.asset(
                              'assets/images/ds_logo_icon.png',
                              width: 18,
                              height: 18,
                              fit: BoxFit.cover,
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            'Order #${order.orderNumber}',
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.cocoa,
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Awaiting Payment',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppTheme.cocoa,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 20),
                  const Text(
                    'Deliver to:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.muted),
                  ),
                  Text(
                    '${order.customerName != null ? "${order.customerName} • " : ""}${order.customerPhone}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cocoa),
                  ),
                  Text(
                    order.deliveryAddress,
                    style: const TextStyle(fontSize: 12, color: AppTheme.cocoa),
                  ),
                  if (order.landmark != null && order.landmark!.isNotEmpty)
                    Text(
                      'Landmark: ${order.landmark}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                    ),
                  const Divider(color: AppTheme.border, height: 20),
                  ...order.items.map((it) => Padding(
                        padding: const EdgeInsets.only(bottom: 6),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${it.quantity}x ${it.nameSnapshot}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.cocoa),
                            ),
                            Text(
                              AppTheme.formatPaise(it.subtotalPaise),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(color: AppTheme.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Items Subtotal:', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                      Text(AppTheme.formatPaise(order.subtotalPaise), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Delivery Fee (${order.distanceKm} km):',
                        style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                      Text(AppTheme.formatPaise(order.deliveryFeePaise), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Total Payable:',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                      ),
                      Text(
                        AppTheme.formatPaise(order.totalPaise),
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text(
              'Select Payment Method',
              style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
            ),
            const SizedBox(height: 10),
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                children: [
                  RadioListTile<String>(
                    value: 'UPI_QR',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.saffronDark,
                    title: const Text('UPI QR Code (Scan to Pay)', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Google Pay, PhonePe, Paytm, BHIM', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                    secondary: const Icon(Icons.qr_code_scanner, color: AppTheme.cocoa),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'UPI_INTENT',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.saffronDark,
                    title: const Text('UPI ID / App Intent', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Pay directly through installed UPI app', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                    secondary: const Icon(Icons.mobile_friendly, color: AppTheme.cocoa),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'CARD',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.saffronDark,
                    title: const Text('Credit or Debit Card', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('Visa, MasterCard, RuPay', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                    secondary: const Icon(Icons.credit_card, color: AppTheme.cocoa),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                  const Divider(height: 1),
                  RadioListTile<String>(
                    value: 'NETBANKING',
                    groupValue: _paymentMethod,
                    activeColor: AppTheme.saffronDark,
                    title: const Text('NetBanking', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                    subtitle: const Text('All major Indian banks', style: TextStyle(fontSize: 11, color: AppTheme.muted)),
                    secondary: const Icon(Icons.account_balance, color: AppTheme.cocoa),
                    onChanged: (v) => setState(() => _paymentMethod = v!),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),

            // UPI QR & App Intent container if selected
            if (_paymentMethod == 'UPI_QR' || _paymentMethod == 'UPI_INTENT') ...[
              Builder(
                builder: (context) {
                  final rupeeAmount = (order.totalPaise / 100).toStringAsFixed(2);
                  final upiId = '9030352248@upi';
                  final upiUri = 'upi://pay?pa=$upiId&pn=DS%20Milk%20World&am=$rupeeAmount&cu=INR&tn=${order.orderNumber}';
                  final qrUrl = 'https://api.qrserver.com/v1/create-qr-code/?size=250x250&data=${Uri.encodeComponent(upiUri)}';

                  return Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.saffron, width: 1.5),
                    ),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.flash_on, color: AppTheme.saffronDark, size: 18),
                            const SizedBox(width: 6),
                            Text(
                              'Instant UPI Payment • ${AppTheme.formatPaise(order.totalPaise)}',
                              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        // Dynamic QR Code
                        Container(
                          width: 170,
                          height: 170,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppTheme.border, width: 1.5),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.08),
                                blurRadius: 8,
                                offset: const Offset(0, 3),
                              ),
                            ],
                          ),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(8),
                            child: Image.network(
                              qrUrl,
                              fit: BoxFit.contain,
                              loadingBuilder: (_, child, progress) =>
                                  progress == null ? child : const Center(child: CircularProgressIndicator(strokeWidth: 2)),
                              errorBuilder: (_, __, ___) => const Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.qr_code_2, size: 80, color: AppTheme.cocoa),
                                    Text('Scan with GPay / PhonePe', style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Scan with Google Pay, PhonePe, Paytm, BHIM, or CRED',
                          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.grey[800]),
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),

                        // Payee details chip
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppTheme.border),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.account_circle, size: 20, color: AppTheme.cocoa),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const Text('UPI ID / Payee Mobile', style: TextStyle(fontSize: 10, color: AppTheme.muted)),
                                    Text(
                                      upiId,
                                      style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.copy, size: 18, color: AppTheme.cocoa),
                                tooltip: 'Copy UPI ID',
                                onPressed: () => _copyToClipboard(upiId, 'UPI ID ($upiId)'),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(height: 12),

                        // 1-Tap Open UPI App Button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton.icon(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.cocoa,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                            icon: const Icon(Icons.open_in_new, size: 18),
                            label: const Text(
                              'Pay via UPI App (Google Pay / PhonePe)',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
                            ),
                            onPressed: () {
                              _copyToClipboard(upiUri, 'Payment link');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Opening UPI App for ₹${(order.totalPaise / 100).toStringAsFixed(0)} to 9030352248@upi...'),
                                  backgroundColor: AppTheme.mint,
                                ),
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ],
            const SizedBox(height: 16),

            // Guarantee & policy notice
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.security, size: 16, color: Color(0xFF2E7D32)),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'DS Milk World Direct Guarantee: If the shop cannot fulfill your fresh order, an instant 100% refund is issued to your original payment method.',
                      style: TextStyle(fontSize: 11, color: AppTheme.cocoa, height: 1.3),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _processPayment,
                child: Text(
                  'Confirm & Pay ${AppTheme.formatPaise(order.totalPaise)} →',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}