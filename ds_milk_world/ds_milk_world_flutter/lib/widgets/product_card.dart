import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';

class ProductCard extends StatefulWidget {
  final Product? product;
  final List<Product>? variants;

  const ProductCard({
    super.key,
    this.product,
    this.variants,
  });

  @override
  State<ProductCard> createState() => _ProductCardState();
}

class _ProductCardState extends State<ProductCard> {
  int _selectedVariantIndex = 0;

  List<Product> get _allVariants {
    if (widget.variants != null && widget.variants!.isNotEmpty) {
      return widget.variants!;
    }
    if (widget.product != null) {
      return [widget.product!];
    }
    return [];
  }

  @override
  Widget build(BuildContext context) {
    final variants = _allVariants;
    if (variants.isEmpty) return const SizedBox.shrink();

    final safeIndex = _selectedVariantIndex.clamp(0, variants.length - 1);
    final activeProduct = variants[safeIndex];

    return ListenableBuilder(
      listenable: CartState.instance,
      builder: (context, _) {
        final qty = CartState.instance.getQuantity(activeProduct.sku);
        final price = activeProduct.offerPricePaise ?? activeProduct.pricePaise;
        final hasMultipleVariants = variants.length > 1;

        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppTheme.border, width: 1),
            boxShadow: [
              BoxShadow(
                color: AppTheme.cocoa.withValues(alpha: 0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Veg indicator
                Container(
                  margin: const EdgeInsets.only(top: 4, right: 10),
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    border: Border.all(color: const Color(0xFF2E7D32), width: 1.5),
                    borderRadius: BorderRadius.circular(3),
                  ),
                  child: Center(
                    child: Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: Color(0xFF2E7D32),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ),

                // Main Info Column: Title, Serving, Description, Variant Pills, Price
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        activeProduct.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: AppTheme.cocoa,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (!hasMultipleVariants &&
                          activeProduct.sizeOrServing != null &&
                          !activeProduct.sizeOrServing!.toLowerCase().contains('not published'))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.cream,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              activeProduct.sizeOrServing!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cocoa,
                              ),
                            ),
                          ),
                        ),
                      if (activeProduct.shortDescription != null && activeProduct.shortDescription!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            activeProduct.shortDescription!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              height: 1.3,
                            ),
                          ),
                        ),

                      // Size & Variant Selector Pills
                      if (hasMultipleVariants) ...[
                        const SizedBox(height: 8),
                        Wrap(
                          spacing: 6,
                          runSpacing: 6,
                          children: List.generate(variants.length, (idx) {
                            final v = variants[idx];
                            final isSelected = idx == safeIndex;
                            final vPrice = v.offerPricePaise ?? v.pricePaise;
                            final vLabel = v.sizeOrServing ?? 'Standard';

                            return InkWell(
                              onTap: () {
                                setState(() => _selectedVariantIndex = idx);
                              },
                              borderRadius: BorderRadius.circular(16),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 150),
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                decoration: BoxDecoration(
                                  color: isSelected ? AppTheme.cream : const Color(0xFFF9F6F0),
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: isSelected ? AppTheme.saffronDark : AppTheme.border,
                                    width: isSelected ? 1.5 : 1.0,
                                  ),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isSelected) ...[
                                      const Icon(Icons.check_circle, size: 11, color: AppTheme.saffronDark),
                                      const SizedBox(width: 3),
                                    ],
                                    Text(
                                      vLabel,
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                        color: isSelected ? AppTheme.cocoa : AppTheme.cocoa.withValues(alpha: 0.8),
                                      ),
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      '• ₹${vPrice ~/ 100}',
                                      style: TextStyle(
                                        fontSize: 11,
                                        fontWeight: isSelected ? FontWeight.w900 : FontWeight.w700,
                                        color: isSelected ? AppTheme.saffronDark : AppTheme.muted,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }),
                        ),
                      ],

                      const SizedBox(height: 8),
                      // Price row
                      Row(
                        children: [
                          Text(
                            AppTheme.formatPaise(price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w900,
                              color: AppTheme.cocoa,
                            ),
                          ),
                          if (activeProduct.offerPricePaise != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              AppTheme.formatPaise(activeProduct.pricePaise),
                              style: const TextStyle(
                                fontSize: 12,
                                color: AppTheme.muted,
                                decoration: TextDecoration.lineThrough,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(width: 12),

                // Right Column: Add / Stepper button & Customise Link
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (!activeProduct.availability)
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                        decoration: BoxDecoration(
                          color: Colors.grey[200],
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          'Sold Out',
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: Colors.grey,
                          ),
                        ),
                      )
                    else if (qty == 0)
                      SizedBox(
                        height: 36,
                        child: ElevatedButton(
                          onPressed: () {
                            CartState.instance.addProduct(
                              activeProduct,
                              options: activeProduct.sizeOrServing,
                            );
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cream,
                            foregroundColor: AppTheme.cocoa,
                            side: const BorderSide(color: AppTheme.saffron, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
                            elevation: 0,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: const [
                              Text(
                                'ADD',
                                style: TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              SizedBox(width: 4),
                              Icon(Icons.add, size: 14, color: AppTheme.cocoa),
                            ],
                          ),
                        ),
                      )
                    else
                      Container(
                        height: 36,
                        decoration: BoxDecoration(
                          color: AppTheme.cocoa,
                          borderRadius: BorderRadius.circular(8),
                          boxShadow: const [
                            BoxShadow(color: Colors.black12, blurRadius: 4, offset: Offset(0, 2)),
                          ],
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              constraints: const BoxConstraints(),
                              onPressed: () => CartState.instance.removeProduct(activeProduct.sku),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 8),
                              child: Text(
                                '$qty',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 13,
                                ),
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.add, size: 14, color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              constraints: const BoxConstraints(),
                              onPressed: () => CartState.instance.addProduct(
                                activeProduct,
                                options: activeProduct.sizeOrServing,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
