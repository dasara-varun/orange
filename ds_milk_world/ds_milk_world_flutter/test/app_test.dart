import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:serverpod_flutter/serverpod_flutter.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import 'package:ds_milk_world_flutter/main.dart';
import 'package:ds_milk_world_flutter/state/cart_state.dart';
import 'package:ds_milk_world_flutter/services/mock_data.dart';

void main() {
  setUpAll(() {
    client = Client('http://localhost:8080/');
  });

  setUp(() {
    CartState.instance.clearCart();
  });

  group('CartState Unit Tests', () {
    test('Initial cart is empty', () {
      expect(CartState.instance.items.isEmpty, isTrue);
      expect(CartState.instance.totalItems, equals(0));
      expect(CartState.instance.subtotalPaise, equals(0));
    });

    test('Adding products updates quantity and subtotal correctly', () {
      final oreoFalooda = MockData.getProductBySku('DSMW-001')!; // Rs 160 = 16000 paise
      final roseFalooda = MockData.getProductBySku('DSMW-002')!;  // Rs 130 = 13000 paise

      CartState.instance.addProduct(oreoFalooda);
      expect(CartState.instance.totalItems, equals(1));
      expect(CartState.instance.getQuantity('DSMW-001'), equals(1));
      expect(CartState.instance.subtotalPaise, equals(16000));

      CartState.instance.incrementProduct('DSMW-001');
      expect(CartState.instance.totalItems, equals(2));
      expect(CartState.instance.getQuantity('DSMW-001'), equals(2));
      expect(CartState.instance.subtotalPaise, equals(32000));

      CartState.instance.addProduct(roseFalooda);
      expect(CartState.instance.totalItems, equals(3));
      expect(CartState.instance.subtotalPaise, equals(45000));

      CartState.instance.removeProduct('DSMW-001');
      expect(CartState.instance.getQuantity('DSMW-001'), equals(1));
      expect(CartState.instance.totalItems, equals(2));

      CartState.instance.clearCart();
      expect(CartState.instance.items.isEmpty, isTrue);
    });
  });

  group('Storefront Widget Tests', () {
    testWidgets('Renders DS Milk World storefront header, categories and items', (WidgetTester tester) async {
      await tester.pumpWidget(const DsMilkWorldApp());
      await tester.pumpAndSettle();

      // Outlet header
      expect(find.text('DS Milk World'), findsOneWidget);
      expect(find.textContaining('Auto Nagar Counter'), findsWidgets);
      expect(find.text('All Items'), findsOneWidget);
      expect(find.text('Falooda'), findsOneWidget);
      expect(find.text('Thick Shakes'), findsOneWidget);

      // Product item
      expect(find.text('Oreo Falooda'), findsOneWidget);
      expect(find.text('₹160'), findsWidgets);

      // Tap ADD on Oreo Falooda
      final addButtons = find.text('ADD');
      expect(addButtons, findsWidgets);
      await tester.tap(addButtons.first);
      await tester.pumpAndSettle();

      // Floating Cart bar should appear
      expect(find.textContaining('1 item'), findsOneWidget);
      expect(find.text('View Cart'), findsOneWidget);
    });
  });
}