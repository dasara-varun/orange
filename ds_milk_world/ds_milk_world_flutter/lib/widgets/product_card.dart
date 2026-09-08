import 'package:flutter/material.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import '../theme/app_theme.dart';
import '../state/cart_state.dart';
import 'customization_sheet.dart';

class ProductCard extends StatelessWidget {
  final Product product;

  const ProductCard({super.key, required this.product});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: CartState.instance,
      builder: (context, _) {
        final qty = CartState.instance.getQuantity(product.sku);
        final price = product.offerPricePaise ?? product.pricePaise;

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Veg mark and category indicator
                Container(
                  margin: const EdgeInsets.only(top: 2, right: 10),
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
                // Main product info
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        product.name,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.cocoa,
                          letterSpacing: -0.3,
                        ),
                      ),
                      if (product.sizeOrServing != null &&
                          !product.sizeOrServing!.toLowerCase().contains('not published'))
                        Padding(
                          padding: const EdgeInsets.only(top: 2),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: AppTheme.cream,
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              product.sizeOrServing!,
                              style: const TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: AppTheme.cocoa,
                              ),
                            ),
                          ),
                        ),
                      if (product.shortDescription != null && product.shortDescription!.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 4),
                          child: Text(
                            product.shortDescription!,
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppTheme.muted,
                              height: 1.3,
                            ),
                          ),
                        ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Text(
                            AppTheme.formatPaise(price),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: AppTheme.cocoa,
                            ),
                          ),
                          if (product.offerPricePaise != null) ...[
                            const SizedBox(width: 6),
                            Text(
                              AppTheme.formatPaise(product.pricePaise),
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
                // Add / Stepper button
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (!product.availability)
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
                            if (product.customisable) {
                              CustomizationSheet.show(context, product);
                            } else {
                              CartState.instance.addProduct(product);
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.cream,
                            foregroundColor: AppTheme.cocoa,
                            side: const BorderSide(color: AppTheme.saffron, width: 1.5),
                            padding: const EdgeInsets.symmetric(horizontal: 14),
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
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.remove, size: 14, color: Colors.white),
                              padding: const EdgeInsets.symmetric(horizontal: 6),
                              constraints: const BoxConstraints(),
                              onPressed: () => CartState.instance.removeProduct(product.sku),
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
                              onPressed: () => CartState.instance.addProduct(product),
                            ),
                          ],
                        ),
                      ),
                    if (product.customisable && product.availability)
                      Padding(
                        padding: const EdgeInsets.only(top: 4),
                        child: InkWell(
                          onTap: () => CustomizationSheet.show(context, product),
                          child: const Text(
                            'customise',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: AppTheme.saffronDark,
                            ),
                          ),
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