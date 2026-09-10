import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class OrderTrackingScreen extends StatefulWidget {
  final String orderNumber;

  const OrderTrackingScreen({super.key, required this.orderNumber});

  @override
  State<OrderTrackingScreen> createState() => _OrderTrackingScreenState();
}

class _OrderTrackingScreenState extends State<OrderTrackingScreen> {
  OrderRecord? _order;
  List<OrderEvent> _events = [];
  bool _isLoading = true;
  Timer? _pollingTimer;

  int _rating = 5;
  final Set<String> _feedbackTags = {};
  bool _feedbackSubmitted = false;

  @override
  void initState() {
    super.initState();
    _fetchOrder();
    // Poll order status every 4 seconds for live updates
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _fetchOrder(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    super.dispose();
  }

  Future<void> _fetchOrder({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final order = await ApiService.instance.getOrder(widget.orderNumber);
      final events = await ApiService.instance.getOrderEvents(widget.orderNumber);
      if (mounted) {
        setState(() {
          _order = order;
          _events = events;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  int _getTimelineStep(String status) {
    switch (status.toLowerCase()) {
      case 'awaiting_payment':
      case 'draft':
        return 0;
      case 'paid':
      case 'shop_acceptance_pending':
        return 1;
      case 'preparing':
        return 2;
      case 'ready_for_pickup':
        return 3;
      case 'out_for_delivery':
        return 4;
      case 'delivered':
        return 5;
      case 'rejected':
      case 'refunded':
        return -1;
      default:
        return 1;
    }
  }

  void _showCancelOrderDialog(String orderNumber) {
    final reasonCtrl = TextEditingController(text: 'Customer requested cancellation');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel Order?'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Orders can be cancelled before kitchen preparation starts. 100% of your paid amount will be refunded immediately.',
              style: TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonCtrl,
              decoration: const InputDecoration(labelText: 'Reason for cancellation'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Keep Order')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              Navigator.pop(ctx);
              await ApiService.instance.cancelOrder(orderNumber, reasonCtrl.text.trim());
              _fetchOrder();
            },
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.saffron),
        ),
      );
    }

    final order = _order;
    if (order == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Order Tracking')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('Order not found'),
              const SizedBox(height: 12),
              ElevatedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Return to Shop'),
              ),
            ],
          ),
        ),
      );
    }

    final currentStep = _getTimelineStep(order.status);
    final isRejected = order.status == 'rejected' || order.status == 'refunded';

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
            Text('Order #${order.orderNumber}'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _fetchOrder(),
            tooltip: 'Refresh Status',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Status hero banner
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: isRejected ? const Color(0xFFFFF0F0) : AppTheme.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: isRejected ? AppTheme.error : AppTheme.saffron,
                  width: 1.5,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: isRejected ? AppTheme.error : AppTheme.cocoa,
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isRejected
                              ? Icons.error_outline
                              : order.status == 'delivered'
                                  ? Icons.check
                                  : Icons.outdoor_grill,
                          color: Colors.white,
                          size: 18,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              _getStatusTitle(order.status, order.prepTimeMinutes),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w800,
                                color: isRejected ? AppTheme.error : AppTheme.cocoa,
                              ),
                            ),
                            Text(
                              _getStatusSubtitle(order.status, order.rejectionReason),
                              style: const TextStyle(fontSize: 12, color: AppTheme.cocoa),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Live Vertical Timeline (if not rejected)
            if (!isRejected) ...[
              const Text(
                'Live Order Timeline',
                style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: [
                    _buildTimelineRow(
                      stepIndex: 1,
                      currentStep: currentStep,
                      title: 'Payment Confirmed',
                      subtitle: 'Transferred to DS Milk World',
                      isDone: currentStep >= 1,
                      isCurrent: currentStep == 1,
                    ),
                    _buildTimelineRow(
                      stepIndex: 2,
                      currentStep: currentStep,
                      title: 'Shop Accepted',
                      subtitle: order.prepTimeMinutes != null
                          ? 'Estimated prep time: ${order.prepTimeMinutes} mins'
                          : 'Awaiting kitchen queue confirmation',
                      isDone: currentStep >= 2,
                      isCurrent: currentStep == 2,
                    ),
                    _buildTimelineRow(
                      stepIndex: 3,
                      currentStep: currentStep,
                      title: 'Fresh Preparation',
                      subtitle: 'Crafting shakes & faloodas with fresh dairy',
                      isDone: currentStep >= 3,
                      isCurrent: currentStep == 3,
                    ),
                    _buildTimelineRow(
                      stepIndex: 4,
                      currentStep: currentStep,
                      title: 'Packed & Chilled',
                      subtitle: order.packingChecklistConfirmed
                          ? 'Tamper-sealed & chilling checklist verified'
                          : 'Awaiting final packaging verification',
                      isDone: currentStep >= 4,
                      isCurrent: currentStep == 4,
                    ),
                    _buildTimelineRow(
                      stepIndex: 5,
                      currentStep: currentStep,
                      title: 'Out for Delivery',
                      subtitle: currentStep >= 4
                          ? 'Rider dispatched to your address'
                          : 'Will be assigned upon packing',
                      isDone: currentStep >= 5,
                      isCurrent: currentStep == 4,
                    ),
                    _buildTimelineRow(
                      stepIndex: 6,
                      currentStep: currentStep,
                      title: 'Delivered',
                      subtitle: currentStep == 5
                          ? 'Delivered to your doorstep'
                          : 'Pending drop-off',
                      isDone: currentStep >= 5,
                      isCurrent: currentStep == 5,
                      isLast: true,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Customer Delight & Feedback Card on Delivery
            if (currentStep >= 5) ...[
              _buildFeedbackCard(),
              const SizedBox(height: 20),
            ],

            // Order Items & Delivery summary
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
                  const Text(
                    'Order Details',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                  ),
                  const Divider(color: AppTheme.border, height: 16),
                  ...order.items.map((i) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '${i.quantity}x ${i.nameSnapshot}',
                              style: const TextStyle(fontSize: 13, color: AppTheme.cocoa),
                            ),
                            Text(
                              AppTheme.formatPaise(i.subtotalPaise),
                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
                            ),
                          ],
                        ),
                      )),
                  const Divider(color: AppTheme.border, height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Delivery Fee:', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                      Text(AppTheme.formatPaise(order.deliveryFeePaise), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Paid:', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cocoa)),
                      Text(
                        AppTheme.formatPaise(order.totalPaise),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                      ),
                    ],
                  ),
                  const Divider(color: AppTheme.border, height: 20),
                  const Text(
                    'Delivery Destination:',
                    style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppTheme.muted),
                  ),
                  Text(
                    order.deliveryAddress,
                    style: const TextStyle(fontSize: 12, color: AppTheme.cocoa),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Event History Audit Trail
            if (_events.isNotEmpty) ...[
              const Text(
                'Audit Log & Status History',
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: AppTheme.border),
                ),
                child: Column(
                  children: _events.map((e) {
                    final time = '${e.timestamp.hour.toString().padLeft(2, '0')}:${e.timestamp.minute.toString().padLeft(2, '0')}';
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 4),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            time,
                            style: const TextStyle(fontSize: 11, color: AppTheme.muted, fontWeight: FontWeight.w600),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              '${e.payload ?? e.type} (${e.actorType})',
                              style: const TextStyle(fontSize: 11, color: AppTheme.cocoa),
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),
            ],

            // Support Actions
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTheme.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Need assistance with this order?',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Connecting to DS Milk World WhatsApp Support (+91 866 254 9999)'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.chat, size: 16, color: Color(0xFF2E7D32)),
                          label: const Text('WhatsApp', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Calling Outlet Counter: +91 866 254 9999'),
                              ),
                            );
                          },
                          icon: const Icon(Icons.call, size: 16, color: AppTheme.cocoa),
                          label: const Text('Call Shop', style: TextStyle(fontSize: 12)),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            if (currentStep <= 1 && !isRejected) ...[
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () => _showCancelOrderDialog(order.orderNumber),
                  icon: const Icon(Icons.cancel_outlined, size: 16, color: AppTheme.error),
                  label: const Text('Cancel Order (Full Refund)', style: TextStyle(color: AppTheme.error, fontSize: 13)),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(color: AppTheme.error),
                  ),
                ),
              ),
            ],
            const SizedBox(height: 20),

            SizedBox(
              width: double.infinity,
              child: TextButton(
                onPressed: () => Navigator.popUntil(context, (r) => r.isFirst),
                child: const Text(
                  '← Return to Menu Storefront',
                  style: TextStyle(color: AppTheme.cocoa, fontWeight: FontWeight.w700),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineRow({
    required int stepIndex,
    required int currentStep,
    required String title,
    required String subtitle,
    required bool isDone,
    required bool isCurrent,
    bool isLast = false,
  }) {
    Color dotColor = Colors.grey[300]!;
    if (isDone) dotColor = const Color(0xFF2E7D32);
    if (isCurrent) dotColor = AppTheme.saffronDark;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          children: [
            Container(
              width: 20,
              height: 20,
              decoration: BoxDecoration(
                color: dotColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: isDone
                    ? const Icon(Icons.check, size: 12, color: Colors.white)
                    : Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle)),
              ),
            ),
            if (!isLast)
              Container(
                width: 2,
                height: 36,
                color: isDone ? const Color(0xFF2E7D32) : Colors.grey[300],
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: isCurrent || isDone ? FontWeight.w800 : FontWeight.w500,
                    color: AppTheme.cocoa,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  String _getStatusTitle(String status, int? prepMinutes) {
    switch (status.toLowerCase()) {
      case 'awaiting_payment':
        return 'Payment Pending';
      case 'paid':
      case 'shop_acceptance_pending':
        return 'Order Received by Shop';
      case 'preparing':
        return 'Preparing in Kitchen';
      case 'ready_for_pickup':
        return 'Ready for Pickup';
      case 'out_for_delivery':
        return 'Out for Delivery';
      case 'delivered':
        return 'Delivered';
      case 'rejected':
        return 'Order Cancelled';
      default:
        return status;
    }
  }

  String _getStatusSubtitle(String status, String? reason) {
    switch (status.toLowerCase()) {
      case 'awaiting_payment':
        return 'Complete payment to send order to kitchen.';
      case 'paid':
      case 'shop_acceptance_pending':
        return 'Kitchen staff is reviewing your order items.';
      case 'preparing':
        return 'Crafting fresh with high quality dairy ingredients.';
      case 'ready_for_pickup':
        return 'Packed securely and waiting for rider.';
      case 'out_for_delivery':
        return 'Rider is en-route with your order.';
      case 'delivered':
        return 'Thank you for ordering directly from DS Milk World!';
      case 'rejected':
        return 'Shop Reason: ${reason ?? "Kitchen at capacity"}. Auto-refund processed.';
      default:
        return '';
    }
  }

  Widget _buildFeedbackCard() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.saffron.withValues(alpha: 0.5)),
        boxShadow: const [
          BoxShadow(color: Colors.black12, blurRadius: 6, offset: Offset(0, 2)),
        ],
      ),
      child: _feedbackSubmitted
          ? Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: const BoxDecoration(
                    color: Color(0xFFE8F5E9),
                    shape: BoxShape.circle,
                  ),
                  child: const Center(
                    child: Icon(Icons.star, color: Color(0xFF2E7D32), size: 24),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Thank you for your rating!',
                        style: TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.cocoa),
                      ),
                      SizedBox(height: 2),
                      Text(
                        'Your feedback helps our Kanuru dairy team maintain fresh counter quality.',
                        style: TextStyle(fontSize: 12, color: AppTheme.muted),
                      ),
                    ],
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  children: [
                    Text('🌟', style: TextStyle(fontSize: 18)),
                    SizedBox(width: 8),
                    Text(
                      'Rate Your Fresh Dairy Experience',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                const Text(
                  'How was your beverage delivery from our Kanuru counter?',
                  style: TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(5, (index) {
                    final starIndex = index + 1;
                    return IconButton(
                      icon: Icon(
                        starIndex <= _rating ? Icons.star_rounded : Icons.star_outline_rounded,
                        color: starIndex <= _rating ? Colors.amber[700] : Colors.grey[400],
                        size: 32,
                      ),
                      onPressed: () => setState(() => _rating = starIndex),
                    );
                  }),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: [
                    '100% Pure Milk',
                    'Super Chilled',
                    'Quick Delivery',
                    'Great Taste',
                    'Neat Packaging',
                  ].map((tag) {
                    final isSel = _feedbackTags.contains(tag);
                    return FilterChip(
                      selected: isSel,
                      label: Text(tag, style: const TextStyle(fontSize: 11, color: AppTheme.cocoa)),
                      selectedColor: AppTheme.cream,
                      backgroundColor: Colors.grey[100],
                      checkmarkColor: AppTheme.saffronDark,
                      onSelected: (selected) {
                        setState(() {
                          if (selected) {
                            _feedbackTags.add(tag);
                          } else {
                            _feedbackTags.remove(tag);
                          }
                        });
                      },
                    );
                  }).toList(),
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() => _feedbackSubmitted = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Thank you! Your feedback has been recorded.')),
                      );
                    },
                    child: const Text('Submit Rating'),
                  ),
                ),
              ],
            ),
    );
  }
}