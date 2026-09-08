import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/mock_data.dart';
import '../state/cart_state.dart';
import 'order_tracking_screen.dart';

class OrderHistoryScreen extends StatefulWidget {
  const OrderHistoryScreen({super.key});

  @override
  State<OrderHistoryScreen> createState() => _OrderHistoryScreenState();
}

class _OrderHistoryScreenState extends State<OrderHistoryScreen> {
  List<OrderRecord> _orders = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadHistory();
  }

  Future<void> _loadHistory() async {
    setState(() => _isLoading = true);
    try {
      final orders = await ApiService.instance.listAllOrders();
      if (mounted) {
        setState(() {
          _orders = orders;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _reorder(OrderRecord order) {
    int addedCount = 0;
    for (final item in order.items) {
      final product = MockData.getProductBySku(item.productSku);
      if (product != null && product.availability) {
        for (int i = 0; i < item.quantity; i++) {
          CartState.instance.addProduct(product, options: item.optionsSnapshot);
        }
        addedCount += item.quantity;
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Added $addedCount items from #${order.orderNumber} to cart!'),
        backgroundColor: AppTheme.cocoa,
        action: SnackBarAction(
          label: 'View Cart',
          textColor: AppTheme.saffron,
          onPressed: () => Navigator.pop(context),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Past Orders'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadHistory,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.saffron))
          : _orders.isEmpty
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(32),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.receipt_long_outlined, size: 64, color: AppTheme.muted),
                        const SizedBox(height: 16),
                        const Text(
                          'No orders placed yet',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Fresh faloodas, thick shakes, and buttermilk are waiting for you.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 13, color: AppTheme.muted),
                        ),
                        const SizedBox(height: 20),
                        ElevatedButton(
                          onPressed: () => Navigator.pop(context),
                          child: const Text('Start Ordering'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.separated(
                  padding: const EdgeInsets.all(16),
                  itemCount: _orders.length,
                  separatorBuilder: (_, __) => const SizedBox(height: 12),
                  itemBuilder: (context, idx) {
                    final order = _orders[idx];
                    final isDelivered = order.status == 'delivered';
                    final isRejected = order.status == 'rejected';

                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '#${order.orderNumber}',
                                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14, color: AppTheme.cocoa),
                                    ),
                                    Text(
                                      '${order.createdAt.day}/${order.createdAt.month}/${order.createdAt.year} at ${order.createdAt.hour.toString().padLeft(2, '0')}:${order.createdAt.minute.toString().padLeft(2, '0')}',
                                      style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                                    ),
                                  ],
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: isDelivered
                                        ? const Color(0xFFE8F5E9)
                                        : isRejected
                                            ? const Color(0xFFFFEBEE)
                                            : AppTheme.cream,
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    order.status.replaceAll('_', ' ').toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 10,
                                      fontWeight: FontWeight.w800,
                                      color: isDelivered
                                          ? const Color(0xFF2E7D32)
                                          : isRejected
                                              ? AppTheme.error
                                              : AppTheme.cocoa,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const Divider(color: AppTheme.border, height: 20),
                            ...order.items.map((it) => Padding(
                                  padding: const EdgeInsets.only(bottom: 4),
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
                                const Text('Total Paid:', style: TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
                                Text(
                                  AppTheme.formatPaise(order.totalPaise),
                                  style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.cocoa),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    onPressed: () => _reorder(order),
                                    child: const Text('Reorder Items', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => OrderTrackingScreen(orderNumber: order.orderNumber),
                                        ),
                                      );
                                    },
                                    child: const Text('Track Order', style: TextStyle(fontSize: 12)),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}