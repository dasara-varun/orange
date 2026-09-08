# Decisions, Constraints, and Risk Register — DS Milk World

## 1. Decisions

| Decision | Rationale |
|---|---|
| Start with one outlet | Reduces operational and support complexity |
| Use customer-paid delivery | Protects product margins and keeps pricing transparent |
| Use Dart, Flutter, and Serverpod | One language across client and backend, one client codebase for web, Android, and iOS, and typed server integration |
| Use PostgreSQL with Serverpod | Strong transactional consistency, typed database access, and future multi-outlet support |
| Use hosted payment checkout | Reduces card-data and compliance exposure |
| Fulfill from signed payment webhooks | Browser redirects can be missed or spoofed |
| Keep delivery behind an adapter | Allows provider replacement and manual fallback |
| Exclude Dodo for live physical-goods checkout | Dodo's published policy says physical goods are not supported [1] |
| Use supplied CSV as import input, not unquestioned truth | Public menu data requires shop verification |

## 2. Final technology decision

The final recommendation is Flutter/Dart for all product surfaces and Serverpod 3.x/Dart for the backend, with managed PostgreSQL as the source of truth. The pilot remains a modular monolith. Redis, object storage, and an external queue are optional extensions, not launch requirements. This decision minimizes the number of runtimes and keeps the codebase consistent without sacrificing a production path.

## 3. Payment provider gate

Dodo Payments is a technically attractive API product for hosted checkout, webhooks, INR, UPI, and cards, but its published merchant-acceptance material states that it does not support physical goods. That is a direct mismatch with milk, beverages, and desserts. Do not collect live DS Milk World customer payments through Dodo unless the provider gives written approval specific to this physical-goods use case.

The application must therefore implement a generic payment port. Select an India-focused provider after confirming physical-goods acceptance, UPI and card support, refunds, settlement, webhook signatures, test mode, and business onboarding requirements. This choice is a launch dependency, not an implementation detail to postpone.

## 4. Risk register

| Risk | Impact | Control |
|---|---|---|
| Delivery provider has no approved API | High | Obtain written business/API confirmation; retain manual fallback |
| No rider available after payment | High | Quote/availability check, shop hold state, refund workflow |
| Payment succeeds but shop rejects | High | Explicit refund case and customer notification |
| Duplicate webhook creates duplicate delivery | High | Event idempotency and order fulfillment lock |
| Customer address is outside coverage | Medium | Map pin, radius validation, operator override only |
| Delivery fee exceeds basket margin | High | Customer-paid quote, minimum order, scheduled delivery later |
| Catalog price or availability is wrong | Medium | Shop verification and staff editing |
| OTP is exposed prematurely | High | Follow provider contract; never ask for OTP before handover |
| Staff loses access to console | Medium | Recovery account, role separation, audit log |
| Provider changes API or terms | Medium | Adapter boundary, contract tests, vendor review |
| Personal data is over-retained | Medium | Data minimization, retention policy, restricted logs |

## 4. Vendor questions before build lock

Confirm the exact outlet city and address, delivery radius, average daily order expectation, operating hours, packaging constraints, preferred customer support channel, business entity and settlement account, selected payment provider eligibility, and approved delivery provider/API availability. These questions affect integration and operations, but they do not require changing the core architecture.

## References

[1]: https://docs.dodopayments.com/miscellaneous/merchant-acceptance "Dodo Payments Merchant Acceptance Policy"
[2]: https://docs.dodopayments.com/miscellaneous/faq "Dodo Payments FAQs"
[3]: https://docs.dodopayments.com/features/payment-methods/india "Dodo Payments India Payment Methods"
[4]: https://docs.dodopayments.com/developer-resources/integration-guide "Dodo Payments One-time Payments Integration Guide"
[5]: https://www.rapido.bike/DeliveryPartners "Rapido Delivery Partners"
