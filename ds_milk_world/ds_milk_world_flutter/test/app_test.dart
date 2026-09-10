import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:ds_milk_world_client/ds_milk_world_client.dart';
import 'package:ds_milk_world_flutter/main.dart';
import 'package:ds_milk_world_flutter/state/cart_state.dart';
import 'package:ds_milk_world_flutter/services/mock_data.dart';
import 'package:ds_milk_world_flutter/screens/order_history_screen.dart';
import 'package:ds_milk_world_flutter/widgets/interactive_map_picker.dart';

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

    testWidgets('Opens Order History screen and displays empty state or orders', (WidgetTester tester) async {
      await tester.pumpWidget(const MaterialApp(home: OrderHistoryScreen()));
      await tester.pumpAndSettle();

      expect(find.text('My Past Orders'), findsOneWidget);
      expect(find.text('Start Ordering'), findsOneWidget);
    });

    testWidgets('Tapping guarantee banner shows DS Milk World Direct Guarantee dialog', (WidgetTester tester) async {
      await tester.pumpWidget(const DsMilkWorldApp());
      await tester.pumpAndSettle();

      final bannerText = find.textContaining('Direct prep');
      expect(bannerText, findsOneWidget);
      await tester.tap(bannerText);
      await tester.pumpAndSettle();

      expect(find.text('DS Milk World Direct Guarantee'), findsOneWidget);
      expect(find.text('Authentic Counter Prices'), findsOneWidget);
      expect(find.text('5.0 km Strict Freshness Perimeter'), findsOneWidget);

      await tester.tap(find.text('Got It'));
      await tester.pumpAndSettle();
      expect(find.text('DS Milk World Direct Guarantee'), findsNothing);
    });

    testWidgets('InteractiveMapPicker renders OpenStreetMap controls and Rapido rate card', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: InteractiveMapPicker(
                initialLat: 16.4950,
                initialLng: 80.6650,
                onLocationChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      expect(find.text('Live OpenStreetMap & Rapido Rate'), findsOneWidget);
      expect(find.textContaining('OpenStreetMap'), findsWidgets);
      expect(find.byTooltip('Use My Current GPS Location'), findsOneWidget);
      expect(find.byTooltip('Center on Auto Nagar Outlet'), findsOneWidget);
      expect(find.text('Auto Nagar Gate (Outlet Location)'), findsOneWidget);
      expect(find.text('Rapido Bike Parcel'), findsOneWidget);
    });
  });
}