# UX and Design Specification — DS Milk World Direct

## 1. Design direction

The experience should feel like a trusted neighborhood milk-and-dessert counter rather than a generic food marketplace. Use a warm, fresh visual language based on milk white, deep cocoa, saffron, rose, and mint. Avoid the common red/orange marketplace template, dense promotional banners, and noisy discount-first layouts.

The visual identity should communicate three promises: **shop prices**, **fresh preparation**, and **clear delivery cost**. Product photography can be introduced later; the first release should use strong typography, category color bands, tasteful abstract dairy textures, and clear item descriptions rather than blank image placeholders.

## 2. Suggested visual tokens

| Token | Value | Use |
|---|---|---|
| Milk | `#FFF9F0` | Main background |
| Cocoa | `#3A241B` | Primary text and navigation |
| Cream | `#FFF1D6` | Cards and surfaces |
| Rose | `#D86773` | Falooda and dessert accents |
| Saffron | `#E8A23A` | Primary action and highlights |
| Mint | `#72B7A1` | Freshness and success states |
| Ink | `#1E1B19` | High-contrast text |
| Error | `#B63A3A` | Destructive and payment error states |

Use a rounded display face only for prominent headings and a highly legible sans-serif for body text. Keep body text at accessible contrast and use a minimum 44 px touch target.

## 3. Information architecture

| Area | Screens |
|---|---|
| Customer | Home, category, product detail, cart, address, delivery quote, checkout handoff, order tracking, order history, help |
| Staff | Login, live order queue, order detail, catalog, outlet settings, delivery exceptions, refunds, reports |
| Admin | Staff access, provider settings, audit log, system health, reconciliation |

## 4. Customer home screen

The home screen should open with a simple outlet header: DS Milk World, open/closed state, service radius, and a compact “Order at outlet prices” statement. Follow it with a persistent category rail and a small “popular today” section. Do not lead with discount coupons in the pilot.

The bottom action area should show the cart count and running subtotal. On small screens it should remain visible without covering product controls. On larger screens, use a two-column layout with browsing on the left and a sticky cart summary on the right.

## 5. Product cards and customization

Each card shows item name, short description, price, availability, and a single clear add control. Customizable products open a bottom sheet with options and price deltas. Do not bury the price inside the detail view. Use category accents sparingly so the catalog remains calm.

The supplied menu includes products such as Oreo Falooda, Rose Falooda, Badam Milk in 500 ml and 1000 ml sizes, multiple thick shakes, buttermilk variants, and milk shakes. Preserve the separate sizes as separate purchasable products unless the shop later wants a formal size selector.

## 6. Address and delivery experience

Use a single focused address step. Let the customer search, drag a map pin, and enter a landmark. Show serviceability immediately. If outside the radius, explain the limit and provide a support action instead of allowing an order that will later fail.

The delivery quote view must separate product subtotal from delivery fee. State that the delivery fee comes from the delivery provider or configured quote policy. If the quote is unavailable, show a controlled fallback such as “delivery confirmation required” and route the order to operator review; do not silently guess a fee.

## 7. Checkout and trust

The checkout handoff should clearly show the final amount, outlet details, delivery address, and refund/cancellation link before sending the customer to hosted payment. On return, display “We are confirming your payment” until the server status is known. Never say “Order confirmed” based only on a browser return.

## 8. Order tracking

Use a simple vertical timeline: payment received, shop accepted, preparing, ready for pickup, rider assigned, picked up, out for delivery, delivered. Show the provider booking ID and tracking link only when available. For exceptions, show a human-readable message and a call/WhatsApp support action.

## 9. Staff console

The default staff view is a live queue with large status columns: New paid orders, Preparing, Ready, Delivery active, and Exceptions. Each card shows order number, elapsed time, item count, total, customer locality, and the next action. Avoid exposing unnecessary personal data in the queue.

The order detail view must have one primary next-action button and a visible payment state. Rejection must require a reason. Marking an order ready must require a packing confirmation. Manual delivery fallback must be a guided form, not a hidden database edit.

## 10. Responsive behavior

Design at three reference widths: 360 px mobile, 768 px tablet, and 1440 px desktop. The customer experience is mobile-first. The staff console may use a dense desktop layout but must remain usable on a tablet. Avoid hover-only actions, fixed-width tables, and sidebars that consume the entire mobile viewport.

## 11. Accessibility and content rules

Use semantic labels, readable focus states, keyboard navigation on web, descriptive error text, and accessible form controls. Keep product names exactly as approved by the shop. Normalize accidental spacing and spelling only after shop review. Do not claim ingredients, allergens, nutrition, or dietary certifications that are not verified.

## 12. Empty, loading, and failure states

Every data-dependent screen requires loading skeletons, an empty state, a retry action, and a support path. Payment pending, payment failed, no rider available, shop closed, item unavailable, and refund pending states must be designed before implementation.
