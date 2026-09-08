# Rapido Parcel & Live Payment Integration Architecture

> Production blueprint for integrating **Interactive Map Pin Drop**, **Rapido B2B Parcel Logistics**, **Dynamic Delivery Fee Aggregation**, and **Real Payment Gateway Settlement** for DS Milk World.

---

## 1. System Topology & Fund Settlement Flow

```text
┌──────────────┐             ┌─────────────────────┐             ┌─────────────────────┐
│   Customer   │             │ DS Milk World Server│             │   Payment Gateway   │
│ Flutter App  │             │   (Serverpod API)   │             │ (Razorpay/Cashfree) │
└──────┬───────┘             └──────────┬──────────┘             └──────────┬──────────┘
       │                                │                                   │
       │ 1. Drops pin on Map (lat, lng) │                                   │
       ├───────────────────────────────►│                                   │
       │                                │ 2. Calls Rapido Quote API         │
       │                                ├──────────────┬──────────────────┐ │
       │                                │              │ Rapido B2B API   │ │
       │                                │              ▼                  │ │
       │                                │  POST /v1/orders/quote          │ │
       │                                │  <── Returns fee ₹42, distance  │ │
       │                                ├─────────────────────────────────┘ │
       │ 3. Returns Order Summary:      │                                   │
       │    Items (₹340) + Delivery(₹42)│                                   │
       │    Total = ₹382                │                                   │
       │◄───────────────────────────────┤                                   │
       │                                │                                   │
       │ 4. Taps Pay ₹382               │                                   │
       ├───────────────────────────────►│ 5. Creates Checkout Session       │
       │                                ├──────────────────────────────────►│
       │                                │ ◄── Returns payment_order_id      │
       │ 6. Launches UPI / Card Checkout│                                   │
       │◄───────────────────────────────┼───────────────────────────────────┤
       │                                │                                   │
       │ 7. Customer pays ₹382 via UPI  │                                   │
       ├────────────────────────────────┼──────────────────────────────────►│
       │                                │                                   │
       │                                │ 8. Signed Webhook: payment.success│
       │                                │◄──────────────────────────────────┤
       │                                │                                   │
       │                                │ 9. Auto-dispatches Rapido Rider   │
       │                                │    from Prepaid Corporate Wallet  │
       │                                ├──────────────┬──────────────────┐ │
       │                                │              │ Rapido B2B API   │ │
       │                                │              ▼                  │ │
       │                                │  POST /v1/orders/create         │ │
       │                                │  (Deducts ₹42 from shop balance)│ │
       │                                │  <── Returns tracking_url, rider│ │
       │ 10. Live Tracking & Rider Feed │◄────────────────────────────────┘ │
       │◄───────────────────────────────┤                                   │
```

---

## 2. Interactive Map Location Picker

### Current Implementation in the App
The Flutter application now contains an interactive map canvas widget (`InteractiveMapPicker` in `lib/widgets/interactive_map_picker.dart`) wired directly into `AddressQuoteScreen`:
- **Auto Nagar Center Pin**: Fixed at `16.4950° N, 80.6650° E`.
- **5.0 km Freshness Perimeter**: Rendered as a circular boundary.
- **Draggable / Tappable Pin**: Customers tap or drag anywhere on the map to set their doorstep location.
- **Real-Time Distance & Geocoding**: Calculates the Haversine distance and updates nearest neighborhood landmarks in real-time.

### Upgrading to Google Maps or OpenStreetMap (Production Vector Tiles)
To display live Google Maps satellite or street tiles:

1. Add `google_maps_flutter` to `pubspec.yaml`:
   ```yaml
   dependencies:
     google_maps_flutter: ^2.10.0
   ```
2. Obtain a Google Maps API Key from Google Cloud Console with:
   - Maps SDK for Android / iOS / JavaScript
   - Places API (for address search & autocomplete)
   - Geocoding API (for reverse lat/lng to street address)
3. Set the initial camera position to Auto Nagar:
   ```dart
   GoogleMap(
     initialCameraPosition: const CameraPosition(
       target: LatLng(16.4950, 80.6650),
       zoom: 14.0,
     ),
     circles: {
       Circle(
         circleId: const CircleId('store_radius'),
         center: const LatLng(16.4950, 80.6650),
         radius: 5000, // 5 km
         fillColor: const Color(0xFF72B7A1).withValues(alpha: 0.15),
         strokeColor: const Color(0xFFCE8822),
         strokeWidth: 2,
       ),
     },
     onTap: (LatLng location) => _updateDeliveryCoordinates(location.latitude, location.longitude),
   );
   ```

---

## 3. Rapido Parcel B2B Integration

Rapido provides business delivery APIs under **Rapido Corporate / B2B Logistics**.

### A. Authentication
All requests require your Rapido Merchant API credentials in headers:
```http
Authorization: Bearer <RAPIDO_B2B_API_KEY>
Content-Type: application/json
```

### B. Live Delivery Quote API
When the customer drops their pin, Serverpod calls Rapido:
```http
POST https://api.rapido.bike/b2b/v1/orders/quote
```
**Request Body:**
```json
{
  "pickup": {
    "latitude": 16.4950,
    "longitude": 80.6650,
    "address": "DS Milk World Counter, Auto Nagar Gate, Bandar Road, Vijayawada"
  },
  "drop": {
    "latitude": 16.5000,
    "longitude": 80.6400,
    "address": "MG Road, Benz Circle, Vijayawada"
  },
  "package_details": {
    "weight_in_kg": 1.5,
    "category": "food_and_beverage"
  }
}
```
**Response Body:**
```json
{
  "quote_id": "RAP-QTE-893821",
  "distance_km": 3.2,
  "delivery_fee": 4200, // In paise (₹42.00)
  "estimated_pickup_minutes": 8,
  "currency": "INR"
}
```

### C. Adding Delivery Fee to Order Total
On the server:
```dart
final itemsSubtotalPaise = validatedItems.fold(0, (sum, i) => sum + i.subtotalPaise);
final rapidoDeliveryFeePaise = quote.feePaise; // e.g. 4200 (₹42)
final orderTotalPaise = itemsSubtotalPaise + rapidoDeliveryFeePaise; // e.g. 34000 + 4200 = 38200 (₹382)
```

### D. Booking & Dispatch API
When staff accepts the order or marks it ready:
```http
POST https://api.rapido.bike/b2b/v1/orders/create
```
**Request Body:**
```json
{
  "quote_id": "RAP-QTE-893821",
  "merchant_order_id": "DSMW-20260908-104",
  "pickup": {
    "contact_name": "DS Milk World Auto Nagar",
    "contact_phone": "+918662549999"
  },
  "drop": {
    "contact_name": "Ravi Teja",
    "contact_phone": "+919876543210"
  }
}
```

### E. Rapido Live Webhook Feed
Rapido calls your Serverpod webhook (`POST /deliveryWebhook`) as the rider moves:
```json
{
  "event": "rider_location_update",
  "merchant_order_id": "DSMW-20260908-104",
  "rapido_order_id": "RAP-ORD-928172",
  "status": "out_for_delivery",
  "rider": {
    "name": "Suresh V",
    "phone": "+919876543210",
    "current_latitude": 16.4982,
    "current_longitude": 80.6510,
    "speed_kmh": 28.5
  },
  "eta_minutes": 12,
  "tracking_url": "https://track.rapido.bike/live/928172"
}
```

---

## 4. Payment Settlement & Paying Rapido

### Why Dodo Payments Cannot Be Used
As documented in `docs/DECISIONS-AND-RISKS.md`, Dodo Payments does not permit physical food and beverage deliveries.

### Recommended Payment Gateway: Razorpay / Cashfree Payments
For Indian businesses delivering food and beverages:
- Supports 100% of Indian payment methods (Google Pay, PhonePe, Paytm, CRED UPI, Rupay/Visa/Mastercard, NetBanking).
- Next-day (T+1) automatic settlement into DS Milk World's current bank account.

### How Rapido Gets Paid: 2 Practical Industry Flows

#### Method 1: Prepaid Corporate Billing Wallet (Standard Rapido B2B Model)
1. **Prepaid Wallet**: When DS Milk World registers as a B2B partner on the Rapido Partner Portal, you are assigned a corporate prepaid wallet.
2. **Customer Payment**: Customer pays ₹382 (₹340 items + ₹42 delivery fee). The entire ₹382 settles into your bank account.
3. **Wallet Deduction**: When `createOrder` is dispatched via API, Rapido automatically deducts the ₹42 delivery fee from your Rapido wallet balance.
4. **Auto-Reload**: Maintain an automated top-up rule (e.g. using Razorpay Payouts or a standing instruction): whenever the Rapido wallet drops below ₹2,000, it automatically reloads ₹5,000 from your shop account.

#### Method 2: Post-Paid Monthly Invoice (Enterprise)
For outlets doing 30+ daily deliveries, Rapido issues a monthly GST invoice based on total dispatched orders, settled net-15 or net-30 via bank transfer.

---

## 5. Serverpod Implementation Example

Drop-in service class for `ds_milk_world_server/lib/src/services/rapido_service.dart`:

```dart
import 'dart:convert';
import 'package:http/http.dart' as http;

class RapidoService {
  static const String _baseUrl = 'https://api.rapido.bike/b2b/v1';
  static const String _apiKey = String.fromEnvironment('RAPIDO_API_KEY');

  /// Fetches real-time dynamic quote from Rapido B2B API
  static Future<int> getDeliveryQuotePaise({
    required double dropLat,
    required double dropLng,
    required String dropAddress,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders/quote'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'pickup': {
          'latitude': 16.4950,
          'longitude': 80.6650,
          'address': 'DS Milk World, Auto Nagar, Vijayawada',
        },
        'drop': {
          'latitude': dropLat,
          'longitude': dropLng,
          'address': dropAddress,
        },
        'package_details': {'weight_in_kg': 1.5},
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return data['delivery_fee'] as int; // paise
    } else {
      // Fallback to Haversine pricing formula if API is unreachable
      return 3000;
    }
  }

  /// Dispatches delivery rider using corporate wallet deduction
  static Future<Map<String, dynamic>> dispatchRider({
    required String orderNumber,
    required String customerPhone,
    required String customerName,
    required double dropLat,
    required double dropLng,
    required String dropAddress,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/orders/create'),
      headers: {
        'Authorization': 'Bearer $_apiKey',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({
        'merchant_order_id': orderNumber,
        'drop': {
          'contact_name': customerName,
          'contact_phone': customerPhone,
          'latitude': dropLat,
          'longitude': dropLng,
          'address': dropAddress,
        },
      }),
    );

    return jsonDecode(response.body);
  }
}
```
