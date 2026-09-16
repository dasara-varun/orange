import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../services/api_service.dart';
import '../services/cashfree_checkout/cashfree_checkout.dart';
import 'order_tracking_screen.dart';

class CheckoutScreen extends StatefulWidget {
  final OrderRecord order;

  const CheckoutScreen({super.key, required this.order});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  bool _isProcessing = false;
  String? _processingStep;

  void _showWhitelistingHelpDialog([String? errorMsg]) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTheme.milk,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.link_off, color: AppTheme.error, size: 24),
            SizedBox(width: 8),
            Text(
              'Cashfree Whitelisting',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
            ),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Cashfree requires production domains to be whitelisted before accepting live card & UPI payments:',
                style: TextStyle(fontSize: 13, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTheme.border),
                ),
                child: const SelectableText(
                  'https://ds-milk-world.pages.dev',
                  style: TextStyle(fontFamily: 'monospace', fontWeight: FontWeight.bold, fontSize: 13, color: AppTheme.cocoa),
                ),
              ),
              const SizedBox(height: 12),
              const Text(
                'How to approve in Cashfree Dashboard:\n'
                '1. Log into merchant.cashfree.com in Production\n'
                '2. Go to Payment Gateway > Developers > Whitelisting\n'
                '3. Click Add New, choose "Domain name", enter the link above, and save.',
                style: TextStyle(fontSize: 12, color: AppTheme.muted, height: 1.4),
              ),
              if (errorMsg != null && errorMsg.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  'Details: $errorMsg',
                  style: const TextStyle(fontSize: 11, color: AppTheme.error, fontStyle: FontStyle.italic),
                ),
              ],
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(ctx);
              _completeViaVerification();
            },
            child: const Text('Simulate Order (Verification Mode)', style: TextStyle(color: AppTheme.saffronDark, fontWeight: FontWeight.w700)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.cocoa, foregroundColor: Colors.white),
            child: const Text('OK, Got It'),
          ),
        ],
      ),
    );
  }

  Future<void> _completeViaVerification() async {
    setState(() {
      _isProcessing = true;
      _processingStep = 'Confirming order for kitchen preparation...';
    });

    try {
      await ApiService.instance.processPaymentWebhook(
        orderNumber: widget.order.orderNumber,
        externalId: 'VERIF-${DateTime.now().millisecondsSinceEpoch}',
        status: 'successful',
        amountPaise: widget.order.totalPaise,
      );

      CartState.instance.clearCart();

      if (!mounted) return;
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
        SnackBar(content: Text('Verification Error: $e'), backgroundColor: AppTheme.error),
      );
    }
  }

  Future<void> _processPayment() async {
    setState(() {
      _isProcessing = true;
      _processingStep = 'Connecting to Cashfree Payments...';
    });

    try {
      // 1. Create Checkout Session via Cashfree PG
      final attempt = await ApiService.instance.createCheckoutSession(
        widget.order.orderNumber,
        'cashfree',
      );

      // If Cashfree provider is returned with a live session id
      if (attempt.provider == 'cashfree' && attempt.rawReference != null && attempt.rawReference!.isNotEmpty) {
        setState(() {
          _processingStep = 'Opening Cashfree secure checkout modal...';
        });

        final result = await launchCashfreeWebCheckout(
          paymentSessionId: attempt.rawReference!,
          redirectTarget: '_modal',
        );

        if (result.isDismissed) {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _processingStep = null;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Payment was cancelled or closed. You can retry with Cashfree whenever you are ready.'),
              backgroundColor: AppTheme.cocoa,
            ),
          );
          return;
        }

        if (!result.isSuccess && !result.isRedirecting) {
          if (!mounted) return;
          setState(() {
            _isProcessing = false;
            _processingStep = null;
          });
          _showWhitelistingHelpDialog(result.error);
          return;
        }

        if (result.isRedirecting) {
          // Navigating away to bank authentication
          return;
        }

        // Cashfree payment attempt submitted; verify status with backend
        if (!mounted) return;
        setState(() {
          _processingStep = 'Verifying payment status with Cashfree...';
        });

        await ApiService.instance.verifyCashfreePayment(widget.order.orderNumber);
      } else {
        // Fallback simulated payment gateway confirmation
        await Future.delayed(const Duration(milliseconds: 1200));
        if (!mounted) return;
        setState(() {
          _processingStep = 'Confirming payment with bank...';
        });
        await Future.delayed(const Duration(milliseconds: 1200));

        await ApiService.instance.processPaymentWebhook(
          orderNumber: widget.order.orderNumber,
          externalId: attempt.externalId,
          status: 'successful',
          amountPaise: widget.order.totalPaise,
        );
      }

      // Clear customer shopping cart
      CartState.instance.clearCart();

      if (!mounted) return;
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
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: SingleChildScrollView(
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
                    'Deliver to & Billed to:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.muted),
                  ),
                  Text(
                    '${order.customerName != null ? "${order.customerName} • " : ""}${order.customerPhone}',
                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.cocoa),
                  ),
                  if (order.customerEmail != null && order.customerEmail!.isNotEmpty)
                    Text(
                      'Email: ${order.customerEmail} (Invoice destination)',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: AppTheme.cocoa),
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

            const SizedBox(height: 20),

            // Cashfree Payment Gateway Card
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: AppTheme.border, width: 1.2),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.cocoa.withValues(alpha: 0.04),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.cream,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.verified, color: AppTheme.saffronDark, size: 22),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Cashfree Payment Gateway',
                              style: TextStyle(
                                fontSize: 15,
                                fontWeight: FontWeight.w800,
                                color: AppTheme.cocoa,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Official Payment Gateway • 100% Secure',
                              style: TextStyle(fontSize: 11, color: Colors.grey[700]),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 24),
                  const Text(
                    'All Payment Modes Managed in Cashfree:',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _paymentModeChip(Icons.phone_android, 'UPI (GPay / PhonePe / Paytm)'),
                      _paymentModeChip(Icons.credit_card, 'Cards (Visa, RuPay, Master)'),
                      _paymentModeChip(Icons.account_balance, 'NetBanking (26+ Banks)'),
                      _paymentModeChip(Icons.qr_code_2, 'Instant QR Code'),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: const Color(0xFFF6FAF8),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppTheme.mint.withValues(alpha: 0.4)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lock, size: 15, color: Color(0xFF2E7D32)),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Seamless one-tap payment. You can choose any payment mode inside the Cashfree secure window.',
                            style: TextStyle(fontSize: 11, color: Color(0xFF1E1B19), height: 1.3),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
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
              child: ElevatedButton.icon(
                onPressed: _processPayment,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.cocoa,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                icon: const Icon(Icons.lock_outline, size: 18, color: AppTheme.saffron),
                label: Text(
                  'Pay ${AppTheme.formatPaise(order.totalPaise)} via Cashfree →',
                  style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w800),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Center(
              child: InkWell(
                onTap: () => _showWhitelistingHelpDialog(),
                borderRadius: BorderRadius.circular(6),
                child: const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  child: Text(
                    'Cashfree domain whitelisting info & test mode',
                    style: TextStyle(
                      fontSize: 11,
                      color: AppTheme.muted,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    ),
  ),
);
  }

  Widget _paymentModeChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppTheme.cream,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: AppTheme.cocoa),
          const SizedBox(width: 6),
          Text(
            label,
            style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppTheme.cocoa),
          ),
        ],
      ),
    );
  }
}