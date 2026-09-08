# Product Requirements Document — DS Milk World Direct Ordering MVP

## 1. Product summary

DS Milk World Direct is a single-outlet ordering platform that lets customers buy products at the outlet's listed prices, select a delivery location, pay online, and receive the order through an approved third-party delivery provider. DS Milk World manages catalog accuracy, acceptance, preparation, and handover. The platform manages the customer experience, payment confirmation, order state, delivery coordination, notifications, and support workflow.

The pilot is intentionally narrow. It does not attempt to be a multi-vendor marketplace, employ riders, operate a wallet, or launch native applications before demand is proven.

## 2. Goals and non-goals

| Goals | Non-goals for MVP |
|---|---|
| Accept direct prepaid orders from one outlet | Multiple outlets and vendor onboarding |
| Preserve outlet prices and show delivery separately | Platform-wide commission engine |
| Support UPI and debit/credit cards through an approved provider | Cash on delivery and stored wallet balance |
| Use map-selected addresses and enforce a service radius | Complex route optimization |
| Outsource rider operations through an approved delivery API or controlled fallback | Employing or dispatching in-house riders |
| Provide staff order handling and operational visibility | Native-only app before pilot validation |
| Keep architecture extensible for later scale | Loyalty points, promotions engine, and advanced subscriptions |

## 3. Users and roles

| Role | Need |
|---|---|
| Customer | Browse, order, pay, track, repeat, and get help |
| Shop operator | See paid orders, accept, mark ready, and hand over safely |
| Platform administrator | Manage catalog, service area, payments, delivery settings, refunds, and incidents |
| Delivery provider | Receive a valid pickup/drop job and return delivery status |

## 4. Pilot scope

The supplied catalog contains 79 distinct menu items across Falooda, Our Specials, Thick Shakes, Butter Milk, Milk Shakes, and the remaining categories in the provided CSV. The CSV is the source import file, but every product must be verified by the shop before publication because it was extracted from a public listing and includes source metadata rather than an authoritative inventory contract.

The pilot should publish a curated subset first, then enable the remainder after operational review. Product price, availability, preparation notes, customization options, and packaging constraints must be editable from the staff console.

## 5. Core customer flow

1. Customer opens the responsive store page.
2. Customer browses categories and adds items to cart.
3. Customer enters phone number and delivery details.
4. Customer selects a map location or uses a saved address.
5. Platform checks whether the location is within the configured service radius.
6. Platform obtains a delivery quote, or applies a configured fallback rule when a quote is unavailable.
7. Checkout shows product subtotal, delivery fee, any tax/fee line, and the final total.
8. Customer completes hosted checkout through the approved payment gateway.
9. The server confirms payment from a signed provider webhook.
10. The order becomes paid and is presented to the shop.
11. Shop accepts or rejects the order and prepares the package.
12. Platform creates or confirms the delivery booking only after payment and shop acceptance.
13. Customer receives status and tracking information when available.
14. Shop confirms handover using the provider's official workflow.
15. Customer confirms receipt using the provider's delivery flow when required.

## 6. Order state model

`draft → awaiting_payment → payment_processing → paid → shop_acceptance_pending → accepted → preparing → ready_for_pickup → delivery_requested → rider_assigned → picked_up → out_for_delivery → delivered`

Terminal and exception states are `payment_failed`, `payment_cancelled`, `shop_rejected`, `delivery_unavailable`, `delivery_cancelled`, `delivery_failed`, `refunded`, and `partially_refunded`.

Every transition must be recorded with actor, timestamp, source event, and reason. The client must never be allowed to invent a state transition.

## 7. Functional requirements

| ID | Requirement | Priority |
|---|---|---|
| FR-01 | Browse published products by category | Must |
| FR-02 | Add, remove, and adjust cart quantities | Must |
| FR-03 | Show outlet prices without marketplace commission markup | Must |
| FR-04 | Capture address, phone, landmark, and map coordinates | Must |
| FR-05 | Reject locations outside the configured service area | Must |
| FR-06 | Calculate and display delivery charges before payment | Must |
| FR-07 | Create a fresh hosted checkout session per payment attempt | Must |
| FR-08 | Confirm payment only from a verified webhook | Must |
| FR-09 | Prevent duplicate order fulfillment on repeated callbacks | Must |
| FR-10 | Let staff accept, reject, prepare, and mark ready | Must |
| FR-11 | Request delivery through an approved provider adapter | Must |
| FR-12 | Show customer order timeline and tracking link | Must |
| FR-13 | Support manual delivery-booking fallback | Must |
| FR-14 | Provide refund and cancellation handling | Must |
| FR-15 | Maintain an immutable order and event audit trail | Must |
| FR-16 | Support guest checkout with phone verification or signed order access | Should |
| FR-17 | Support repeat order from history | Should |
| FR-18 | Support scheduled delivery windows | Later |
| FR-19 | Support recurring milk subscriptions | Later |

## 8. Payment rules

The platform must not store card credentials. It must use a provider-hosted checkout or approved SDK. The payment adapter must support INR, UPI, debit cards, credit cards, payment status webhooks, refunds, and merchant settlement appropriate for physical goods in India.

For one-off orders, delivery booking must not be treated as proof of payment. Fulfillment begins only after a verified successful payment event and shop acceptance. If payment succeeds but the shop rejects the order, the system opens a refund case and notifies the customer.

## 9. Pilot acceptance criteria

The pilot is ready when a staff member can publish a product, a customer can complete an order on a phone, a duplicate payment callback does not create a second delivery, the shop can reject an unavailable order, the platform can record a refund case, and an operator can complete a manual delivery fallback without database edits.

The first success threshold is 10–20 completed paid orders per day with fewer than 2% duplicate/incorrect fulfillment incidents, a clear delivery-cost record per order, and repeat usage from early customers. These are operating targets, not guarantees.

## 10. Success metrics

| Metric | Definition |
|---|---|
| Order completion rate | Delivered orders divided by paid orders |
| Payment success rate | Successful payments divided by checkout attempts |
| Delivery assignment rate | Orders receiving a rider within the target time |
| Median preparation time | Shop acceptance to ready-for-pickup |
| Median delivery time | Pickup to delivered |
| Refund rate | Refunded orders divided by paid orders |
| Repeat rate | Customers placing a second order within 30 days |
| Contribution per order | Product gross margin less payment, support, subsidy, and platform allocation |

## 11. Technology constraint

The product will be implemented with Flutter/Dart for web, Android, and iOS and Serverpod 3.x/Dart for the backend. This is an implementation constraint, not a customer-facing feature, and it is selected to keep one language across the product while retaining typed API integration and a production-grade PostgreSQL foundation.

## References

[1]: https://docs.dodopayments.com/miscellaneous/merchant-acceptance "Dodo Payments Merchant Acceptance Policy"
[2]: https://docs.dodopayments.com/developer-resources/integration-guide "Dodo Payments One-time Payments Integration Guide"
