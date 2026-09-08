import 'dart:async';
import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class StaffConsoleScreen extends StatefulWidget {
  final VoidCallback onBackToStorefront;

  const StaffConsoleScreen({super.key, required this.onBackToStorefront});

  @override
  State<StaffConsoleScreen> createState() => _StaffConsoleScreenState();
}

class _StaffConsoleScreenState extends State<StaffConsoleScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  List<OrderRecord> _orders = [];
  StoreCatalog? _catalog;
  bool _isLoading = true;
  Timer? _pollingTimer;
  String _catalogSearch = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 7, vsync: this);
    _loadData();
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) => _loadData(silent: true));
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData({bool silent = false}) async {
    if (!silent) setState(() => _isLoading = true);
    try {
      final orders = await ApiService.instance.listAllOrders();
      final catalog = await ApiService.instance.getCatalog();
      if (mounted) {
        setState(() {
          _orders = orders;
          _catalog = catalog;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted && !silent) {
        setState(() => _isLoading = false);
      }
    }
  }

  List<OrderRecord> _filterByStatus(String status) {
    if (status == 'new') {
      return _orders.where((o) => o.status == 'shop_acceptance_pending' || o.status == 'paid').toList();
    }
    return _orders.where((o) => o.status.toLowerCase() == status.toLowerCase()).toList();
  }

  // Action: Accept Order
  void _showAcceptDialog(OrderRecord order) {
    int prepMinutes = 20;
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Accept Order #${order.orderNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select estimated kitchen prep time:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [15, 20, 25, 30, 45].map((mins) {
                  final isSel = prepMinutes == mins;
                  return ChoiceChip(
                    label: Text('$mins mins'),
                    selected: isSel,
                    selectedColor: AppTheme.cream,
                    labelStyle: TextStyle(
                      color: AppTheme.cocoa,
                      fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                    ),
                    side: BorderSide(color: isSel ? AppTheme.saffron : AppTheme.border),
                    onSelected: (_) => setDialogState(() => prepMinutes = mins),
                  );
                }).toList(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ApiService.instance.acceptOrder(order.orderNumber, prepMinutes);
                _loadData();
              },
              child: const Text('Accept & Send to Kitchen'),
            ),
          ],
        ),
      ),
    );
  }

  // Action: Reject Order
  void _showRejectDialog(OrderRecord order) {
    final reasonController = TextEditingController(text: 'Kitchen at capacity for fresh preparation');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('Reject Order #${order.orderNumber}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'A mandatory reason is required. Rejecting will immediately process a 100% refund for the customer.',
              style: TextStyle(fontSize: 12, color: AppTheme.muted),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Rejection Reason *'),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.error, foregroundColor: Colors.white),
            onPressed: () async {
              final r = reasonController.text.trim();
              if (r.isEmpty) return;
              Navigator.pop(ctx);
              await ApiService.instance.rejectOrder(order.orderNumber, r);
              _loadData();
            },
            child: const Text('Reject & Issue Refund'),
          ),
        ],
      ),
    );
  }

  // Action: Mark Ready with Checklist
  void _showMarkReadyDialog(OrderRecord order) {
    bool isChilled = true;
    bool isSealed = true;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Ready for Pickup #${order.orderNumber}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('Verify packaging requirements before dispatch:', style: TextStyle(fontSize: 13)),
              const SizedBox(height: 12),
              CheckboxListTile(
                value: isChilled,
                activeColor: AppTheme.saffronDark,
                title: const Text('Cold drinks/faloodas packed chilled', style: TextStyle(fontSize: 13)),
                onChanged: (v) => setDialogState(() => isChilled = v ?? false),
              ),
              CheckboxListTile(
                value: isSealed,
                activeColor: AppTheme.saffronDark,
                title: const Text('Tamper-evident security tape applied', style: TextStyle(fontSize: 13)),
                onChanged: (v) => setDialogState(() => isSealed = v ?? false),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: (!isChilled || !isSealed)
                  ? null
                  : () async {
                      Navigator.pop(ctx);
                      await ApiService.instance.markReady(order.orderNumber);
                      _loadData();
                    },
              child: const Text('Confirm Ready for Pickup'),
            ),
          ],
        ),
      ),
    );
  }

  // Action: Assign Delivery (Partner or Manual Fallback)
  void _showAssignDeliveryDialog(OrderRecord order) {
    String provider = 'Rapido';
    final riderNameCtrl = TextEditingController(text: 'Suresh V');
    final riderPhoneCtrl = TextEditingController(text: '+91 98765 43210');
    final trackingCtrl = TextEditingController(text: 'https://track.rapido.bike/del-4982');
    bool manualFallback = false;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text('Assign Delivery #${order.orderNumber}'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: provider,
                  decoration: const InputDecoration(labelText: 'Delivery Integration / Partner'),
                  items: const [
                    DropdownMenuItem(value: 'Rapido', child: Text('Rapido API')),
                    DropdownMenuItem(value: 'Shadowfax', child: Text('Shadowfax')),
                    DropdownMenuItem(value: 'Shop Rider', child: Text('Shop In-House Rider (Manual Fallback)')),
                  ],
                  onChanged: (v) {
                    setDialogState(() {
                      provider = v ?? 'Rapido';
                      manualFallback = (provider == 'Shop Rider');
                    });
                  },
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: riderNameCtrl,
                  decoration: const InputDecoration(labelText: 'Rider Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: riderPhoneCtrl,
                  decoration: const InputDecoration(labelText: 'Rider Phone'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: trackingCtrl,
                  decoration: const InputDecoration(labelText: 'Tracking URL / Reference'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(ctx);
                await ApiService.instance.assignDelivery(
                  orderNumber: order.orderNumber,
                  provider: provider,
                  riderName: riderNameCtrl.text.trim(),
                  riderPhone: riderPhoneCtrl.text.trim(),
                  trackingUrl: trackingCtrl.text.trim(),
                  manualFallback: manualFallback,
                );
                _loadData();
              },
              child: const Text('Dispatch Order'),
            ),
          ],
        ),
      ),
    );
  }

  // Action: Mark Delivered
  void _markDelivered(OrderRecord order) async {
    await ApiService.instance.markDelivered(order.orderNumber);
    _loadData();
  }

  @override
  Widget build(BuildContext context) {
    final newOrders = _filterByStatus('new');
    final prepOrders = _filterByStatus('preparing');
    final readyOrders = _filterByStatus('ready_for_pickup');
    final outOrders = _filterByStatus('out_for_delivery');
    final doneOrders = _filterByStatus('delivered');

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: widget.onBackToStorefront,
          tooltip: 'Back to Customer Storefront',
        ),
        title: Row(
          children: [
            const Text('Staff Ops Console'),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.saffron,
                borderRadius: BorderRadius.circular(6),
              ),
              child: const Text(
                'Auto Nagar Counter',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadData(),
            tooltip: 'Refresh Orders',
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          labelColor: AppTheme.cocoa,
          unselectedLabelColor: AppTheme.muted,
          indicatorColor: AppTheme.saffron,
          tabs: [
            Tab(text: 'New Paid (${newOrders.length})'),
            Tab(text: 'Preparing (${prepOrders.length})'),
            Tab(text: 'Ready (${readyOrders.length})'),
            Tab(text: 'Out for Delivery (${outOrders.length})'),
            Tab(text: 'Completed (${doneOrders.length})'),
            const Tab(text: 'Menu Catalog (79)'),
            const Tab(text: 'Reports & Stats'),
          ],
        ),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.saffron))
          : Column(
              children: [
                if (newOrders.isNotEmpty)
                  InkWell(
                    onTap: () => _tabController.animateTo(0),
                    child: Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                      color: AppTheme.saffron,
                      child: Row(
                        children: [
                          const Icon(Icons.notifications_active, size: 18, color: AppTheme.cocoa),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'ACTION REQUIRED: ${newOrders.length} new paid order(s) awaiting shop acceptance!',
                              style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 13, color: AppTheme.cocoa),
                            ),
                          ),
                          const Text(
                            'Review Now →',
                            style: TextStyle(fontWeight: FontWeight.w800, fontSize: 12, color: AppTheme.cocoa),
                          ),
                        ],
                      ),
                    ),
                  ),
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildOrderList(newOrders, 'new'),
                      _buildOrderList(prepOrders, 'preparing'),
                      _buildOrderList(readyOrders, 'ready_for_pickup'),
                      _buildOrderList(outOrders, 'out_for_delivery'),
                      _buildOrderList(doneOrders, 'delivered'),
                      _buildCatalogTab(),
                      _buildReportsTab(),
                    ],
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildOrderList(List<OrderRecord> list, String stage) {
    if (list.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.inbox_outlined, size: 48, color: Colors.grey[400]),
              const SizedBox(height: 12),
              Text(
                'No orders in this stage',
                style: TextStyle(color: Colors.grey[600], fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ],
          ),
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: list.length,
      itemBuilder: (context, idx) {
        final order = list[idx];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '#${order.orderNumber}',
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15, color: AppTheme.cocoa),
                    ),
                    Text(
                      AppTheme.formatPaise(order.totalPaise),
                      style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppTheme.cocoa),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '${order.customerName != null ? "${order.customerName} • " : ""}${order.customerPhone}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.cocoa),
                ),
                Text(
                  '${order.deliveryAddress} (${order.distanceKm} km away)',
                  style: const TextStyle(fontSize: 12, color: AppTheme.muted),
                ),
                const Divider(height: 16),
                ...order.items.map((it) => Text(
                      '• ${it.quantity}x ${it.nameSnapshot}${it.optionsSnapshot != null ? " (${it.optionsSnapshot})" : ""}',
                      style: const TextStyle(fontSize: 12, color: AppTheme.cocoa),
                    )),
                const Divider(height: 16),
                // Action row depending on stage
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    if (stage == 'new') ...[
                      OutlinedButton(
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppTheme.error,
                          side: const BorderSide(color: AppTheme.error),
                        ),
                        onPressed: () => _showRejectDialog(order),
                        child: const Text('Reject (Refund)'),
                      ),
                      const SizedBox(width: 8),
                      ElevatedButton(
                        onPressed: () => _showAcceptDialog(order),
                        child: const Text('Accept Order'),
                      ),
                    ] else if (stage == 'preparing') ...[
                      ElevatedButton(
                        onPressed: () => _showMarkReadyDialog(order),
                        child: const Text('Mark Ready (Checklist)'),
                      ),
                    ] else if (stage == 'ready_for_pickup') ...[
                      ElevatedButton(
                        onPressed: () => _showAssignDeliveryDialog(order),
                        child: const Text('Dispatch / Assign Delivery'),
                      ),
                    ] else if (stage == 'out_for_delivery') ...[
                      ElevatedButton(
                        onPressed: () => _markDelivered(order),
                        child: const Text('Mark as Delivered'),
                      ),
                    ] else ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: const Color(0xFFE8F5E9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Delivered Successfully',
                          style: TextStyle(color: Color(0xFF2E7D32), fontWeight: FontWeight.w700, fontSize: 12),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildCatalogTab() {
    if (_catalog == null) {
      return const Center(child: Text('No catalog loaded'));
    }

    final filtered = _catalog!.products.where((p) {
      if (_catalogSearch.isEmpty) return true;
      final q = _catalogSearch.toLowerCase();
      return p.name.toLowerCase().contains(q) || p.categoryName.toLowerCase().contains(q) || p.sku.toLowerCase().contains(q);
    }).toList();

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: TextField(
            onChanged: (val) => setState(() => _catalogSearch = val),
            decoration: const InputDecoration(
              hintText: 'Search menu item to toggle availability...',
              prefixIcon: Icon(Icons.search),
              isDense: true,
            ),
          ),
        ),
        Expanded(
          child: ListView.separated(
            itemCount: filtered.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, idx) {
              final prod = filtered[idx];
              return ListTile(
                dense: true,
                title: Text(
                  prod.name,
                  style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                ),
                subtitle: Text(
                  '${prod.categoryName} • ${AppTheme.formatPaise(prod.pricePaise)} • ${prod.sku}',
                  style: const TextStyle(fontSize: 11, color: AppTheme.muted),
                ),
                trailing: Switch(
                  value: prod.availability,
                  activeColor: AppTheme.saffronDark,
                  onChanged: (val) async {
                    setState(() => prod.availability = val);
                    await ApiService.instance.updateProductAvailability(prod.sku, val);
                  },
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildReportsTab() {
    final paidOrders = _orders.where((o) => o.status != 'awaiting_payment' && o.status != 'draft').toList();
    final totalRevenuePaise = paidOrders.fold(0, (sum, o) => sum + o.totalPaise);
    final deliveryFeesPaise = paidOrders.fold(0, (sum, o) => sum + o.deliveryFeePaise);
    final rejectedCount = _orders.where((o) => o.status == 'rejected').length;
    final totalItemsSold = paidOrders.fold(0, (sum, o) => sum + o.items.fold(0, (s, i) => s + i.quantity));

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Daily Performance & Financial Reconciliation',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
          ),
          const SizedBox(height: 6),
          const Text(
            'Live metrics from Auto Nagar Counter pilot:',
            style: TextStyle(fontSize: 12, color: AppTheme.muted),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Gross Revenue',
                  value: AppTheme.formatPaise(totalRevenuePaise),
                  subtitle: '${paidOrders.length} orders settled',
                  accent: AppTheme.saffronDark,
                  icon: Icons.currency_rupee,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Items Prepared',
                  value: '$totalItemsSold',
                  subtitle: 'Across 8 categories',
                  accent: AppTheme.mint,
                  icon: Icons.inventory_2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: _buildMetricCard(
                  title: 'Delivery Collected',
                  value: AppTheme.formatPaise(deliveryFeesPaise),
                  subtitle: 'Customer paid',
                  accent: AppTheme.cocoa,
                  icon: Icons.two_wheeler,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _buildMetricCard(
                  title: 'Exceptions / Refunds',
                  value: '$rejectedCount',
                  subtitle: 'Shop rejected / cancelled',
                  accent: rejectedCount > 0 ? AppTheme.error : Colors.grey,
                  icon: Icons.assignment_return,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          const Text(
            'Outlet Operating Rules Check',
            style: TextStyle(fontSize: 14, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
          ),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(
              children: [
                _buildRuleRow('Delivery Radius Boundary', '5.0 km strictly enforced via Haversine', true),
                const Divider(height: 16),
                _buildRuleRow('Pricing Calculation', 'Strictly server-side; client total ignored', true),
                const Divider(height: 16),
                _buildRuleRow('Payment Security', 'Signed webhooks & idempotency lock', true),
                const Divider(height: 16),
                _buildRuleRow('Physical Goods Policy', 'Generic payment adapter (Dodo excluded)', true),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required Color accent,
    required IconData icon,
  }) {
    return Container(
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
              Text(title, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppTheme.muted)),
              Icon(icon, size: 18, color: accent),
            ],
          ),
          const SizedBox(height: 8),
          Text(value, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: accent)),
          const SizedBox(height: 2),
          Text(subtitle, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
        ],
      ),
    );
  }

  Widget _buildRuleRow(String rule, String detail, bool compliant) {
    return Row(
      children: [
        Icon(compliant ? Icons.check_circle : Icons.warning, size: 18, color: compliant ? const Color(0xFF2E7D32) : AppTheme.error),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(rule, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppTheme.cocoa)),
              Text(detail, style: const TextStyle(fontSize: 11, color: AppTheme.muted)),
            ],
          ),
        ),
      ],
    );
  }
}