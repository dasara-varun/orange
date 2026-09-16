# DS Milk World — Spec Kit Project Constitution

## Core Principles

### I. Spec-Driven Development (NON-NEGOTIABLE)
Every feature, architectural modification, and protocol extension must start from an approved specification artifact (`spec.md` and `plan.md`) in `.specify/` or the designated planning framework. Specifications serve as the single source of truth. The team and AI agents must never practice unstructured "vibe coding" without documented requirements, data invariants, and verification steps.

### II. Zero-Latency State Hydration & Offline Resilience
The client applications (Customer Storefront and Staff Ops Console) must hydrate and render within **0ms on frame 1**. All API services must implement resilient circuit breakers (maximum 350ms network probe timeout) with instant local fallback. Standalone web sessions must remain 100% interactive without blocking spinners or UI freezes.

### III. Fullstack Invariant Integrity
- **Integer Paise Arithmetic**: All financial calculations (item prices, add-ons, discounts, delivery fees, taxes, subtotals, refunds) must be computed in integer paise (`₹1 = 100 paise`). Floating-point arithmetic is strictly forbidden.
- **Server-Authoritative Totals**: The backend recalculates and enforces all order totals from database catalog snapshots. Client-submitted prices or totals are completely ignored.
- **Strict 5.0 km Freshness Perimeter**: Orders beyond 5.0 km from Kanuru Center (`16.4850° N, 80.6900° E`) must be rejected at the boundary to guarantee dairy product chill and quality.

### IV. Impeccable Design & UI Craft
- Interfaces must strictly adhere to the tokens and guidelines defined in `DESIGN.md` and `PRODUCT.md`.
- No generic "AI slop", unstyled empty states, or arbitrary color gradients.
- Interactive controls must maintain a minimum 44px touch target.
- Polling, search filtering, and state transitions must happen seamlessly in-place without visual jitter.

### V. High-Cadence Micro-Commits & Immediate Pushing
- Work must never accumulate uncommitted across multiple tasks or files.
- Commit immediately after every notable atomic milestone (component update, bugfix, new endpoint, passing test).
- Push immediately to `origin main` to maintain real-time remote synchronization and continuous integration deployment.
- `main` must remain green, tested, and deployable at all times.

---

## Technical Standards & Quality Gates

1. **Platform Architecture**:
   - Backend: Serverpod (Dart fullstack framework), PostgreSQL migrations, Redis pub/sub.
   - Frontend: Flutter Web / Cross-Platform, CanvasKit/HTML renderers, pure CSS zero-latency splash loader.
   - Geolocation & Mapping: OpenStreetMap raster tiles, Leaflet (`flutter_map`), Haversine distance engine.
2. **Quality Gates**:
   - Static analysis: Zero linter issues allowed (`flutter analyze`).
   - Automated tests: All unit, widget, and server lifecycle tests must pass before commit/push (`flutter test`, `dart test`).
3. **Security Standards**:
   - Outlet console must require counter staff PIN **`1979`**.
   - No API keys, credentials, or private keys checked into version control.

---

## Governance & Amendment

- This constitution represents the supreme engineering law of the DS Milk World repository.
- Changes to these core principles require an explicit architectural review and an update to this document.

**Version**: 1.0.0 | **Ratified**: 2026-09-10 | **Last Amended**: 2026-09-16
