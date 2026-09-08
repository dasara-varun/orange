# DS Milk World Platform — MVP Documentation Package

**Status:** Build-ready product and engineering baseline  
**Pilot:** One outlet, DS Milk World  
**Primary market:** Vijayawada, India, subject to final outlet/service-area confirmation  
**Author:** Manus AI

This package defines a minimal but production-oriented direct-ordering platform for DS Milk World. The pilot uses one shop, customer-paid delivery, one payment provider, and one approved delivery integration. The design preserves a clean path to multiple outlets without prematurely implementing marketplace complexity.

## Important payment decision

Dodo Payments is **not approved for this use case**. Its official merchant-acceptance documentation states that it supports digital delivery and does not support physical goods. DS Milk World sells physical food and beverages, so Dodo must not be used for live checkout unless Dodo gives written, product-specific approval that overrides its published policy. The payment layer in the technical design is therefore provider-neutral and should be implemented with an India-capable gateway that explicitly supports physical goods, INR, UPI, cards, refunds, and merchant settlement.

## Documents

| File | Purpose |
|---|---|
| `PRD.md` | Product requirements, scope, users, flows, acceptance criteria, and pilot metrics |
| `TRD.md` | Technical requirements, architecture, data model, security, integrations, and operational design |
| `UX-AND-DESIGN.md` | Brand direction, responsive design system, screens, states, and interaction rules |
| `IMPLEMENTATION-PLAN.md` | Delivery sequence, milestones, testing, deployment, and launch checklist |
| `DECISIONS-AND-RISKS.md` | Key decisions, unresolved vendor questions, assumptions, and risk controls |
| `menu/ds_milk_world_menu_clean.csv` | Supplied 79-item catalog for import and content review |

## Final recommended production stack

The strongest fit for this product is an **all-Dart application stack**:

| Layer | Final choice | Reason |
|---|---|---|
| Customer and staff application | Flutter with Dart | One responsive codebase for web, Android, and iOS |
| Backend | Serverpod 3.x with Dart | Dart-native typed endpoints, generated client, authentication support, PostgreSQL integration, and a clean path from pilot to multi-outlet platform |
| Database | Managed PostgreSQL 16+ | Transactions, constraints, reporting, backups, and future multi-outlet data isolation |
| Cache and short-lived jobs | Redis-compatible managed cache, added only when needed | Rate limiting, temporary quote caching, and distributed locks without making the first release dependent on it |
| Files | S3-compatible object storage | Product media, receipts, and future documents without putting binary data in PostgreSQL |
| Payments | Provider-neutral Dart adapter | Dodo is excluded for physical goods; select an India-capable gateway supporting INR, UPI, cards, refunds, signed webhooks, and merchant settlement |
| Delivery | Provider-neutral Dart adapter | Supports an approved Rapido/aggregator API and a manual fallback |
| Deployment | Dockerized Serverpod service plus managed Flutter web hosting | Reproducible deployment, simple staging/live separation, and future horizontal scaling |
| Monitoring | OpenTelemetry-compatible traces, structured logs, uptime checks, and error tracking | Faster diagnosis of payment and delivery failures |

This stack keeps the customer app and backend in one programming language while preserving provider boundaries. The pilot should begin as a modular monolith, not as microservices. PostgreSQL is the source of truth, and Redis remains optional until measured traffic or concurrency requires it.

The first release should be a responsive installable web experience. Android and iOS builds should come from the same Flutter project and be enabled when pilot usage justifies store distribution.

## Architecture principle

Start with a complete, reliable order-to-payment-to-delivery loop rather than a large feature set. The pilot must be able to accept a paid order, prevent duplicate fulfillment, let the shop accept and pack it, create a delivery booking through an approved provider, show status, and resolve exceptions.

## Sources

[1]: https://docs.dodopayments.com/miscellaneous/merchant-acceptance "Dodo Payments Merchant Acceptance Policy"
[2]: https://docs.dodopayments.com/miscellaneous/faq "Dodo Payments FAQs"
[3]: https://docs.dodopayments.com/developer-resources/integration-guide "Dodo Payments One-time Payments Integration Guide"
[4]: https://docs.dodopayments.com/features/payment-methods/india "Dodo Payments India Payment Methods"
[5]: https://www.rapido.bike/DeliveryPartners "Rapido Delivery Partners"

## Stack references

[6]: https://docs.serverpod.dev/3.1.0/overview "Serverpod 3.1 Overview"
[7]: https://docs.flutter.dev/ui/adaptive-responsive "Flutter Adaptive and Responsive Design"
[8]: https://docs.flutter.dev/app-architecture/guide "Flutter App Architecture Guide"
