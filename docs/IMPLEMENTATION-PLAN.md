# Implementation Plan — DS Milk World Direct Ordering MVP

## 1. Final stack and delivery approach

The repository should contain one Flutter/Dart workspace with a Flutter client and a Serverpod 3.x Dart server. Keep shared domain models and serialization in the generated Serverpod contract rather than duplicating request models by hand. Use PostgreSQL migrations managed with the Serverpod database workflow. Deploy the server as a Docker image and the Flutter web build as static HTTPS assets.

Build in vertical slices so every milestone produces a testable end-to-end capability.

Do not build all screens first and postpone integrations. The first usable slice should complete a sandbox order from catalog to payment webhook to staff queue.

## 2. Milestones

| Milestone | Deliverable | Exit condition |
|---|---|---|
| M0 — decisions | Confirm outlet details, service radius, payment gateway eligibility, delivery-provider business/API terms | Written vendor answers and approved pilot policy |
| M1 — foundation | Flutter/Dart workspace, Serverpod 3.x service, environments, PostgreSQL migrations, authentication, logging | Test deployment and health checks work |
| M2 — catalog | Import 79 supplied products, category browsing, staff catalog editing | Shop verifies published catalog |
| M3 — cart and address | Cart, map/location input, service-radius validation, delivery quote abstraction | Test order total is correct |
| M4 — payment | Hosted checkout adapter, webhook verification, idempotency, payment states | Sandbox success/failure/pending tests pass |
| M5 — shop operations | Staff queue, accept/reject, prepare, ready, audit events | Shop can operate without database access |
| M6 — delivery | Approved provider quote/booking/status adapter plus manual fallback | Test delivery lifecycle is visible |
| M7 — support and hardening | Refund cases, notifications, monitoring, backups, accessibility, security review | Production checklist complete |
| M8 — live pilot | Small-radius launch with a limited catalog and controlled customer group | Metrics reviewed after 7–14 days |

## 3. Environment strategy

Maintain separate development, test, and production environments for Flutter and Serverpod. Use separate payment credentials and webhook endpoints. Production data must never be used in development. Seed test products and synthetic addresses. Keep database migrations versioned and reversible where practical.

## 4. Launch checklist

Before live launch, verify the business bank account and payment settlement arrangement, physical-goods eligibility of the selected payment provider, refund and cancellation policy, outlet opening hours, delivery radius, packaging process, phone support, customer terms, privacy notice, webhook signature verification, backups, incident contacts, and manual delivery fallback.

Conduct a controlled live test with a small amount. Confirm that the customer sees the correct total, the shop sees the paid order, the provider receives the correct pickup/drop data, the tracking link works, and the order is reconciled after delivery.

## 5. Operating playbook

At opening, the shop operator confirms hours, item availability, and service radius. For each paid order, the operator accepts or rejects promptly, prepares the package, marks it ready, and hands it over only through the provider's official flow. At closing, the operator reviews pending, failed, refunded, and exception orders.

The platform operator reviews failed webhooks, delivery exceptions, refund cases, and reconciliation differences daily during the pilot. Weekly, review order completion, delivery subsidy, repeat usage, and customer feedback before adding features or outlets.

## 6. Expansion gates

Add a second outlet only after the single-outlet system has stable payment reconciliation, reliable delivery exception handling, clear support ownership, and enough repeat demand to justify outlet onboarding. Add recurring milk subscriptions only after one-off ordering is reliable. Add a second delivery provider when the first provider's coverage or reliability creates measurable customer loss.
