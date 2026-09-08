import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OutletHeader extends StatelessWidget {
  final ValueChanged<String>? onSearchChanged;
  final VoidCallback? onToggleStaffMode;
  final VoidCallback? onOpenHistory;
  final bool isStaffMode;

  const OutletHeader({
    super.key,
    this.onSearchChanged,
    this.onToggleStaffMode,
    this.onOpenHistory,
    this.isStaffMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      decoration: const BoxDecoration(
        color: AppTheme.milk,
        border: Border(
          bottom: BorderSide(color: AppTheme.border, width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    width: 46,
                    height: 46,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.saffron, width: 1.5),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.cocoa.withValues(alpha: 0.1),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.5),
                      child: Image.asset(
                        'assets/images/ds_logo_square.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'DS Milk World',
                        style: TextStyle(
                          color: AppTheme.cocoa,
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                      Row(
                        children: [
                          Container(
                            width: 8,
                            height: 8,
                            decoration: const BoxDecoration(
                              color: AppTheme.mint,
                              shape: BoxShape.circle,
                            ),
                          ),
                          const SizedBox(width: 6),
                          const Text(
                            'Open Now • Auto Nagar Counter',
                            style: TextStyle(
                              color: AppTheme.cocoa,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!isStaffMode && onOpenHistory != null)
                    IconButton(
                      icon: const Icon(Icons.receipt_long_outlined, size: 20, color: AppTheme.cocoa),
                      tooltip: 'My Past Orders',
                      onPressed: onOpenHistory,
                    ),
                  OutlinedButton.icon(
                    onPressed: onToggleStaffMode,
                    icon: Icon(
                      isStaffMode ? Icons.storefront : Icons.admin_panel_settings,
                      size: 16,
                      color: AppTheme.cocoa,
                    ),
                    label: Text(
                      isStaffMode ? 'Storefront' : 'Staff Ops',
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                    ),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                      side: const BorderSide(color: AppTheme.border),
                      backgroundColor: isStaffMode ? AppTheme.cream : Colors.white,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Visual Brand Banner
          Container(
            height: 76,
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTheme.border),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(
                    'assets/images/ds_logo_banner.png',
                    fit: BoxFit.cover,
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.centerLeft,
                        end: Alignment.centerRight,
                        colors: [
                          AppTheme.cocoa.withValues(alpha: 0.82),
                          AppTheme.cocoa.withValues(alpha: 0.25),
                        ],
                      ),
                    ),
                  ),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Pure Dairy & Fresh Shakes',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.3,
                          ),
                        ),
                        SizedBox(height: 2),
                        Text(
                          'Handcrafted Faloodas • 100% Pure Milk • Auto Nagar',
                          style: TextStyle(
                            color: Color(0xFFFFF1D6),
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => _showGuaranteeDialog(context),
            borderRadius: BorderRadius.circular(8),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppTheme.cream,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppTheme.border),
              ),
              child: const Row(
                children: [
                  Icon(Icons.verified, size: 16, color: AppTheme.saffronDark),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Order at outlet prices • Direct prep • 5 km Vijayawada radius',
                      style: TextStyle(
                        color: AppTheme.cocoa,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  Icon(Icons.info_outline, size: 16, color: AppTheme.cocoa),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            onChanged: onSearchChanged,
            decoration: InputDecoration(
              hintText: 'Search 79 fresh faloodas, shakes, buttermilk, specials...',
              prefixIcon: const Icon(Icons.search, color: AppTheme.muted, size: 20),
              isDense: true,
              contentPadding: const EdgeInsets.symmetric(vertical: 10, horizontal: 12),
              fillColor: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  void _showGuaranteeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.verified, color: AppTheme.saffronDark),
            SizedBox(width: 8),
            Expanded(
              child: Text(
                'DS Milk World Direct Guarantee',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
              ),
            ),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _GuaranteeTile(
                icon: Icons.storefront,
                title: 'Authentic Counter Prices',
                description: 'Direct menu pricing with zero third-party aggregator commissions or inflated catalog rates.',
              ),
              SizedBox(height: 12),
              _GuaranteeTile(
                icon: Icons.location_on,
                title: '5.0 km Strict Freshness Perimeter',
                description: 'Deliveries limited strictly to 5.0 km around our Auto Nagar counter (Vijayawada) so cold dairy treats and thickshakes arrive in peak condition.',
              ),
              SizedBox(height: 12),
              _GuaranteeTile(
                icon: Icons.delivery_dining,
                title: 'Transparent Delivery Fee',
                description: 'Flat ₹30 for the first 2.0 km, + ₹10/km beyond that. Real-time Haversine distance calculation.',
              ),
              SizedBox(height: 12),
              _GuaranteeTile(
                icon: Icons.restart_alt,
                title: 'Instant 100% Refund Guarantee',
                description: 'If your order is rejected or cancelled before kitchen prep, a 100% refund is initiated immediately to your payment source.',
              ),
              SizedBox(height: 12),
              _GuaranteeTile(
                icon: Icons.phone_in_talk,
                title: 'Counter Contact & Hygiene',
                description: 'FSSAI compliant facility. Need quick assistance? Direct counter line: +91 866 254 9999.',
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Got It'),
          ),
        ],
      ),
    );
  }
}

class _GuaranteeTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;

  const _GuaranteeTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(6),
          decoration: BoxDecoration(
            color: AppTheme.cream,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, size: 18, color: AppTheme.saffronDark),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13, color: AppTheme.cocoa),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: const TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.3),
              ),
            ],
          ),
        ),
      ],
    );
  }
}