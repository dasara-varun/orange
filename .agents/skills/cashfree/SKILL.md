---
name: cashfree
description: Cashfree Payments integration suite — Payment Gateway (PG), S2S REST APIs, Flutter & Web SDKs, UPI Intent, Webhook verification, Auto Collect, Settlements & Recon, and Cashfree MCP Server integration. Use whenever the user asks about Cashfree, payment gateway integration, collecting payments via UPI/cards/netbanking, verifying webhooks, processing refunds, or using Cashfree MCP tools.
---

# Cashfree Payments — AI Agent Skill & Integration Guide

This skill provides comprehensive instructions for integrating and managing Cashfree Payments on the DS Milk World direct-ordering platform.

---

## 🚀 Quick Navigation & Skill Map

The Cashfree skill tree is installed at `.agents/skills/cashfree-skills/` and `.agent/skills/cashfree-skills/`. Consult the targeted sub-skills below based on user intent:

| Task / User Intent | Target Sub-Skill Document |
| :--- | :--- |
| **Getting Started & Credentials** | [`.agents/skills/cashfree-skills/getting-started/SKILL.md`](../cashfree-skills/getting-started/SKILL.md) |
| **Check Activated Payment Modes** | [`.agents/skills/cashfree-skills/eligible-payment-modes/SKILL.md`](../cashfree-skills/eligible-payment-modes/SKILL.md) |
| **Payment Gateway Overview** | [`.agents/skills/cashfree-skills/pg/SKILL.md`](../cashfree-skills/pg/SKILL.md) |
| **Server-to-Server REST APIs** | [`.agents/skills/cashfree-skills/pg/apis/SKILL.md`](../cashfree-skills/pg/apis/SKILL.md) |
| **Backend SDKs (Node, Python, Java, Go)**| [`.agents/skills/cashfree-skills/pg/backend-sdks/SKILL.md`](../cashfree-skills/pg/backend-sdks/SKILL.md) |
| **Mobile & Flutter SDKs** | [`.agents/skills/cashfree-skills/pg/mobile-sdks/SKILL.md`](../cashfree-skills/pg/mobile-sdks/SKILL.md) |
| **Web Checkout (Cashfree.js v3)** | [`.agents/skills/cashfree-skills/pg/web-sdk/SKILL.md`](../cashfree-skills/pg/web-sdk/SKILL.md) |
| **Webhooks & Signature Verification** | [`.agents/skills/cashfree-skills/pg/webhooks/SKILL.md`](../cashfree-skills/pg/webhooks/SKILL.md) |
| **Refunds (Instant & Standard)** | [`.agents/skills/cashfree-skills/pg/refunds/SKILL.md`](../cashfree-skills/pg/refunds/SKILL.md) |
| **Disputes & Chargebacks** | [`.agents/skills/cashfree-skills/pg/disputes/SKILL.md`](../cashfree-skills/pg/disputes/SKILL.md) |
| **Payment Links (SMS / WhatsApp)** | [`.agents/skills/cashfree-skills/pg/payment-links/SKILL.md`](../cashfree-skills/pg/payment-links/SKILL.md) |
| **Settlements & Bank Recon** | [`.agents/skills/cashfree-skills/settlements-and-reconciliation/SKILL.md`](../cashfree-skills/settlements-and-reconciliation/SKILL.md) |
| **Testing Sandbox & Validation** | [`.agents/skills/cashfree-skills/validation-and-testing/SKILL.md`](../cashfree-skills/validation-and-testing/SKILL.md) |
| **Go-Live Production Checklist** | [`.agents/skills/cashfree-skills/pg/go-live/SKILL.md`](../cashfree-skills/pg/go-live/SKILL.md) |
| **Common Errors & Troubleshooting** | [`.agents/skills/cashfree-skills/common-mistakes/SKILL.md`](../cashfree-skills/common-mistakes/SKILL.md) |

---

## ⚡ Core Integration Flow for DS Milk World

```
Customer Cart (Flutter) ──> POST /order/create ──> Serverpod Backend (Port 8080)
                                                          │
                                                          ▼
                                            POST /pg/orders (Cashfree API)
                                            (Pass order_amount in INR, order_id, customer)
                                                          │
                                                          ▼
                                            Returns payment_session_id
                                                          │
Customer Browser <── Renders Cashfree.js Dropin <─────────┘
        │
Customer Pays (UPI / Card)
        │
Cashfree PG Server ──> POST /payment-webhook ──> Serverpod Webhook Endpoint
                                                          │
                                                Verify HMAC-SHA256 Signature
                                                Transition Order to 'shop_acceptance_pending'
                                                KOT Printed at Kanuru Counter
```

### 1. Environment Endpoints & API Versions
- **Sandbox Base URL**: `https://sandbox.cashfree.com/pg`
- **Production Base URL**: `https://api.cashfree.com/pg`
- **API Version**: `2023-08-01` (or `2025-01-01`)
- **Headers Required**:
  ```http
  x-client-id: <CASHFREE_APP_ID>
  x-client-secret: <CASHFREE_SECRET_KEY>
  x-api-version: 2023-08-01
  Content-Type: application/json
  ```

### 2. Creating a Payment Order (Serverpod S2S)
```json
POST /pg/orders
{
  "order_id": "DSMW-20260916-01",
  "order_amount": 290.00,
  "order_currency": "INR",
  "customer_details": {
    "customer_id": "CUST-9876543210",
    "customer_phone": "9876543210",
    "customer_name": "Ravi Kumar"
  },
  "order_meta": {
    "return_url": "https://orders.dsmilkworld.com/order-tracking/{order_id}",
    "notify_url": "https://api.dsmilkworld.com/payment-webhook"
  },
  "order_note": "DS Milk World Kanuru Order"
}
```

### 3. Webhook Signature Verification (Crucial Security Invariant)
Every incoming webhook must be verified using the secret key before updating order status:
```dart
// Compute signature in Dart/Serverpod:
// rawBody + timestamp signed with HMAC-SHA256 using CASHFREE_SECRET_KEY
import 'dart:convert';
import 'package:crypto/crypto.dart';

bool verifyCashfreeSignature(String rawBody, String timestamp, String signature, String secret) {
  final payload = '$timestamp$rawBody';
  final hmac = Hmac(sha256, utf8.encode(secret));
  final digest = hmac.convert(utf8.encode(payload));
  final computed = base64.encode(digest.bytes);
  return computed == signature;
}
```

---

## 🤖 Cashfree Model Context Protocol (MCP) Server

Connect your AI assistant directly to your Cashfree account to query balances, settlement dates, transaction states, and download recon reports.

### MCP Configuration
- **Endpoint URL**: `https://mcp.cashfree.com/mcp`
- **Cursor Config (`.cursor/mcp.json`)**:
  ```json
  {
    "mcpServers": {
      "cashfree": {
        "url": "https://mcp.cashfree.com/mcp"
      }
    }
  }
  ```
- **Claude Code CLI**:
  ```bash
  claude mcp add --transport http cashfree https://mcp.cashfree.com/mcp
  ```

### Available MCP Tools
- `get_transaction_details`: Query the complete lifecycle of a transaction.
- `search_orders`: Search orders matching filters (date, customer, status).
- `get_unsettled_amount`: View total unsettled funds held by Cashfree.
- `get_next_settlement_date`: Next scheduled bank transfer date.
- `create_payment_link`: Generate instant payment links for customer WhatsApp support.
- `search_product_docs`: Natural language search across Cashfree technical docs.
