import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';

class CustomizationSheet extends StatefulWidget {
  final Product product;

  const CustomizationSheet({super.key, required this.product});

  static Future<void> show(BuildContext context, Product product) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CustomizationSheet(product: product),
    );
  }

  @override
  State<CustomizationSheet> createState() => _CustomizationSheetState();
}

class _CustomizationSheetState extends State<CustomizationSheet> {
  String _sweetness = 'Regular';
  String _topping = 'None';
  int _extraPaise = 0;
  final TextEditingController _noteController = TextEditingController();

  final List<String> _sweetnessOptions = ['Regular Sweet', 'Less Sweet', 'No Added Sugar'];
  final Map<String, int> _toppingOptions = {
    'None': 0,
    'Extra Dry Fruits & Nuts (+₹20)': 2000,
    'Tutti Frutti Mix (+₹10)': 1000,
    'Extra Vanilla Scoop (+₹30)': 3000,
  };

  @override
  void dispose() {
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final basePrice = widget.product.offerPricePaise ?? widget.product.pricePaise;
    final totalPrice = basePrice + _extraPaise;

    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.milk,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        top: 20,
        left: 20,
        right: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.product.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        color: AppTheme.cocoa,
                      ),
                    ),
                    Text(
                      widget.product.categoryName,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.rose,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.close, color: AppTheme.cocoa),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const Divider(color: AppTheme.border, height: 24),
          const Text(
            'Sweetness Level',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.cocoa,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: _sweetnessOptions.map((s) {
              final isSel = _sweetness == s;
              return ChoiceChip(
                label: Text(s),
                selected: isSel,
                selectedColor: AppTheme.cream,
                backgroundColor: Colors.white,
                labelStyle: TextStyle(
                  color: AppTheme.cocoa,
                  fontWeight: isSel ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSel ? AppTheme.saffron : AppTheme.border,
                ),
                onSelected: (_) => setState(() => _sweetness = s),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),
          const Text(
            'Add-ons & Toppings',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w700,
              color: AppTheme.cocoa,
            ),
          ),
          const SizedBox(height: 8),
          Column(
            children: _toppingOptions.entries.map((entry) {
              return RadioListTile<String>(
                contentPadding: EdgeInsets.zero,
                dense: true,
                title: Text(
                  entry.key,
                  style: const TextStyle(
                    fontSize: 13,
                    color: AppTheme.cocoa,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                value: entry.key,
                groupValue: _topping,
                activeColor: AppTheme.saffronDark,
                onChanged: (val) {
                  if (val != null) {
                    setState(() {
                      _topping = val;
                      _extraPaise = entry.value;
                    });
                  }
                },
              );
            }).toList(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _noteController,
            decoration: const InputDecoration(
              labelText: 'Special instructions for kitchen',
              hintText: 'e.g., extra chilled, no nuts...',
              isDense: true,
            ),
          ),
          const SizedBox(height: 20),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () {
                final note = _noteController.text.trim();
                final optionsSummary = 'Sweetness: $_sweetness | Topping: $_topping${note.isNotEmpty ? " | Note: $note" : ""}';
                CartState.instance.addProduct(widget.product, options: optionsSummary);
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Added ${widget.product.name} to order'),
                    backgroundColor: AppTheme.cocoa,
                    duration: const Duration(seconds: 1),
                  ),
                );
              },
              child: Text(
                'Add to Order • ${AppTheme.formatPaise(totalPrice)}',
                style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w700),
              ),
            ),
          ),
        ],
      ),
    );
  }
}