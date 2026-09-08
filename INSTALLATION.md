# DS Milk World — Installation & Deployment Guide

Welcome to the **DS Milk World** direct-ordering MVP platform installation guide. This guide explains how to install, configure, containerize, and run the complete All-Dart fullstack application across **Docker Compose** or directly in your local development environment.

---

## 🏗️ Architecture & Port Mapping

```text
┌─────────────────────────────────────────────────────────────────────────────┐
│                       Host System / Gateway                                 │
└──────┬───────────────────────────────┬───────────────────────────────┬──────┘
       │ :3000                         │ :8080                         │ :8090
       ▼                               ▼                               ▼
┌──────────────┐               ┌──────────────┐               ┌──────────────┐
│ Flutter Web  │ (Nginx)       │ Serverpod API│ (Dart 3.5)    │  PostgreSQL  │ (pg16)
│ Storefront & │ ────────────► │ Monolith     │ ────────────► │  Database    │
│ Staff Console│               │ Endpoints    │               │  & Vectors   │
└──────────────┘               └──────────────┘               └──────────────┘
```

| Service | Container / Process | Port | Purpose |
| :--- | :--- | :--- | :--- |
| **Flutter Web** | `web` (Nginx Alpine) | `3000` (mapped to `80`) | Customer Storefront & Staff Ops Console |
| **Serverpod API** | `serverpod` (Dart binary) | `8080` | Main REST & RPC endpoints |
| **Serverpod Insights** | `serverpod` | `8081` | Server health, diagnostics, and metrics |
| **Serverpod Web** | `serverpod` | `8082` | Backend diagnostic web server |
| **PostgreSQL** | `postgres` (pgvector 16) | `8090` (mapped to `5432`)| Persistent transactional database |

---

## 📱 Application User Interface Previews

### 1. Customer Storefront
Warm dairy palette (`#FFF9F0` Milk, `#3A241B` Cocoa, `#FFF1D6` Cream), category rail (Falooda, Specials, Shakes), 79 item catalog, and 5 km radius notice:

![DS Milk World Storefront](docs/images/storefront_preview.jpg)

### 2. Staff Operations Console
Live order cards, Kanban queue, prep accept (15-45m), packaging checklist, delivery partner dispatch, and real-time catalog price/stock management:

![Staff Operations Console](docs/images/staff_console_preview.jpg)

### 3. Real-Time Order Tracking
Vertical stepper timeline from payment confirmation to door delivery, live ETA, rider details, WhatsApp help, and Auto Nagar counter contact:

![Live Order Tracking](docs/images/order_tracking_preview.jpg)

---

## 🚀 Option 1: 1-Click Containerized Installation (Docker)

This is the recommended installation method for production or containerized testing.

### 1. Prerequisites
- Docker Engine `>= 24.0.0`
- Docker Compose `>= 2.20.0`

### 2. Launch the Application Stack
From the project root directory (`e:\sh`):

```bash
# Build and start all containers in detached mode
docker compose up --build -d
```

### 3. Verify Container Status
```bash
docker compose ps
```

All 3 services (`postgres`, `serverpod`, and `web`) should report `Up` or `healthy`.

### 4. Access the Applications
- **Customer Storefront & Staff Console**: Open your browser to `http://localhost:3000`
- **Serverpod API Healthcheck**: Open `http://localhost:8080`
- **Serverpod Insights Dashboard**: Open `http://localhost:8081`

### 5. Stopping the Stack
```bash
docker compose down
```

---

## 💻 Option 2: Native Bare-Metal Local Development

Follow these steps to run the backend server and Flutter frontend directly on your local workstation without Docker.

### 1. Prerequisites
- **Flutter SDK**: `>= 3.24.0` (installed at `E:\flutter\bin`)
- **Dart SDK**: `>= 3.5.0`
- **Serverpod CLI**: `2.9.5` (installed in Pub Cache)
- **PostgreSQL**: Version 15 or 16 running on port `8090` or `5432`

### 2. Configure Environment Path (Windows PowerShell)
```powershell
$env:PATH = "E:\flutter\bin;$env:USERPROFILE\AppData\Local\Pub\Cache\bin;" + $env:PATH
```

### 3. Start Database Service
You can use Docker solely for PostgreSQL:
```powershell
docker compose up postgres -d
```

### 4. Run Serverpod Database Migrations
Navigate to the server directory and apply existing migrations:
```powershell
cd ds_milk_world/ds_milk_world_server

# Verify or generate protocol and client
serverpod generate

# Run database migrations
dart run bin/main.dart --mode=production --apply-migrations
```

### 5. Start the Serverpod Backend Server
```powershell
cd ds_milk_world/ds_milk_world_server
dart run bin/main.dart
```
The server will bind to `localhost:8080`.

### 6. Launch the Flutter Storefront & Staff App
In a new terminal window:
```powershell
# Set path
$env:PATH = "E:\flutter\bin;$env:USERPROFILE\AppData\Local\Pub\Cache\bin;" + $env:PATH

cd ds_milk_world/ds_milk_world_flutter

# Install Flutter dependencies
flutter pub get

# Run on Chrome (Web)
flutter run -d chrome

# Or run as a native Windows desktop app
flutter run -d windows
```

---

## 🧪 Verification & Automated Test Suite

### 1. Run Server Unit Tests (12/12 passing)
Validates Haversine distance, 5.0 km geofence, dynamic fees, server-side pricing recalculation, order creation, payment idempotency, order cancellation, and staff transitions:
```powershell
cd ds_milk_world/ds_milk_world_server
dart test test/order_lifecycle_test.dart
```

### 2. Run Flutter Static Analysis (0 issues)
```powershell
cd ds_milk_world/ds_milk_world_flutter
flutter analyze
```

### 3. Run Flutter Widget & State Tests (5/5 passing)
Validates reactive cart operations, menu rendering, past order history navigation, and Direct Guarantee modal:
```powershell
cd ds_milk_world/ds_milk_world_flutter
flutter test test/app_test.dart
```

### 4. Build Release Web Artifacts
Compiles the complete optimized single-page web bundle to `build/web`:
```powershell
cd ds_milk_world/ds_milk_world_flutter
flutter build web --release
```

---

## 📡 Webhook & Integration Simulation

### 1. Payment Webhook Callback
To simulate a payment confirmation event from the payment gateway:
```bash
curl -X POST http://localhost:8080/paymentWebhook \
  -H "Content-Type: application/json" \
  -H "X-Webhook-Signature: valid-test-signature" \
  -d '{
    "eventId": "EVT-TEST-001",
    "orderNumber": "DSMW-20260908-1",
    "status": "payment_successful",
    "providerPaymentId": "pay_test_983719"
  }'
```

### 2. Delivery Partner Webhook Callback
To simulate partner updates (Rapido / Shadowfax):
```bash
curl -X POST http://localhost:8080/deliveryWebhook \
  -H "Content-Type: application/json" \
  -d '{
    "orderNumber": "DSMW-20260908-1",
    "status": "out_for_delivery",
    "riderName": "Suresh V",
    "riderPhone": "+91 98765 43210",
    "trackingUrl": "https://track.rapido.bike/del-4982"
  }'
```

---

## 🛡️ Operational Safeguards & Contact

- **Pilot Outlet Location**: Auto Nagar, Bandar Road, Vijayawada (`16.4950° N, 80.6650° E`)
- **Direct Phone Hotline**: `+91 866 254 9999`
- **FSSAI Food Safety Compliance**: Counter hygiene standards enforced for all chilled dairy preparation.
