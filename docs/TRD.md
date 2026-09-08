# Technical Requirements Document — DS Milk World Direct Ordering MVP

## 1. Technical direction

Use **Flutter and Dart** for the customer app, staff console, responsive web build, Android build, and iOS build. Use **Serverpod 3.x with Dart** for the backend. This is the final stack recommendation because it keeps the complete product in one language, provides typed client/server contracts, supports PostgreSQL, and reduces the number of technologies required for the pilot. Serverpod's documented features include generated client integration, authentication options, database support, caching options, and Docker-compatible deployment.[6]

Use a **modular monolith** first. Modules are catalog, outlet, customer, cart, order, payment, delivery, notification, refund, and operations. They share one deployment and one PostgreSQL database but communicate through explicit service interfaces and an outbox table. This gives the simplicity of one service without creating a rewrite when more outlets are added.

Deploy the Serverpod service as a container on a managed container platform. Host the Flutter web build on managed HTTPS hosting. Use managed PostgreSQL with point-in-time recovery and backups. Add a managed Redis-compatible cache only when rate limiting, quote caching, or distributed locks are measured requirements. Do not introduce microservices, Kubernetes, or a message broker in the MVP.

## 2. Logical architecture

```text
Flutter/Dart customer and staff clients
        │ HTTPS / generated Serverpod client
        ▼
Serverpod 3.x / Dart modular monolith
        ├── Auth and role policy
        ├── Catalog and outlet module
        ├── Cart and order module
        ├── Checkout orchestration module
        ├── Payment adapter module
        ├── Delivery adapter module
        ├── Notification and support module
        └── Audit and operations module
        │
        ├── Managed PostgreSQL: source of truth
        ├── Outbox table: reliable external side effects
        ├── Optional Redis: cache, rate limits, distributed locks
        ├── S3-compatible storage: future media and documents
        └── External providers: payment, maps, delivery, SMS/WhatsApp
```

The web and mobile clients must never contain payment secrets, delivery credentials, database credentials, or privileged business rules.

## 3. Suggested components

| Concern | Recommendation |
|---|---|
| UI and client | Flutter/Dart, responsive layout, deep links, installable web app |
| API and backend | Serverpod 3.x with Dart; generated typed client and endpoint contracts |
| Database | Managed PostgreSQL 16+ with migrations, backups, point-in-time recovery, and pooling |
| Authentication | Passwordless phone verification or magic link; staff accounts require stronger authentication |
| Payment | India-capable gateway adapter; Dodo excluded for physical-goods checkout unless written approval is obtained |
| Delivery | Official provider API or aggregator adapter; manual fallback is mandatory |
| Maps | Geocoding and map tiles behind a provider interface; store coordinates and address snapshot |
| Notifications | Transactional SMS/WhatsApp/email provider with retry and delivery logs |
| Monitoring | Structured logs, error tracking, uptime checks, webhook metrics, and business dashboards |
| Deployment | Dockerized Serverpod service plus managed Flutter web hosting, with separate test and live environments |

## 4. Core data model

| Table | Key fields |
|---|---|
| `outlets` | id, name, phone, address, status, service_radius_m, timezone |
| `users` | id, phone, email, role, status, created_at |
| `addresses` | id, user_id, label, line_1, landmark, latitude, longitude, geocode_precision |
| `categories` | id, outlet_id, name, sort_order, published |
| `products` | id, outlet_id, category_id, name, description, price_paise, availability, customizable, sku |
| `product_options` | id, product_id, name, option_type, price_delta_paise |
| `orders` | id, outlet_id, user_id, status, subtotal_paise, delivery_fee_paise, total_paise, currency, address_snapshot |
| `order_items` | id, order_id, product_id, name_snapshot, unit_price_paise, quantity, options_snapshot |
| `payment_attempts` | id, order_id, provider, external_id, amount_paise, status, raw_reference |
| `delivery_jobs` | id, order_id, provider, external_id, quote_paise, status, tracking_url, rider_snapshot |
| `refunds` | id, order_id, payment_attempt_id, amount_paise, reason, status, provider_reference |
| `order_events` | id, order_id, type, actor_type, actor_id, payload, created_at |
| `webhook_events` | id, provider, external_event_id, signature_valid, processed_at, payload_hash |
| `outbox_messages` | id, topic, aggregate_id, payload, attempts, next_attempt_at, status |

Store money as integer paise. Store an address snapshot on the order because a customer may later edit the saved address. Store product name and price snapshots on order items because the catalog can change after purchase.

## 5. Critical invariants

1. An order total is calculated on the server from current catalog data and the server-returned delivery quote.
2. A client-supplied total is never trusted.
3. A successful payment webhook is processed idempotently using provider event identity.
4. Only one active fulfillment workflow may exist for an order.
5. Delivery booking creation uses an idempotency key derived from the order ID.
6. A refund cannot exceed the captured amount minus previous refunds.
7. Every privileged transition produces an audit event.
8. Secrets are stored in a managed secret store and are never returned to clients.

## 6. API surface

| Endpoint | Purpose |
|---|---|
| `GET /v1/store` | Outlet, hours, service area, and published catalog |
| `POST /v1/quotes/delivery` | Validate location and return delivery estimate |
| `POST /v1/orders` | Create a pending order with server-calculated totals |
| `POST /v1/orders/{id}/checkout` | Create a fresh hosted checkout session |
| `GET /v1/orders/{id}` | Return customer-safe order status |
| `POST /v1/orders/{id}/cancel` | Request cancellation subject to policy |
| `POST /v1/webhooks/payments` | Verify and process payment provider events |
| `POST /v1/webhooks/delivery` | Verify and process delivery events |
| `POST /v1/admin/orders/{id}/accept` | Staff acceptance transition |
| `POST /v1/admin/orders/{id}/ready` | Staff ready-for-pickup transition |
| `POST /v1/admin/orders/{id}/delivery-fallback` | Record manual booking details |
| `POST /v1/admin/orders/{id}/refund` | Create an authorized refund request |

## 7. Payment adapter contract

Define an internal interface with `createCheckout`, `verifyWebhook`, `getPayment`, `createRefund`, and `healthCheck`. The concrete adapter must be replaceable through configuration. The checkout request must include the order ID as metadata, INR currency, customer phone/email, and a return URL. The webhook handler must read the raw request body, verify the provider signature, persist the event before processing, and acknowledge only after idempotent handling.

The provider documentation reviewed for Dodo recommends server-created checkout sessions, fresh single-use checkout URLs, explicit INR/country settings, and fulfillment from verified `payment.succeeded` webhooks rather than browser redirects.[3] Those patterns remain valid even though Dodo is not suitable for physical goods.[1]

## 8. Delivery adapter contract

Define `quote`, `createBooking`, `cancelBooking`, `getStatus`, and `verifyWebhook`. Require provider-side idempotency if available. Normalize provider statuses into the internal state model. Keep a manual booking path with provider name, booking ID, fee, rider details, and tracking link. Never automate screen scraping or rely on an unofficial consumer API.

## 9. Security and privacy

Use HTTPS everywhere. Apply rate limits to authentication, quote, checkout, and webhook endpoints. Validate all input. Use authorization checks on every outlet and order resource. Encrypt backups. Redact payment payloads, OTPs, and access tokens from logs. Retain only the personal data needed to fulfill and support an order. Provide account deletion or data-retention handling consistent with the business's legal advice. Do not expose exact customer addresses to unauthorized staff or other customers.

For delivery OTPs, do not copy or relay a provider OTP unless the provider's official business API explicitly defines that flow. The app should display instructions based on the provider contract and should never request a delivery OTP before the rider and customer are physically at the handover point.

## 10. Reliability and operations

Use the PostgreSQL outbox pattern for side effects. A worker inside the Serverpod service claims pending outbox rows with a lease and retries them with exponential backoff. A payment webhook should persist the event and enqueue fulfillment rather than performing every downstream action synchronously. Retries must use exponential backoff and a dead-letter state. Add a reconciliation job that compares local payment and delivery states against provider APIs at a low frequency. Provide an operator screen for unresolved events.

Backups should be automated and restoration tested before launch. Define recovery objectives for the pilot: restore within four hours and lose no more than fifteen minutes of acknowledged order events. These are engineering targets to validate with the selected hosting provider.

## 11. Performance targets

| Target | Pilot objective |
|---|---:|
| Store page first meaningful render on a normal 4G phone | under 3 seconds |
| Catalog API p95 | under 500 ms |
| Server-side order creation p95 | under 800 ms excluding external quote latency |
| Webhook acknowledgment | under 2 seconds |
| Duplicate fulfillment | zero tolerated incidents |
| Availability | 99.5% monthly for the pilot |

## 12. Testing strategy

Use unit tests for pricing, service-radius validation, state transitions, and refund limits. Use contract tests for payment and delivery adapters. Use integration tests for webhook signature verification and idempotency. Use end-to-end tests on mobile widths and desktop widths. Run payment-provider sandbox tests for successful, failed, pending, cancelled, and duplicate events. Conduct a production-readiness rehearsal using a test outlet before enabling live payments.

## 13. Why this stack is the best fit

The alternatives were deliberately rejected for this MVP. A separate backend language would increase hiring, deployment, and type-contract overhead. A minimal HTTP framework would require more custom authentication, serialization, database conventions, and client plumbing. A microservice design would add operational cost without helping a single-outlet pilot. Serverpod provides the best balance between Dart-only development, typed Flutter integration, PostgreSQL-backed transactional workflows, and a credible path to multi-outlet scale.

## References

[1]: https://docs.dodopayments.com/miscellaneous/merchant-acceptance "Dodo Payments Merchant Acceptance Policy"
[2]: https://docs.dodopayments.com/miscellaneous/faq "Dodo Payments FAQs"
[3]: https://docs.dodopayments.com/developer-resources/integration-guide "Dodo Payments One-time Payments Integration Guide"
[4]: https://docs.dodopayments.com/api-reference/introduction "Dodo Payments API Introduction"
[5]: https://www.rapido.bike/DeliveryPartners "Rapido Delivery Partners"
[6]: https://docs.serverpod.dev/3.1.0/overview "Serverpod 3.1 Overview"
[7]: https://docs.serverpod.dev/3.3.0/get-started/deployment "Serverpod Deployment"
[8]: https://docs.flutter.dev/app-architecture/guide "Flutter App Architecture Guide"
[9]: https://docs.flutter.dev/ui/adaptive-responsive "Flutter Adaptive and Responsive Design"
