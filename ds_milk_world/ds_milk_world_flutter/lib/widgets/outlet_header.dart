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
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.cream,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppTheme.saffron, width: 1.5),
                    ),
                    child: const Center(
                      child: Text(
                        '🥛',
                        style: TextStyle(fontSize: 22),
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
          Container(
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
                    'Order at outlet prices • Direct preparation • 5 km delivery radius in Vijayawada',
                    style: TextStyle(
                      color: AppTheme.cocoa,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
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
}