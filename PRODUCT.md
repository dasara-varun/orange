# DS Milk World — Product Context (PRODUCT.md)

This document provides durable product context, user personas, operational scope, and business invariants for the DS Milk World direct-to-consumer digital ordering and counter management platform.

---

## 🥛 1. Product Overview & Value Proposition

**DS Milk World** is an authentic dairy parlor and dessert kitchen located in **Kanuru, Vijayawada**. The platform enables customers to order fresh farm dairy products, thick shakes, royal faloodas, and flavored sodas directly from the shop counter for doorstep delivery, bypassing 3P aggregator price markups and platform commissions.

### Key Value Pillars
1. **Direct Counter Pricing**: Authentic in-shop prices without aggregator inflation or phantom markups.
2. **Strict Freshness Perimeter**: Maximum 5.0 km delivery radius from Kanuru Center to guarantee shakes and faloodas arrive ice-cold and uncompromised.
3. **Rapid Kitchen Turnaround**: Direct kitchen ticket printing (KOT) and dedicated dispatch via partner bike parcel APIs (Rapido/Shadowfax) or in-house shop riders.
4. **Transparent Fullstack Trust**: Live order tracking timeline, itemized kitchen packaging checklist, and instant automated refunds upon any cancellation.

---

## 📍 2. Hub Location & Geofencing Parameters

- **Outlet Address**: Kanuru Center, Bandar Road, Vijayawada, Andhra Pradesh 520007.
- **Coordinates**: `16.4850° N, 80.6900° E`
- **Delivery Service Radius**: `5.0 km` maximum (hard geofence).
- **Serviceable Neighborhoods**:
  - *Kanuru Center* (0.0 km)
  - *Tadigadapa* (1.2 km)
  - *Poranki* (1.8 km)
  - *Auto Nagar* (2.9 km)
  - *Patamata* (4.2 km)
  - *Benz Circle* (4.9 km)
- **Delivery Fee Structure**:
  - Up to 2.0 km: Flat ₹30 (3000 paise).
  - Beyond 2.0 km: ₹30 + ₹10 per additional km.

---

## 👥 3. Target User Personas

### Persona A: The Refreshment Seeker (Customer)
- **Context**: Resident, college student, or office worker in Kanuru, Poranki, or Auto Nagar craving thick milkshakes, royal falooda, or chilled masala buttermilk on a warm afternoon.
- **Needs**: Instant menu loading, seamless visual selection of flavors and sizes (300ml vs 650ml), frictionless checkout, precise doorstep location pin on OpenStreetMap, and clear real-time delivery status updates.
- **Frustrations**: 3-second app freezes, inflated ₹150+ prices on aggregator apps, melted/lukewarm dairy delivered from distant commercial kitchens.

### Persona B: The Counter Staff & Kitchen Supervisor (Staff)
- **Context**: Fast-paced dairy parlor counter staff in Kanuru operating during peak evening rush hours (4 PM – 10 PM).
- **Needs**: High-contrast, tactile, PIN-protected (`1979`) operations console. Immediate audio-visual alerts when orders are paid, one-tap prep time acceptance, itemized packaging checklists to avoid missed items, and 1-click thermal KOT printing.
- **Frustrations**: Complex login flows, unreliable software that freezes when offline, confusing ticket layouts, and manual math for daily reconciliation.

---

## ⚡ 4. Architectural Non-Negotiables & Invariants

1. **Zero-Latency State Hydration**:
   - The customer storefront and staff console must render instantly in 0ms on frame 1 using local catalog state.
   - Network calls must be non-blocking with automated circuit breakers (350ms timeouts) that gracefully degrade to local data when the backend is unreachable.
2. **Server-Authoritative Pricing**:
   - Item prices, delivery fees, and order totals are calculated strictly on the backend in integer paise (`₹1 = 100 paise`) to prevent floating-point rounding bugs and client-side price tampering.
3. **Strict Geofence Rejection**:
   - Any order attempt located at a distance > 5.0 km must be rejected before payment handoff with a helpful distance explanation.
4. **Audit Trail & Event Sourcing**:
   - Every order state transition (`order_created`, `payment_successful`, `order_accepted`, `order_ready`, `delivery_dispatched`, `order_delivered`, `order_rejected`) is permanently recorded in the order event log.
5. **Kitchen Packaging Checklist**:
   - Orders cannot advance to `Ready for Pickup` without staff checking off each prepared item and quantity.
6. **PIN Security**:
   - Counter console is gated by staff PIN **`1979`**.
