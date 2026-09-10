import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import '../screens/address_quote_screen.dart';

class FloatingCartBar extends StatelessWidget {
  const FloatingCartBar({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartState.instance,
      builder: (context, _) {
        final totalItems = CartState.instance.totalItems;
        if (totalItems == 0) return const SizedBox.shrink();

        final subtotal = CartState.instance.subtotalPaise;

        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppTheme.cocoa,
                borderRadius: BorderRadius.circular(14),
                boxShadow: const [
                  BoxShadow(
                    color: Color(0x333A241B),
                    blurRadius: 16,
                    offset: Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.saffron,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      '$totalItems ${totalItems == 1 ? "item" : "items"}',
                      style: const TextStyle(
                        color: AppTheme.cocoa,
                        fontWeight: FontWeight.w800,
                        fontSize: 12,
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          AppTheme.formatPaise(subtotal),
                          style: const TextStyle(
                            color: AppTheme.milk,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                          ),
                        ),
                        const Text(
                          'Plus delivery fee at next step',
                          style: TextStyle(
                            color: AppTheme.cream,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        isScrollControlled: true,
                        backgroundColor: Colors.transparent,
                        builder: (_) => const CartReviewSheet(),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.saffron,
                      foregroundColor: AppTheme.cocoa,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'View Cart',
                          style: TextStyle(fontWeight: FontWeight.w800, fontSize: 13),
                        ),
                        SizedBox(width: 4),
                        Icon(Icons.arrow_forward, size: 14),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class CartReviewSheet extends StatefulWidget {
  const CartReviewSheet({super.key});

  @override
  State<CartReviewSheet> createState() => _CartReviewSheetState();
}

class _CartReviewSheetState extends State<CartReviewSheet> {
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _noteController = TextEditingController(text: CartState.instance.instructions);
  }

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartState.instance,
      builder: (context, _) {
        final items = CartState.instance.items;
        final subtotal = CartState.instance.subtotalPaise;

        return Container(
          decoration: const BoxDecoration(
            color: AppTheme.milk,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: EdgeInsets.only(
            top: 20,
            left: 20,
            right: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 24,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Order Basket',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cocoa,
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close, color: AppTheme.cocoa),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
                const Divider(color: AppTheme.border),
                if (items.isEmpty)
                  const Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(
                      child: Text('Your basket is empty. Add some fresh dairy treats!'),
                    ),
                  )
                else ...[
                  ConstrainedBox(
                    constraints: const BoxConstraints(maxHeight: 240),
                    child: ListView.separated(
                      shrinkWrap: true,
                      itemCount: items.length,
                      separatorBuilder: (_, __) => const Divider(color: AppTheme.border, height: 16),
                      itemBuilder: (context, idx) {
                        final item = items[idx];
                        return Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.nameSnapshot,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      fontSize: 14,
                                      color: AppTheme.cocoa,
                                    ),
                                  ),
                                  if (item.optionsSnapshot != null)
                                    Text(
                                      item.optionsSnapshot!,
                                      style: const TextStyle(
                                        fontSize: 11,
                                        color: AppTheme.muted,
                                      ),
                                    ),
                                  const SizedBox(height: 4),
                                  Text(
                                    AppTheme.formatPaise(item.unitPricePaise),
                                    style: const TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppTheme.cocoa,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Container(
                              height: 32,
                              decoration: BoxDecoration(
                                color: AppTheme.cream,
                                borderRadius: BorderRadius.circular(6),
                                border: Border.all(color: AppTheme.border),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.remove, size: 12),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28),
                                    onPressed: () => CartState.instance.removeProduct(item.productSku),
                                  ),
                                  Text(
                                    '${item.quantity}',
                                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 12),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.add, size: 12),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(minWidth: 28),
                                    onPressed: () {
                                      CartState.instance.incrementProduct(item.productSku);
                                    },
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 12),
                            SizedBox(
                              width: 60,
                              child: Text(
                                AppTheme.formatPaise(item.subtotalPaise),
                                textAlign: TextAlign.right,
                                style: const TextStyle(
                                  fontWeight: FontWeight.w800,
                                  fontSize: 14,
                                  color: AppTheme.cocoa,
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                  const Divider(color: AppTheme.border, height: 20),

                  // Special instructions card
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppTheme.border),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.edit_note, size: 16, color: AppTheme.cocoa),
                            SizedBox(width: 6),
                            Text(
                              'Notes for counter / kitchen',
                              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        TextField(
                          controller: _noteController,
                          onChanged: (val) => CartState.instance.setInstructions(val),
                          decoration: const InputDecoration(
                            hintText: 'e.g., less sweet, extra chilled, ring bell...',
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                          ),
                        ),
                        const SizedBox(height: 6),
                        Wrap(
                          spacing: 6,
                          runSpacing: 4,
                          children: [
                            'Less Sweet',
                            'Extra Chilled',
                            'Leave at Gate',
                            'Call on Arrival',
                          ].map((chip) {
                            return InkWell(
                              onTap: () {
                                final current = _noteController.text.trim();
                                if (current.isEmpty) {
                                  _noteController.text = chip;
                                } else if (!current.contains(chip)) {
                                  _noteController.text = '$current, $chip';
                                }
                                CartState.instance.setInstructions(_noteController.text);
                                setState(() {});
                              },
                              borderRadius: BorderRadius.circular(12),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: AppTheme.cream,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: AppTheme.saffron.withValues(alpha: 0.5)),
                                ),
                                child: Text(
                                  '+ $chip',
                                  style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppTheme.cocoa),
                                ),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text(
                        'Subtotal',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600, color: AppTheme.cocoa),
                      ),
                      Text(
                        AppTheme.formatPaise(subtotal),
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.cocoa),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // close cart sheet
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const AddressQuoteScreen()),
                        );
                      },
                      child: const Text(
                        'Enter Delivery Address & Check Radius →',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}