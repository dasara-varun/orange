import 'package:flutter/foundation.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';

class CartState extends ChangeNotifier {
  static final CartState instance = CartState._();
  CartState._();

  final List<OrderItem> _items = [];

  List<OrderItem> get items => List.unmodifiable(_items);

  int get totalItems => _items.fold(0, (sum, item) => sum + item.quantity);

  int get subtotalPaise => _items.fold(0, (sum, item) => sum + item.subtotalPaise);

  int getQuantity(String sku) {
    try {
      return _items.firstWhere((i) => i.productSku == sku).quantity;
    } catch (_) {
      return 0;
    }
  }

  void addProduct(Product product, {String? options}) {
    final existingIndex = _items.indexWhere((i) => i.productSku == product.sku);
    final unitPrice = product.offerPricePaise ?? product.pricePaise;

    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      final newQty = existing.quantity + 1;
      _items[existingIndex] = OrderItem(
        productSku: product.sku,
        nameSnapshot: product.name,
        unitPricePaise: unitPrice,
        quantity: newQty,
        optionsSnapshot: options ?? existing.optionsSnapshot,
        subtotalPaise: unitPrice * newQty,
      );
    } else {
      _items.add(OrderItem(
        productSku: product.sku,
        nameSnapshot: product.name,
        unitPricePaise: unitPrice,
        quantity: 1,
        optionsSnapshot: options,
        subtotalPaise: unitPrice,
      ));
    }
    notifyListeners();
  }

  void incrementProduct(String sku) {
    final existingIndex = _items.indexWhere((i) => i.productSku == sku);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      final newQty = existing.quantity + 1;
      _items[existingIndex] = OrderItem(
        productSku: existing.productSku,
        nameSnapshot: existing.nameSnapshot,
        unitPricePaise: existing.unitPricePaise,
        quantity: newQty,
        optionsSnapshot: existing.optionsSnapshot,
        subtotalPaise: existing.unitPricePaise * newQty,
      );
      notifyListeners();
    }
  }

  void removeProduct(String sku) {
    final existingIndex = _items.indexWhere((i) => i.productSku == sku);
    if (existingIndex >= 0) {
      final existing = _items[existingIndex];
      if (existing.quantity > 1) {
        final newQty = existing.quantity - 1;
        _items[existingIndex] = OrderItem(
          productSku: existing.productSku,
          nameSnapshot: existing.nameSnapshot,
          unitPricePaise: existing.unitPricePaise,
          quantity: newQty,
          optionsSnapshot: existing.optionsSnapshot,
          subtotalPaise: existing.unitPricePaise * newQty,
        );
      } else {
        _items.removeAt(existingIndex);
      }
      notifyListeners();
    }
  }

  void deleteItem(String sku) {
    _items.removeWhere((i) => i.productSku == sku);
    notifyListeners();
  }

  void clearCart() {
    _items.clear();
    notifyListeners();
  }
}