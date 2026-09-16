# DS Milk World — Production Specification

**Version:** 3.0 — End-to-end production blueprint with performance plan  
**Prepared:** 16 September 2026  
**Business:** DS Milk World, Kanuru, Vijayawada, Andhra Pradesh  
**Shop coordinates to verify:** `16.4854333, 80.6874703`  
**Primary domain:** `https://dsmilkworld.isroot.in`  
**Current storefront:** `https://ds-milk-world.pages.dev`  
**Current DNS delegation supplied by owner:** `ns1.isroot.in`, `ns2.isroot.in`

## 1. Executive decision

The platform should be built as a **staged, adapter-based ordering system**. The Flutter Web storefront may remain on Cloudflare Pages. A narrow HTTPS backend should own authentication, order creation, payment verification, invoice generation, email delivery, mapping-provider calls, delivery integrations, secrets, webhooks, and audit logs.

The initial pilot can use Cloudflare Workers, D1, and R2 within their free quotas. This is not a promise of permanently free production hosting. Cloudflare documents quotas for Workers, Pages, D1, and R2, and quota exhaustion or plan changes can affect availability.[1] A production system must include quota alerts, backups, export tooling, graceful failure behavior, and a migration path to PostgreSQL.

The revised communication requirement is:

1. **WhatsApp is removed.** No WhatsApp integration is required.
2. **Email and phone are compulsory** before an order can be placed.
3. The invoice is generated and emailed **only after the order reaches `completed`**, not merely when payment succeeds.
4. The invoice, email attempt, payment state, delivery state, and all relevant events are saved in the database.
5. Cashfree is the first payment provider. Its current promotional offer must be treated as conditional and time-limited rather than as a permanent free service.[2]
6. n8n is optional. It cannot run directly inside Cloudflare Workers or Pages because n8n requires a persistent Node.js runtime. If n8n is retained, it must run on a separate persistent host, such as an outlet computer or another server, and may be protected with Cloudflare Tunnel. A native Cloudflare Worker workflow is the recommended free-first implementation.

## 2. Scope

The system covers the customer storefront, product catalog, cart, checkout, address selection, map-based serviceability, Cashfree payment, kitchen operations, delivery state, completed-order invoice generation, email delivery, customer order history, and administrative auditability.

The system does not initially include WhatsApp messaging, a native Rapido API integration without written partner access, self-hosted payment processing, or a guarantee that every component will remain free regardless of usage.

## 3. Current baseline

The existing application already contains a Flutter Web storefront, a staff kitchen console, an order state machine, integer-paise price validation, an OSM map picker, a delivery-radius calculation, a Serverpod backend, and Cloudflare Pages deployment. The existing staff PIN `1979` must not be used in production. Replace it with authenticated staff accounts, role-based authorization, MFA where practical, rate limiting, and an audited credential-rotation process.

The current status document claims that Cloudflare, Neon, Render, and map services can provide a permanently free production platform. This specification corrects that claim. Free software and free tiers reduce cost, but they do not remove infrastructure, payment, email, delivery, compliance, support, backup, or operational costs.

## 4. Recommended architecture

```text
Customer browser / staff browser
              |
              v
Cloudflare Pages: Flutter Web static assets
              |
              v
Cloudflare Worker HTTPS API / backend-for-frontend
              |
      +-------+--------+-------------------+----------------+
      |                |                   |                |
      v                v                   v                v
D1 or PostgreSQL     R2/private media   Cashfree        Email service
catalog/orders       invoice PDFs       web checkout    and email logs
      |                                                        
      +--------------------+----------------------------------+
                           v
                   Outbox/event processor
                           |
             completed-order invoice workflow
                           |
                           v
                 ERPNext/India Compliance
                 or internal invoice module

Optional later adapters:
- licensed map/geocoding/routing provider
- self-hosted OSRM/Valhalla/Pelias
- Rapido, only after a written API agreement
- n8n, only on a separate persistent host
```

The browser must never receive Cashfree secrets, database credentials, R2 credentials, ERPNext credentials, email provider secrets, or delivery-partner credentials. Flutter communicates only with the DS Milk World HTTPS API.

## 5. Hosting and data plan

### 5.1 Pilot deployment

Use Cloudflare Pages for the Flutter Web build. Use a Cloudflare Worker for the API. Use D1 for indexed catalog, customer, address, order, payment, invoice, delivery, email, and audit records. Use a private R2 bucket for invoice PDFs and other private media. Issue short-lived signed URLs from the Worker when a customer or staff member is authorized to download a document.

D1 must be accessed through parameterized queries and bounded, indexed operations. Do not expose D1 directly to the browser. D1’s free limits include daily read/write quotas, a per-database storage limit, and execution constraints; an over-limit ordering path must show a retry/support state rather than silently losing an order.[1]

### 5.2 Production migration gate

Move the authoritative order and payment database to PostgreSQL when any of the following is true:

- Peak-load testing approaches D1 write or concurrency limits.
- The catalog, order history, or audit data approaches the storage ceiling.
- Reporting requires complex joins or must not compete with order writes.
- The business requires defined recovery-point and recovery-time objectives.
- The application needs mature replication, backup, restore, or operational tooling.
- Cloudflare data-location or contractual requirements cannot be satisfied by the selected Cloudflare services.

From the first release, implement a repository interface so the application can use either D1 or PostgreSQL without rewriting business logic. Add an export command for catalog, customers, addresses, orders, order lines, payments, invoices, deliveries, email events, consent records, and audit events. Test restoration regularly.

### 5.3 n8n decision

n8n is open-source/source-available automation software, but it requires a persistent Node.js process and operational resources. It cannot be deployed as a native Cloudflare Worker. Do not describe “n8n hosted on Cloudflare for free” as the architecture.

The recommended invoice workflow is a Cloudflare-native outbox processor. If the business specifically requires n8n’s visual editor, run n8n separately with Docker on an outlet computer or persistent server, expose only a signed webhook through Cloudflare Tunnel, and restrict access with authentication and IP/access policies. The separate host must be backed up, patched, monitored, and kept online. The application must continue to work if n8n is unavailable.

## 6. Required customer data and checkout rules

The checkout form must require:

- Customer full name.
- Valid email address.
- Indian mobile number in normalized E.164-compatible form, such as `+919xxxxxxxxx`.
- Delivery address or pin location.
- Landmark and delivery instructions when needed.
- Consent to receive transactional email for the order.
- Acceptance of the privacy notice and order terms.

Phone and email must be validated on the server, not only in Flutter. A customer cannot create a payable order without both fields. If phone OTP or email verification is later added, the order must remain in `contact_verification_pending` until verification succeeds.

Do not use email or phone as the sole long-term identity key. Store a customer ID and maintain unique normalized contact fields with carefully defined duplicate-account behavior. Do not reveal whether a phone or email already exists to unauthenticated users.

## 7. Order lifecycle

Use explicit server-owned state transitions:

```text
cart
  -> checkout_draft
  -> payment_pending
  -> payment_verified
  -> accepted
  -> preparing
  -> ready
  -> dispatched
  -> delivered
  -> completed
```

Terminal or exceptional states include `payment_failed`, `payment_expired`, `rejected`, `cancelled`, `refund_pending`, `refunded`, `delivery_failed`, and `invoice_failed`.

`completed` is the only state that authorizes invoice generation and email delivery. Payment success alone must not generate the invoice because the shop may reject, cancel, partially fulfil, or refund the order.

The completion operation must be idempotent. Repeating a completion event must not generate a second invoice number, duplicate PDF, or duplicate email. Use a database transaction to record the state transition and an outbox event with a unique key such as `order_completed:{order_id}`.

## 8. Cashfree payment integration

Use Cashfree’s hosted web checkout or documented JavaScript web integration. The backend creates the Cashfree order and returns only a short-lived payment session identifier to Flutter. The client must not create Cashfree orders and must not receive the secret key.[3]

The backend must:

1. Recalculate the order amount from server-side product prices, taxes, delivery fee, discounts, and integer paise.
2. Create a Cashfree order using the server secret.
3. Store the internal order ID and Cashfree order ID before starting checkout.
4. Open the hosted checkout from Flutter Web using the web-compatible integration path.
5. Treat browser redirects and client callbacks as untrusted signals.
6. Verify payment status and webhook signatures server-side using the raw request body and the Cashfree secret.[4]
7. Verify the provider amount and currency against the internal order.
8. Process webhook events idempotently using provider event/payment identifiers.
9. Handle pending, success, failure, expiry, refund, dispute, and duplicate events.
10. Fulfil only after a verified server-side payment result and shop acceptance.

Cashfree’s current ₹20 lakh offer must be recorded as a provider promotion with eligibility and end-date checks, not a permanent system assumption.[2] The platform must support payment fees, GST, refunds, chargebacks, settlement delays, KYC requirements, and future pricing changes.

Never collect or store card number, CVV, PIN, or raw payment credentials. Payment logs must contain transaction identifiers and status, not sensitive card data.

## 9. Invoice strategy

### 9.1 Recommended production option

Use **ERPNext with the India Compliance app** as the accounting and invoice boundary when the business needs GST-aware invoices, credit notes, tax configuration, e-Invoice, e-Way Bill, inventory, and accounting integration. ERPNext is open-source and exposes a REST API, but production deployment still requires a hardened server, database, backups, upgrades, monitoring, and tax configuration.[5]

The invoice adapter must send only the required data:

- Internal order ID.
- Customer name, email, phone, and billing/delivery address.
- Product name, quantity, unit price, discount, tax, and total.
- Payment reference and completion timestamp.
- GSTIN and HSN/SAC fields where applicable.
- Store legal identity, address, GST details, invoice series, and bank/payment details where required.

A qualified tax professional must confirm GST treatment, HSN/SAC, place of supply, invoice numbering, tax rates, credit-note rules, and e-Invoice eligibility. A PDF generated by software does not by itself guarantee statutory compliance.[6]

### 9.2 Lightweight alternative

InvoicePlane is a lighter self-hosted MIT-licensed option for basic PDF and email invoices. Its official project description characterizes it as community-supported hobby software and does not establish India-specific GST functionality or a production-grade integration contract.[7] It may be used for a non-statutory receipt or an early internal pilot only after business and tax review.

Do not select an invoice generator merely because its GitHub repository is free. The selection criteria are API stability, PDF generation, tax fields, invoice numbering, credit notes, auditability, data export, security updates, licensing, and operational support.

## 10. Invoice-generation workflow after completion

The required workflow is:

```text
verified payment + shop acceptance + delivery completion
                         |
                         v
                  mark order completed
                         |
                         v
               insert unique outbox event
                         |
                         v
              create invoice in ERPNext/internal engine
                         |
                         v
             store invoice number and PDF metadata
                         |
                         v
             save private PDF to R2 or object storage
                         |
                         v
                 enqueue invoice email event
                         |
                         v
                  send transactional email
                         |
                         v
             record accepted/delivered/bounced status
```

The invoice worker must use a unique idempotency key. If invoice creation times out, retry by looking up the existing invoice using the internal order ID before creating another one. If email fails, retain the invoice and retry with bounded exponential backoff. A failed email must not roll back a completed order or create a second invoice.

The database must store:

- `invoice_id`.
- `order_id`.
- Invoice number and series.
- Invoice provider and provider invoice ID.
- PDF object key and checksum.
- Invoice status: `pending`, `generated`, `email_pending`, `sent`, `delivered`, `bounced`, `failed`, `cancelled`.
- Generation timestamp and completion timestamp.
- Email provider message ID.
- Retry count, last error code, and next retry time.
- Audit timestamps and actor/system source.

## 11. Email delivery

Cloudflare Email Service can provide native email sending from Workers through a binding, REST API, or SMTP-related interface, subject to its availability, account eligibility, sending limits, domain verification, and current terms.[8] Confirm that the required production sending capability is enabled for the account before making it the sole email provider.

If Cloudflare Email Service is unavailable or unsuitable, use a transactional email provider with a documented API. The provider must support verified sender domains, SPF, DKIM, DMARC, bounce events, rate limits, API keys, and data-processing terms. Email routing/forwarding alone is not an outbound transactional email service.

Email requirements:

- Send from a verified business domain.
- Use a transactional subject such as `Your DS Milk World invoice for order {order_number}`.
- Include order number, invoice number, amount, completion date, shop details, and customer support contact.
- Attach the PDF only when the provider and size limits permit, or include a short-lived authenticated invoice link.
- Never include payment-card data or secrets.
- Do not include an unguessable but permanently public object URL.
- Record accepted, delivered, bounced, and failed statuses.
- Retry transient failures; do not retry permanent invalid-address failures indefinitely.
- Provide a staff resend action that is authenticated, rate-limited, audited, and idempotent.

The email address is compulsory for checkout, but the customer must still be able to view or download the invoice from an authenticated order-history page after completion.

## 12. Maps and location features

Use MapLibre GL JS or a maintained Flutter Web wrapper for map rendering. MapLibre is a renderer, not a hosted map-data service.[9]

Required features:

- Search address to coordinate.
- Coordinate/pin to normalized address.
- Current location with browser permission.
- Manual pin movement.
- Landmark and delivery-instruction input.
- Service-area polygon validation.
- Distance and route estimate from the verified shop coordinate.
- Delivery fee calculation on the server.
- Staff override for ambiguous addresses.
- Stored map-provider name, response version, confidence, timestamp, latitude, longitude, and normalized address.

Do not make `tile.openstreetmap.org`, public Nominatim, public OSRM demo endpoints, or similar public demonstration services a production dependency. OSM data is open, but public infrastructure has usage policies, rate limits, attribution requirements, no guaranteed SLA, and may block abusive or commercial usage.[10] [11]

For the pilot, use a properly licensed OSM-derived hosted provider behind a backend adapter. For a larger self-hosted deployment, evaluate MapLibre with self-hosted vector tiles, Pelias or Nominatim for geocoding, and OSRM or Valhalla for routing. Self-hosting requires compute, storage, OSM data imports, preprocessing, updates, monitoring, and backups.

Do not send customer names, phone numbers, email addresses, or order notes to a geocoding provider. Send only the minimum address or coordinate data required.

The customer must be able to place a pin when geocoding fails. Indian addresses may contain apartment names, Telugu/English variants, landmarks, lanes, and private roads not represented consistently in map data. Do not reject an address solely because forward geocoding failed.

## 13. Rapido parcel delivery

Rapido remains an optional integration. The reviewed official Rapido business pages describe a delivery-partner onboarding and callback process but do not publish a complete public parcel API contract, sandbox, pricing, webhook specification, SLA, or confirmed Kanuru/Vijayawada availability.[12]

Therefore:

- Launch with manual dispatch and a generic delivery adapter.
- Request written confirmation for the exact shop location and delivery area.
- Confirm dairy/perishable acceptance, pickup radius, operating hours, delivery pricing, cancellation policy, liability, rider identity, status callbacks, credentials, and data-processing terms.
- Do not scrape or reverse-engineer the consumer Rapido application.
- Do not make Rapido a hard dependency for order completion.
- Store delivery-provider IDs and statuses separately from order state.
- Support delivery states `requested`, `accepted`, `rider_assigned`, `picked_up`, `delivered`, `failed`, `cancelled`, and `unknown`.

## 14. Database model

Minimum entities:

| Entity | Purpose |
|---|---|
| `customers` | Name, normalized email, normalized phone, account status, timestamps. |
| `customer_consents` | Privacy notice version, transactional email consent, source, timestamp, withdrawal status. |
| `addresses` | Customer-selected address, coordinates, landmark, provider metadata, serviceability result. |
| `products` | SKU, name, category, price in paise, tax configuration, stock status, active status. |
| `orders` | Customer, address snapshot, totals, lifecycle state, idempotency key, timestamps. |
| `order_items` | Product snapshot, quantity, unit price, tax, discount, line total. |
| `payments` | Gateway, provider order/payment IDs, amount, status, webhook event IDs, timestamps. |
| `invoices` | Invoice number, provider ID, PDF metadata, status, error/retry fields. |
| `email_messages` | Recipient, template version, provider ID, status, attempts, failure reason. |
| `deliveries` | Provider, delivery ID, status, fare, rider data if legally permitted, timestamps. |
| `outbox_events` | Unique event key, event type, aggregate ID, payload, attempts, lock, next retry. |
| `audit_events` | Actor, action, entity, request ID, safe metadata, timestamp. |
|

Store snapshots of product price, tax, customer address, and customer contact information on the order so historical invoices remain stable if the customer later edits their profile.

## 15. API surface

Required backend endpoints:

- `POST /api/v1/customers/validate-contact`
- `GET /api/v1/catalog`
- `POST /api/v1/addresses/geocode`
- `POST /api/v1/addresses/reverse-geocode`
- `POST /api/v1/addresses/validate-serviceability`
- `POST /api/v1/orders` with an idempotency key.
- `GET /api/v1/orders/{id}`.
- `POST /api/v1/orders/{id}/payment-session`.
- `POST /api/v1/webhooks/cashfree`.
- `POST /api/v1/staff/orders/{id}/accept`.
- `POST /api/v1/staff/orders/{id}/reject`.
- `POST /api/v1/staff/orders/{id}/mark-ready`.
- `POST /api/v1/staff/orders/{id}/dispatch`.
- `POST /api/v1/staff/orders/{id}/mark-delivered`.
- `POST /api/v1/staff/orders/{id}/complete`.
- `GET /api/v1/orders/{id}/invoice`.
- `POST /api/v1/staff/orders/{id}/invoice/resend`.
- `POST /api/v1/webhooks/email`.
- `POST /api/v1/webhooks/delivery/{provider}`.

All webhook endpoints must validate signatures, enforce payload limits, deduplicate event IDs, and return quickly after durable persistence. Slow invoice or email work belongs in the outbox worker, not in the webhook request.

## 16. Security requirements

Implement the following before public launch:

- Secrets stored in Cloudflare runtime secrets or a dedicated secret manager, never in Flutter code, Git, Wrangler configuration, source maps, or logs.[13]
- HTTPS-only traffic with secure headers and a strict production CORS allowlist.
- Authentication for customers and staff. Use separate staff roles for kitchen, dispatch, catalog, finance, and administrators.
- Replace the shared staff PIN with account credentials and audited sessions.
- Server-side authorization on every staff action.
- Server-side price, stock, tax, delivery-fee, serviceability, and state validation.
- Idempotency on order creation, payment events, completion, invoice generation, email send, and delivery requests.
- HMAC/signature validation for Cashfree, email, delivery, and any automation webhook.
- Rate limiting by IP, account, phone, email, endpoint, and webhook source where appropriate.
- Input validation for coordinates, addresses, quantities, filenames, HTML, PDF metadata, and provider payloads.
- No sensitive payment credentials in logs, analytics, crash reports, or customer support tickets.
- Private R2 objects and short-lived signed downloads.
- Dependency scanning, lockfiles, patch cadence, secret scanning, SAST, and security regression tests.
- Audit records for refunds, order-state overrides, invoice cancellation, resend actions, catalog price changes, and staff permission changes.
- Backups with restore tests and documented retention.
- Incident runbook covering payment mismatch, duplicate webhook, invoice duplication, email bounce, provider outage, database quota exhaustion, credential compromise, and data deletion requests.

## 17. Privacy and Indian compliance

Treat names, email addresses, phone numbers, addresses, precise coordinates, order history, invoices, and delivery data as personal data. Collect the minimum required data. Publish a clear notice describing purposes, processors, retention, user rights, support contact, and withdrawal/deletion processes. Provide English and consider Telugu-language notice and consent for the Vijayawada customer base.

Cloudflare India Regional Services can restrict some HTTPS inspection processing, but it is not a blanket guarantee that all D1 records, R2 objects, logs, metadata, analytics, or support access remain in India. Confirm the selected products, account entitlements, contractual terms, retention, and data-processing arrangements before making a data-locality promise.[14]

Tax, GST, e-Invoice, e-Way Bill, DPDP, payment aggregation, map-data licensing, email, and delivery-provider obligations require professional review for the actual business structure and transaction facts. The implementation team must not hard-code legal assumptions without written business approval.

## 18. Testing and acceptance gates

The platform is not production-ready until all of the following pass:

1. Unit tests cover price calculation, tax calculation, delivery fees, serviceability, state transitions, invoice idempotency, email retry, and refund logic.
2. Integration tests cover Cashfree sandbox order creation, success, failure, pending, expiry, refund, signature failure, duplicate webhook, and amount mismatch.
3. Completion tests prove that payment success does not generate an invoice before delivery completion.
4. Repeated completion events generate one invoice and one logical email message.
5. Invoice-generation failure leaves the order completed and creates a retryable outbox event.
6. Email bounce and provider outage are visible to staff and do not create duplicate invoices.
7. Customer email and phone are mandatory and are validated server-side.
8. Staff authorization prevents kitchen staff from changing payment or tax configuration unless explicitly permitted.
9. Address tests cover forward geocoding, reverse geocoding, pin fallback, browser location denial, service-area boundaries, and inaccurate Indian addresses.
10. Manual delivery dispatch works when Rapido or another provider is unavailable.
11. Backup restore is tested using a new environment.
12. Quota exhaustion is simulated for Worker, D1, R2, email, and provider APIs.
13. Security tests cover secret exposure, CORS misuse, webhook replay, IDOR, SQL injection, XSS, CSRF where applicable, rate-limit bypass, signed-URL expiry, and unauthorized invoice access.
14. Representative Kanuru/Vijayawada addresses are field-tested from the shop coordinate.
15. Production Cashfree onboarding, domain approval, settlement, refund, and support contacts are confirmed.
16. Invoice tax fields, numbering, credit notes, PDF appearance, and business identity are approved by the business owner and tax advisor.

## 19. Delivery phases

### Phase 1 — Correct the existing MVP

Remove WhatsApp code and UI. Make email and phone compulsory. Replace the shared staff PIN. Create the repository and provider-adapter boundaries. Preserve the current storefront and staff workflow while moving all critical validation to the backend.

### Phase 2 — Cashfree hardening

Implement server-created Cashfree orders, web-compatible checkout, webhook signature verification, idempotent payment state transitions, refund handling, amount reconciliation, and sandbox tests. Do not use live keys until merchant KYC and domain approval are complete.

### Phase 3 — Completion-triggered invoice and email

Implement the completed-order outbox event. Integrate ERPNext/India Compliance or the approved invoice engine. Store invoice metadata and private PDF. Integrate Cloudflare Email Service or a verified transactional email provider. Add retry, bounce handling, resend, and customer invoice access.

### Phase 4 — Mapping hardening

Replace public OSM demo dependencies with the selected licensed map stack. Implement provider abstraction, address confidence, pin fallback, service polygon, server-side route/distance, and location privacy controls. Verify the shop location and representative customer addresses.

### Phase 5 — Delivery adapter

Keep manual dispatch as the fallback. Add Rapido only after the partner contract and technical API documentation are received. Implement delivery idempotency, status callbacks, cancellation, failure handling, and reconciliation.

### Phase 6 — Production migration and operations

Add quota monitoring, PostgreSQL migration readiness, backups, restore drills, security scanning, incident response, staff training, tax review, privacy review, and a documented release/rollback process.

## 20. Final implementation rule

The AI or engineering team implementing this specification must never claim that the entire platform is “free forever,” “bug-free,” “fully compliant,” or “guaranteed to run on Cloudflare free hosting.” The correct objective is a **secure, tested, observable, low-cost platform with explicit limits, graceful failure, portability, and human approval for payments, tax, privacy, and delivery operations**.

## References

[1]: https://developers.cloudflare.com/workers/platform/pricing/ "Cloudflare Workers and Pages Functions pricing"
[2]: https://www.cashfree.com/payment-gateway-charges/ "Cashfree payment gateway charges and current promotional offer"
[3]: https://www.cashfree.com/docs/payments/online/web "Cashfree hosted web checkout integration"
[4]: https://www.cashfree.com/docs/payments/online/webhooks/signature-verification "Cashfree webhook signature verification"
[5]: https://github.com/frappe/erpnext "ERPNext open-source ERP repository"
[6]: https://docs.indiacompliance.app/docs/getting-started/introduction "India Compliance application documentation"
[7]: https://invoiceplane.com/ "InvoicePlane self-hosted invoicing application"
[8]: https://developers.cloudflare.com/email-service/get-started/send-emails/ "Cloudflare Email Service sending documentation"
[9]: https://maplibre.org/maplibre-gl-js/docs/ "MapLibre GL JS documentation"
[10]: https://operations.osmfoundation.org/policies/tiles/ "OpenStreetMap tile usage policy"
[11]: https://operations.osmfoundation.org/policies/nominatim/ "Nominatim usage policy"
[12]: https://www.rapido.bike/DeliveryPartners "Rapido delivery partner program"
[13]: https://developers.cloudflare.com/workers/best-practices/workers-best-practices/ "Cloudflare Workers security best practices"
[14]: https://developers.cloudflare.com/data-localization/region-support/ "Cloudflare data localization and regional services"


# Part II — Complete production implementation and setup guide

## 21. Definition of production-ready

“Production-ready” means that the business can accept real orders with controlled risk, recover from provider or infrastructure failures, trace every important event, protect customer data, and operate the system without relying on a developer’s personal machine. It does not mean that software can have zero defects or that third-party providers cannot fail.

The release owner must sign off five separate areas before opening the system to public orders:

| Area | Required sign-off |
|---|---|
| Business operations | Product catalog, prices, opening hours, delivery radius, cancellation policy, refunds, support contacts, and staff roles are approved. |
| Payments | Cashfree production onboarding, domain approval, test payment, verified webhook, refund test, settlement contact, and reconciliation process are approved. |
| Tax and invoices | Store legal identity, GST status, invoice series, tax configuration, HSN/SAC, credit-note process, and PDF template are approved by the business and tax advisor. |
| Security and privacy | Authentication, authorization, secrets, backups, privacy notice, retention, data processor terms, incident response, and vulnerability checks are approved. |
| Operations and continuity | Monitoring, alerts, runbooks, restore drill, manual dispatch, manual invoice fallback, provider outage procedures, and owner/on-call responsibility are approved. |

## 22. Product requirements

### 22.1 Customer storefront

The customer application must present the store identity, service area, opening status, catalog, category navigation, product details, stock status, prices, taxes or tax-inclusive labels, cart, delivery fee, checkout, payment status, order history, invoice access, support contact, privacy notice, refund policy, and terms of ordering.

The storefront must be usable on low-end Android devices, recent Chrome, Safari, Firefox, and Edge. It must support keyboard navigation, visible focus states, sufficient color contrast, responsive layouts, large touch targets, meaningful labels, error messages that do not expose internal details, and a usable offline or poor-network state. The client may cache catalog data, but it must never treat cached prices or stock as authoritative at checkout.

### 22.2 Store configuration

Store staff must be able to configure, subject to role authorization:

- Store name, address, phone, email, logo, GST information, and invoice identity.
- Opening hours, holidays, temporary closure, and order cutoff time.
- Delivery service polygon, maximum distance, base fee, per-kilometre fee, and fee cap.
- Product categories, names, descriptions, images, prices, tax class, SKU, stock, and visibility.
- Preparation-time choices and acceptance limits.
- Cancellation and refund rules.
- Email sender display name and support contact.
- Invoice numbering series and document template.

Every change to prices, taxes, delivery fees, product availability, invoice settings, and staff access must produce an audit event containing the actor, previous value, new value, timestamp, request ID, and reason where required.

### 22.3 Customer order experience

A customer must be able to add products, edit quantities, select or enter an address, move a pin, add a landmark, see the calculated delivery fee, provide email and phone, review the final total, complete Cashfree checkout, view order status, and receive the invoice by email after completion.

The application must not promise an exact delivery time based only on map routing. It may show an estimate with a clear qualifier. Operational staff must be able to override a route or serviceability result after confirming the address by phone.

## 23. Domain and DNS setup for `dsmilkworld.isroot.in`

The supplied domain is `dsmilkworld.isroot.in`, with nameservers `ns1.isroot.in` and `ns2.isroot.in`. The first step is to determine whether `dsmilkworld.isroot.in` is a delegated DNS zone or an ordinary record under a parent zone. The DNS provider or registrar must confirm the authoritative zone and permit the required CNAME/TXT records.

### 23.1 Recommended path: keep IsRoot DNS and attach the subdomain

This path avoids changing nameservers and is usually the least disruptive.

1. In Cloudflare Pages, open the `ds-milk-world` project and add the custom domain `dsmilkworld.isroot.in`.
2. Cloudflare will display the required validation record or target. Follow the exact target shown by the Cloudflare dashboard because project targets can differ.
3. In the IsRoot DNS zone, create the required CNAME record for `dsmilkworld.isroot.in`. Do not add a conflicting A or AAAA record for the same name.
4. Add any Cloudflare-provided TXT validation record exactly as shown.
5. Wait for DNS propagation and click **Verify** in Pages.
6. Confirm that `https://dsmilkworld.isroot.in` returns the storefront, the SPA fallback works on a deep path, and the browser shows a valid certificate.
7. Keep `https://ds-milk-world.pages.dev` available as a rollback URL until the custom domain has passed payment, checkout, map, invoice, and staff-console tests.

Cloudflare Pages supports connecting a custom subdomain by CNAME when the nameservers are not moved to Cloudflare.[15]

### 23.2 Alternative path: delegate a DNS zone to Cloudflare

Use this path only if IsRoot supports the required delegation model and the business wants Cloudflare DNS control.

1. Add the appropriate DNS zone in Cloudflare.
2. Cloudflare will provide nameservers. Do not assume the nameservers will be `ns1.isroot.in` or `ns2.isroot.in`; use the nameservers shown by the Cloudflare dashboard.
3. At IsRoot, update the delegation only for the zone being transferred, if supported. Do not accidentally change the parent domain’s nameservers unless the owner intends to move the entire domain.
4. Wait for authoritative delegation to update.
5. Add the Pages custom domain and Worker custom domains in Cloudflare.
6. Confirm DNSSEC status, TLS certificate issuance, email records, and rollback ownership before deleting old records.

Do not change nameservers blindly. A nameserver change can interrupt the website, email, verification records, and other services. The exact zone hierarchy must be confirmed first.

### 23.3 Recommended hostnames

Use a single-origin design where possible:

| Hostname | Purpose |
|---|---|
| `dsmilkworld.isroot.in` | Customer storefront and public landing page. |
| `api.dsmilkworld.isroot.in` | Worker API, webhooks, and signed application endpoints. |
| `staff.dsmilkworld.isroot.in` | Optional staff console hostname; require authentication and preferably an access policy. |
| `status.dsmilkworld.isroot.in` | Optional public service-status page; never expose internal logs. |
| `mail.dsmilkworld.isroot.in` | Optional email sending domain or tracking domain, only if supported by the selected provider. |

The customer browser should call `https://api.dsmilkworld.isroot.in` over HTTPS. Configure an exact production CORS allowlist containing only the storefront and staff origins. Do not use `*` when authenticated or personal-data requests are involved.

### 23.4 DNS verification checklist

Run and record the following checks after DNS changes:

```bash
# DNS answers
 dig +short dsmilkworld.isroot.in CNAME
 dig +short api.dsmilkworld.isroot.in CNAME
 dig +short dsmilkworld.isroot.in A
 dig +short dsmilkworld.isroot.in AAAA

# Authoritative nameservers
 dig +short dsmilkworld.isroot.in NS
 dig +trace dsmilkworld.isroot.in

# HTTPS headers and certificate
 curl -I https://dsmilkworld.isroot.in/
 curl -I https://api.dsmilkworld.isroot.in/health
```

The health endpoint must return a minimal status such as `{"status":"ok","version":"..."}` and must not disclose secrets, database connection strings, provider tokens, stack traces, or customer data.

## 24. Environment separation

Create four environments:

- **Local development:** synthetic data, local or sandbox provider credentials, no production customer data.
- **Preview/staging:** separate Cloudflare project or Worker environment, separate D1 database and R2 bucket, Cashfree sandbox, test email recipients, synthetic customer data.
- **Production:** production domain, production databases and storage, production Cashfree keys, verified email sender, restricted staff access.
- **Disaster recovery:** isolated restore target, never used for normal writes, with documented restore credentials and procedures.

Every environment must have separate:

- Database and storage identifiers.
- Cashfree app ID and secret.
- Email credentials.
- ERPNext credentials.
- Session signing keys.
- Webhook signing secrets.
- Encryption keys.
- Staff accounts.
- Allowed CORS origins.
- Alert destinations.

Never copy production data into staging without documented minimization or anonymization. Never test a refund, invoice cancellation, customer email, or delivery request against production unless the exact action is approved under a runbook.

## 25. Repository and code organization

The codebase should be organized into clearly separated modules:

```text
/apps/storefront_flutter/
/apps/staff_flutter/
/services/api_worker/
/packages/domain/
/packages/contracts/
/packages/payment_adapter/
/packages/invoice_adapter/
/packages/email_adapter/
/packages/maps_adapter/
/packages/delivery_adapter/
/packages/auth/
/packages/security/
/infra/cloudflare/
/infra/erpnext/
/infra/email/
/db/migrations/
/db/seeds/
/tests/unit/
/tests/integration/
/tests/e2e/
/docs/runbooks/
```

The domain module must contain business rules independent of Cloudflare, Cashfree, ERPNext, email, maps, and Rapido. Adapters translate external provider requests and responses into stable internal contracts. Provider-specific payloads must not leak into Flutter screens or core order logic.

Every external request must have a request ID, timeout, bounded retry policy, safe error mapping, and structured logging. Retrying a payment capture, refund, invoice creation, or delivery booking requires provider-specific idempotency protection.

## 26. Authentication and authorization design

### 26.1 Customer access

The first launch may support guest checkout with an order tracking link only if the link is a high-entropy, short-lived capability token and the user must also provide a second factor such as email or phone confirmation. A stronger design uses passwordless email or phone OTP, but OTP introduces a messaging provider, rate limits, abuse controls, and additional cost.

Do not put order IDs alone in URLs. A customer invoice link must use an unguessable token, expire, be revocable, and be checked against the order’s customer contact or authenticated account.

### 26.2 Staff access

Create named staff accounts. At minimum, define these roles:

| Role | Permissions |
|---|---|
| Kitchen | View paid orders, accept/reject, set preparation state, mark ready. No payment settings or invoice configuration. |
| Dispatch | View ready orders, assign delivery, update dispatch and delivery states. No catalog pricing or payment secrets. |
| Catalog manager | Edit products, prices, availability, images, and categories. No refunds or staff access. |
| Finance | View payments, refunds, invoices, email status, reconciliation, and accounting exports. |
| Administrator | Manage roles, configuration, integrations, backups, and security settings. Use sparingly. |
| Auditor/read-only | View operational and audit records without mutation privileges. |

Require reauthentication for refunds, invoice cancellation, staff-role changes, secret rotation, and destructive data operations. Record every privileged action.

## 27. Observability and monitoring

Implement structured JSON logs with:

- Timestamp in UTC.
- Request ID and trace ID.
- Environment and application version.
- Route and HTTP status.
- Actor type and safe actor ID.
- Order ID or aggregate ID where relevant.
- Provider and provider event ID where relevant.
- Latency and retry count.
- Safe error code.

Never log full payment secrets, authorization headers, OTPs, raw card data, invoice PDFs, full addresses, or unnecessary phone/email values. Mask personal fields in operational dashboards.

Track these metrics:

- Successful and failed order creation.
- Payment session creation and verified payment rate.
- Payment webhook delay and signature failures.
- Orders stuck in each state.
- Order rejection and refund rate.
- Average preparation time.
- Delivery acceptance and failure rate.
- Completion-to-invoice latency.
- Invoice generation failures and duplicate-prevention events.
- Email accepted, delivered, bounced, and failed counts.
- Map provider latency, error rate, and quota usage.
- Worker errors and execution time.
- D1 reads, writes, storage, and quota consumption.
- R2 operations and storage.
- Authentication failures and staff privilege changes.

Alerts must notify the operator when payments are verified but orders are not accepted, orders are completed but invoices are pending, email failure exceeds a threshold, a webhook signature fails repeatedly, quota usage approaches a configured threshold, backups fail, or provider health degrades.

## 28. Backup and disaster recovery

Define targets before launch:

- **RPO:** maximum acceptable lost data, for example 15 minutes for order/payment metadata.
- **RTO:** maximum acceptable recovery time, for example 4 hours for a pilot.
- **Retention:** daily, weekly, and monthly retention periods approved by the business and privacy policy.

Back up:

- Database records and schema migrations.
- R2 invoice PDFs and product images.
- Cloudflare configuration and environment manifests, excluding secret values.
- ERPNext database and private files.
- Invoice numbering and tax configuration.
- Provider reconciliation exports.
- Audit logs.

Use encrypted backups with restricted access and at least one copy isolated from the primary account. Test restore monthly in a clean environment. A backup that has never been restored is not evidence of recoverability.

The restore runbook must cover DNS, Pages, Worker, database, R2, ERPNext, Cashfree webhook configuration, email domain verification, staff accounts, and reconciliation of payments and orders created around the outage.

## 29. Reconciliation and financial controls

Daily reconciliation must compare:

1. Internal orders marked paid.
2. Cashfree successful payments.
3. Cashfree refunds and disputes.
4. Internal refunds.
5. Completed orders.
6. Generated invoices.
7. ERPNext submitted invoices and credit notes.
8. Settlement reports and bank receipts.

Differences must produce an actionable exception queue. Staff must never “fix” totals by editing historical orders. Use adjustment records, refunds, credit notes, or controlled administrative corrections with reason and approval.

The platform must not mark a payment as successful based on an uploaded screenshot, customer claim, browser callback, or staff assumption. Only verified provider status tied to the internal order can authorize the payment transition.

## 30. Email domain setup

For the selected outbound email service:

1. Create a dedicated sender such as `orders@dsmilkworld.isroot.in` or `billing@dsmilkworld.isroot.in`.
2. Verify domain ownership using the provider’s required TXT record.
3. Publish SPF according to the provider’s exact instruction. Do not create multiple conflicting SPF records.
4. Publish DKIM records provided by the email service.
5. Publish a DMARC record, initially with a monitoring policy such as `p=none`, review reports, and then tighten the policy after confirming all legitimate senders.
6. Configure bounce and complaint webhooks.
7. Test delivery to Gmail, Outlook, Yahoo, and at least one Indian consumer mailbox.
8. Confirm that invoice attachments or authenticated links are not blocked.
9. Keep marketing mail separate from transactional mail. Do not use invoice messages for promotions without the required consent and template review.

Cloudflare Email Service requires domain configuration before email sending, and its current availability, limits, and account terms must be checked during setup.[16] Email Routing is not automatically an outbound transactional email service.

## 31. Security verification plan

Use OWASP ASVS as the baseline security checklist.[17] At minimum, perform:

- Dependency and container vulnerability scanning.
- Secret scanning in Git history and CI artifacts.
- Static analysis for Flutter/Dart, TypeScript/JavaScript, SQL, and infrastructure files.
- Dynamic testing of authentication, authorization, CORS, CSRF, XSS, injection, path traversal, SSRF, replay, and rate limits.
- Manual test of invoice access with another customer’s order ID and token.
- Manual test of staff role separation.
- Payment webhook signature and replay tests.
- Malformed provider payload tests.
- R2 signed-URL expiry and origin tests.
- Database backup confidentiality tests.
- Production configuration review before each release.

A high-risk finding involving payment authorization, staff access, secret exposure, invoice access, customer data exposure, or webhook verification blocks production release.

## 32. Release and rollback procedure

Every release must have a version, migration plan, test result, owner, change summary, rollback plan, and monitoring window. Database migrations must be backward-compatible with the previous application version unless a controlled maintenance window is approved.

Release sequence:

1. Merge code only after review and automated checks.
2. Deploy to staging.
3. Run unit, integration, smoke, accessibility, and payment-sandbox tests.
4. Run a database migration dry run.
5. Deploy the Worker and frontend to preview.
6. Verify health, API contract, checkout, map, staff, invoice, and email flows.
7. Deploy to production during a low-order period.
8. Run a synthetic order that uses Cashfree sandbox only in staging; use a non-financial production smoke check in production.
9. Monitor errors, order states, payment webhooks, invoice queue, and email queue.
10. Roll back frontend and Worker code if required. Never blindly roll back a database migration; use a forward fix or a tested restore plan.

## 33. Manual fallback procedures

The business must be able to continue safely when a provider fails.

### Payment provider outage

Show checkout unavailable, preserve the cart locally, do not accept screenshots as payment proof, and record the incident. Resume only after payment status verification is healthy.

### Invoice engine outage

Complete the order if delivery is complete, create an `invoice_pending` outbox record, and notify finance. Do not generate a second invoice manually without checking the provider by internal order ID.

### Email outage

Keep the invoice private in storage, show it in authenticated order history, queue retry, and allow finance to resend after the provider recovers.

### Map outage

Allow manual address entry, pin placement, landmark, phone confirmation, and staff serviceability override. Do not silently use a stale route or charge an unverified fee.

### Rapido or delivery-provider outage

Use manual dispatch. Record the actual rider/delivery reference only when legally and operationally appropriate. Do not block a completed order’s invoice merely because a later delivery status provider is unavailable.

### Cloudflare quota or account outage

Use the documented rollback or migration plan, preserve the last exported order/payment data, and communicate through the approved support channel. Quota exhaustion must not cause duplicate payment attempts.

## 34. Required business inputs before final implementation

The engineering build cannot safely finalize the following without business decisions:

- Legal business name, proprietor/company name, billing address, and support contacts.
- GST registration status and GSTIN, if applicable.
- Tax treatment and HSN/SAC for each product category.
- Invoice numbering series and financial-year policy.
- Store opening hours and holidays.
- Delivery service polygon and fee policy.
- Product catalog, stock, prices, and images.
- Refund, cancellation, replacement, and damaged-product policy.
- Customer privacy notice and terms.
- Staff names, roles, and emergency access owner.
- Cashfree production account and approved domain.
- Email provider choice and verified sending domain.
- Whether ERPNext will be self-hosted or managed.
- Whether n8n is actually required after reviewing the native outbox workflow.
- Rapido partnership status and official technical documentation.
- Backup owner, alert recipient, and incident-response contact.

## 35. Exact implementation checklist

### Foundation

- [ ] Create staging and production Cloudflare projects.
- [ ] Connect `dsmilkworld.isroot.in` to Pages.
- [ ] Create `api.dsmilkworld.isroot.in` Worker custom domain.
- [ ] Verify DNS, TLS, CORS, SPA fallback, and health checks.
- [ ] Create separate D1 databases and R2 buckets for staging and production.
- [ ] Configure runtime secrets and access policy.
- [ ] Establish migrations, seeds, export, and backup jobs.

### Customer and staff

- [ ] Remove production use of PIN `1979`.
- [ ] Create named staff accounts and roles.
- [ ] Implement mandatory phone and email validation.
- [ ] Implement privacy notice and transactional-email consent.
- [ ] Implement authenticated order history and invoice access.
- [ ] Implement accessibility and responsive UI checks.

### Payments

- [ ] Configure Cashfree sandbox.
- [ ] Implement server order creation.
- [ ] Implement web checkout for Flutter Web.
- [ ] Implement signature verification and provider lookup.
- [ ] Implement idempotent webhook processing.
- [ ] Test failures, retries, refunds, expiry, amount mismatch, and duplicate events.
- [ ] Complete production KYC, domain whitelisting, and live-key setup.

### Invoices and email

- [ ] Choose ERPNext/India Compliance or an approved lightweight invoice engine.
- [ ] Validate tax configuration and invoice template.
- [ ] Implement completion outbox event.
- [ ] Implement invoice idempotency by internal order ID.
- [ ] Store PDF privately and record checksum.
- [ ] Configure sender domain, SPF, DKIM, and DMARC.
- [ ] Implement email API, webhook status, retry, bounce, and resend.
- [ ] Test invoice generation only after `completed`.

### Maps and delivery

- [ ] Verify the shop coordinate in the field.
- [ ] Select a licensed map/geocoding/routing provider.
- [ ] Implement provider adapter and backend-only calls.
- [ ] Implement pin fallback and staff override.
- [ ] Test Kanuru/Vijayawada addresses in English and Telugu variants.
- [ ] Keep manual dispatch operational.
- [ ] Add Rapido only after official contract/API documentation.

### Security and operations

- [ ] Complete OWASP ASVS-based review.
- [ ] Run secret scanning, dependency scanning, SAST, DAST, and access-control tests.
- [ ] Configure logs, metrics, alerts, and dashboards.
- [ ] Complete backup and restore drill.
- [ ] Complete payment, invoice, email, map, and delivery outage drills.
- [ ] Document incident-response contacts and escalation.
- [ ] Obtain business, tax, privacy, and production release sign-off.

## 36. References added for the domain and production setup

[15]: https://developers.cloudflare.com/pages/configuration/custom-domains/ "Cloudflare Pages custom domains"
[16]: https://developers.cloudflare.com/email-service/configuration/domains/ "Cloudflare Email Service domain configuration"
[17]: https://owasp.org/www-project-application-security-verification-standard/ "OWASP Application Security Verification Standard"

## 37. Final architecture recommendation

The best product for DS Milk World is not a collection of free tools connected directly from the browser. It is a controlled ordering platform with a small and stable internal domain model, a server-side provider adapter layer, explicit order and payment state machines, a completion-triggered invoice outbox, authenticated email delivery, private document storage, map-provider switching, manual delivery fallback, and tested recovery procedures.

Use Cloudflare for the storefront, edge delivery, HTTPS, DNS integration, and a narrow API where its quotas are appropriate. Use D1 only for the initial pilot if its limits are acceptable. Keep a clean path to PostgreSQL. Use Cashfree’s hosted checkout without storing card data. Use ERPNext and India Compliance when statutory invoice/accounting requirements justify it. Use native Worker-based outbox processing instead of forcing n8n into a runtime it does not support. Treat maps, email, payment processing, and delivery as external dependencies with explicit contracts and failure handling.

The supplied domain `dsmilkworld.isroot.in` can be used as the customer-facing production domain while keeping IsRoot DNS, provided the Pages custom-domain CNAME and validation records are created correctly. Do not change nameservers until the DNS zone hierarchy is confirmed and a rollback plan exists.


# Part III — Performance and loading-speed remediation

## 38. Performance problem statement

The application currently appears to spend too much time loading before it becomes useful. The likely causes are a large Flutter Web JavaScript bundle, eager loading of staff, map, payment, catalog, and administration features, oversized images, unnecessary network requests, slow API/database calls, and a loading screen that hides rather than measures the actual bottleneck.

The performance goal is not merely to show a fast splash animation. The goal is to make the storefront useful quickly on a mid-range Android phone using a realistic mobile network. The first screen must show meaningful store content while non-critical features load in the background.

The performance work must be measurement-driven. Do not claim “0 ms hydration” unless a real browser measurement proves it. A branded splash screen is perceived performance, not application readiness.

## 39. Performance targets

Measure production and staging on a representative mid-range Android device, Chrome, a throttled Fast 3G profile, and a normal Indian 4G connection. Record cold-cache and warm-cache results.

| Metric | Target for customer storefront | Release blocker |
|---|---:|---:|
| HTML/document response time | Under 400 ms at the edge | Over 1,000 ms repeatedly |
| Time to first meaningful content | Under 2.5 s on Fast 3G | Over 4 s |
| Largest Contentful Paint | Under 2.5 s on a representative mobile test | Over 4 s |
| Cumulative Layout Shift | Below 0.10 | Above 0.25 |
| Interaction to Next Paint | Below 200 ms for primary interactions | Above 500 ms |
| First meaningful catalog data | Under 2.5 s warm cache, under 4 s cold cache | Catalog absent after 5 s without explanation |
| Initial JavaScript transfer | Prefer under 1.5 MB compressed | Over 3 MB compressed without documented reason |
| Initial image transfer | Prefer under 300 KB compressed | Over 800 KB before interaction |
| Time to interactive checkout controls | Under 3 s warm cache | Over 5 s |
| Map load | Deferred until requested; first useful map under 3 s after opening | Map blocks storefront startup |
| API p95 for catalog | Under 300 ms at edge/backend | Over 1 s |
| API p95 for checkout draft | Under 500 ms excluding Cashfree | Over 1.5 s |
| API p95 for order status | Under 500 ms | Over 1.5 s |

Targets must be validated with real measurements. If a third-party map, payment, email, or delivery provider is slow, the customer storefront must remain usable and show a clear status instead of blocking the entire app.

## 40. Immediate diagnosis procedure

Before changing code, capture a baseline:

1. Open the production domain in Chrome DevTools with cache disabled.
2. Record the Network waterfall from navigation through catalog readiness.
3. Record JavaScript bundle sizes and compression.
4. Record the largest images and fonts.
5. Record long tasks on the main thread.
6. Record API request count, request ordering, latency, and duplicate requests.
7. Test first load, refresh, back navigation, and slow-network behavior.
8. Run Lighthouse or PageSpeed Insights on the production hostname.
9. Test the Flutter Web build using the browser performance timeline.
10. Repeat on the actual Android device used by the business.

Create a short baseline report containing:

- Total transferred bytes.
- Compressed and uncompressed JavaScript size.
- Number of requests before the storefront is usable.
- Time to first catalog item.
- Time to first image.
- Time to first user interaction.
- Map and API contribution to startup time.
- Top five long tasks.
- Top five largest assets.
- Top five slowest API queries.

Do not optimize a guessed bottleneck. Re-run the baseline after each optimization group and keep a comparison table in the repository.

## 41. Flutter Web startup plan

Flutter’s current performance guidance recommends tree shaking, deferred loading, and perceived-performance improvements for Flutter Web applications.[18] Apply the following changes.

### 41.1 Build in release mode

Deploy only a release build. Never deploy `flutter run`, debug assets, development source maps, verbose logging, or unoptimized images to production.

Use a repeatable build command such as:

```bash
flutter clean
flutter pub get
flutter build web --release --base-href=/ \
  --dart-define=APP_ENV=production
```

Confirm that the deployment directory contains only the production web assets, the SPA fallback file, and required metadata. Remove APK files, test fixtures, unused assets, generated debug files, and accidental source archives from the Pages artifact.

### 41.2 Reduce initial feature loading

The first route must load only what is needed to display:

- Brand and store status.
- Product categories.
- First page of active products.
- Cart summary.
- Basic store contact and opening hours.

Do not eagerly initialize the following during startup:

- Map JavaScript and map tiles.
- Staff console.
- Cashfree SDK.
- Invoice viewer.
- Delivery tracking.
- Admin/catalog editor.
- Order-history data for anonymous users.
- Analytics libraries that are not needed for core operation.

Load these features only when the user navigates to the relevant screen or action. Evaluate Dart deferred imports for genuinely large and independent features, especially staff console, map, payment, and invoice modules. Verify that deferred loading actually produces separate chunks in the deployed build; an import that remains in the initial bundle has not solved the problem.

### 41.3 Reduce Flutter rendering work

- Avoid rebuilding the complete storefront when one cart quantity changes.
- Split large widgets into localized stateful sections.
- Use selectors or narrowly scoped listeners instead of listening to the entire cart/provider tree.
- Use stable keys for product lists.
- Paginate or progressively reveal long product lists.
- Avoid expensive shadows, blur effects, and large animated backgrounds on low-end phones.
- Keep the initial animation short and non-blocking.
- Use skeleton placeholders with fixed dimensions to prevent layout shift.
- Do not render all 116 catalog items at once if only a subset is visible.
- Dispose controllers, timers, map instances, and subscriptions when routes leave the screen.
- Avoid repeated `setState` calls during startup and map movement.

### 41.4 Service worker and caching

Use the Flutter service worker only after verifying cache invalidation on every deployment. Version all static assets and ensure an old service worker cannot keep serving stale application code after a critical release.

The service worker must not cache personalized order data, payment responses, staff data, invoices, or authenticated API responses. It may cache immutable versioned static assets and public catalog responses under controlled rules.

Provide a visible update/reload path when a new application version is available. Never silently run a stale payment or checkout bundle after an API contract change.

## 42. Asset optimization

### 42.1 Product images

The catalog must not load original high-resolution photos directly. Generate and store at least:

- Thumbnail for category cards.
- Medium image for product detail.
- Optional high-resolution image only after explicit zoom.

Convert photographs to WebP or AVIF where browser compatibility permits. Strip unnecessary metadata. Keep the first viewport image small and use `width`, `height`, and aspect-ratio placeholders to prevent layout shift.

Recommended image budgets:

- Category thumbnail: 20–60 KB.
- Product card image: 40–120 KB.
- Product detail image: 100–250 KB.
- Store logo: under 30 KB.
- Hero image: under 150 KB and never required for checkout.

Store private or controlled images in R2. Use a Worker or build pipeline to select the correct size. Do not use a single multi-megabyte image for every device.

### 42.2 Fonts and icons

Use a system font stack where possible. If a custom font is required, load only the weights used by the UI, use `font-display: swap`, subset the font, and avoid blocking the first render. Prefer SVG icons or a small icon subset over a full icon font.

### 42.3 Asset audit

Add a CI check that fails or warns when:

- The compressed initial JavaScript bundle exceeds the approved budget.
- A new image exceeds its category budget.
- A font or video is added to the initial route.
- A cache-busting hash is missing from an immutable asset.

## 43. Frontend network strategy

The storefront must use a small number of predictable requests.

### 43.1 Startup request budget

Before the first catalog is usable, target no more than:

1. One HTML/document request.
2. Required Flutter/bootstrap assets.
3. One catalog/configuration API request.
4. Optional one image manifest request if not included in the catalog response.

Do not make separate startup requests for every category, product, image, configuration field, analytics event, user profile, and store setting. Combine small public configuration into a versioned bootstrap response.

### 43.2 Catalog API

The catalog endpoint must:

- Return only active products and required fields.
- Support category and pagination parameters.
- Return image URLs or signed image metadata without exposing storage credentials.
- Include an ETag or version identifier.
- Use a short cache lifetime for public catalog data.
- Use stale-while-revalidate behavior where safe.
- Avoid returning internal stock notes, supplier data, audit data, or staff-only fields.

The client should render cached catalog data immediately when available, then revalidate in the background. If the network fails, show the last known catalog with a clear freshness message and disable purchase of items whose current stock cannot be verified.

### 43.3 Request deduplication and cancellation

Cancel obsolete search, geocoding, map, and catalog requests. Debounce address search and never send every keystroke to a public geocoder. Deduplicate simultaneous catalog and configuration requests. Use request IDs to identify duplicate calls in logs.

### 43.4 API timeouts and retries

Use short per-provider timeouts. Retry only idempotent reads and outbox events with bounded exponential backoff and jitter. Never automatically retry a payment creation, refund, invoice submission, or delivery booking unless the provider’s idempotency mechanism is active.

## 44. Cloudflare delivery optimization

Cloudflare can deliver compressed content using Brotli and other compression mechanisms.[19] Configure the production zone and Pages deployment to:

- Serve Brotli when supported and fall back safely.
- Cache immutable hashed assets for a long duration.
- Use `Cache-Control: public, max-age=31536000, immutable` only for content whose filenames change when content changes.
- Use short cache lifetimes or revalidation for `index.html` so deployments become visible promptly.
- Never cache authenticated API responses or personal data at the public edge.
- Add `ETag` or `Last-Modified` for revalidation where appropriate.
- Avoid cache rules that cache Cashfree checkout responses, webhook endpoints, staff routes, or invoice downloads.
- Configure HTML fallback without turning API 404 responses into the Flutter index page.

Recommended header pattern:

```text
/index.html
Cache-Control: no-cache, must-revalidate

/assets/<hashed-file>
Cache-Control: public, max-age=31536000, immutable

/api/*
Cache-Control: no-store

/public-catalog-response
Cache-Control: public, max-age=30, stale-while-revalidate=120

/private-invoices/*
Cache-Control: private, no-store
```

Verify headers with `curl -I` and confirm the browser does not cache private data.

## 45. Map performance plan

The map must never block initial storefront rendering. Load map code only when the customer opens address selection or delivery tracking.

When the map opens:

- Render a lightweight placeholder immediately.
- Load the map renderer asynchronously.
- Center on the verified shop coordinate without downloading a full route first.
- Load tiles only for the visible viewport.
- Debounce map movement and pin changes.
- Request geocoding only after the user pauses or confirms the pin.
- Cache permitted provider responses carefully.
- Avoid loading satellite imagery or unnecessary layers.
- Use a static map preview when the full interactive map is not required.
- Provide manual address and landmark entry when map loading fails.

Map tiles, geocoding, and routing must be served through a provider with terms suitable for the business. Public OSM endpoints are not a performance or availability guarantee.

## 46. API and database performance

### 46.1 Worker API

Keep the Worker API thin and avoid serial calls when independent reads can be combined. Set provider timeouts and return a useful response before optional enrichments complete. Do not generate PDFs, call an invoice service, or send email synchronously in an order-completion request.

The completion endpoint should persist the completion transition and outbox event quickly. Invoice generation and email must run asynchronously. The customer should see “Order completed — invoice is being prepared” rather than waiting for ERPNext or email providers.

### 46.2 D1 and PostgreSQL

Add indexes for all frequent filters and joins, including order customer/state/created time, payment provider ID, webhook event ID, outbox state/next retry time, invoice order ID, email provider ID, product category/active status, and delivery provider ID.

Avoid `SELECT *`, unbounded order history, unbounded audit logs, leading-wildcard searches, and repeated per-product queries. Use pagination with stable cursors. Keep reporting queries off the transactional path.

Measure query latency and rows scanned. A query that is fast with 116 products may become slow after months of orders; test with realistic data volume.

### 46.3 Connection and payload control

Return only fields required by the screen. Compress JSON where applicable. Use pagination for order history and catalog. Avoid embedding large product images or invoice PDFs in JSON. Use signed URLs for files.

## 47. Perceived-performance design

While the real performance work is being completed, improve the customer experience without disguising failures:

- Show the product shell and store identity immediately.
- Show skeleton cards with fixed dimensions.
- Display a useful catalog cache if available.
- Show a progress state for checkout steps.
- Keep cart state locally, but revalidate prices before payment.
- Use optimistic cart quantity updates with rollback on failure.
- Show “Preparing map…” only in the map screen, not on the storefront.
- Show a clear offline banner and retry action.
- Preserve form input when a network request fails.
- Avoid indefinite spinners; every asynchronous state must have success, empty, error, and retry states.

## 48. Performance testing in CI and production

Add automated performance checks to the release pipeline:

- Bundle-size report and budget enforcement.
- Lighthouse mobile run against staging.
- Cold-cache and warm-cache page load tests.
- Catalog API p50/p95 latency tests.
- Database query plan and seeded-volume tests.
- Image-size and format checks.
- Map lazy-load test proving the map is absent from the initial route.
- Checkout test proving Cashfree scripts are not loaded before checkout if the selected integration allows lazy loading.
- Memory and long-task checks on a representative mobile browser.

Use Core Web Vitals as the public quality signal; web.dev and Google document LCP, CLS, and interaction responsiveness as key user-facing measurements.[20] Monitor real-user performance with privacy-preserving telemetry. Do not record full addresses, phone numbers, emails, invoice contents, or payment values in analytics.

## 49. Performance acceptance gates

The speed remediation is complete only when:

1. The initial storefront does not load staff console, map, invoice, delivery, or admin code eagerly.
2. The first catalog data request is visible and measurable.
3. The initial compressed JavaScript and image budgets pass.
4. Product images use responsive sizes and do not cause layout shift.
5. The map does not block storefront readiness.
6. API calls are deduplicated and authenticated requests are not publicly cached.
7. D1/PostgreSQL queries use indexes and bounded pagination.
8. Invoice generation and email do not block order completion.
9. Lighthouse and real-device tests meet the target thresholds.
10. A slow or failed map, email, invoice, payment, or delivery dependency leaves the rest of the storefront usable.
11. The performance baseline is stored and compared for every release.
12. Production monitoring alerts when the p95 target is exceeded.

## 50. Recommended implementation order for the speed fix

### Sprint A — Measure and remove obvious waste

Capture the baseline. Remove debug assets and unused files. Confirm release build. Inspect the initial bundle, network waterfall, duplicate API calls, largest images, and long tasks.

### Sprint B — Make the storefront progressive

Split customer and staff routes. Lazy-load map, payment, invoice, delivery, and administration. Render a minimal catalog shell and fetch only active products. Add skeletons, fixed image dimensions, and retry states.

### Sprint C — Optimize assets and caching

Resize product images, convert formats, subset fonts, configure Brotli and cache headers, verify service-worker invalidation, and add bundle/image budgets to CI.

### Sprint D — Optimize APIs and database

Add indexes, pagination, ETags, request deduplication, timeouts, query limits, cache-safe catalog responses, and asynchronous outbox processing for invoices and email.

### Sprint E — Validate on real devices

Test cold and warm loads on a mid-range Android phone, Fast 3G, 4G, and desktop. Compare against the target table. Fix regressions before adding new features.

## 51. Performance references

[18]: https://flutter.dev/blog/best-practices-for-optimizing-flutter-web-loading-speed "Flutter Web loading-speed best practices"
[19]: https://developers.cloudflare.com/speed/optimization/content/compression/ "Cloudflare content compression"
[20]: https://web.dev/explore/learn-core-web-vitals "web.dev Core Web Vitals guidance"
