# DS Milk World — Development Environment & Agent Instructions (AGENTS.md)

This file is the master operational guideline for all AI coding assistants, subagents, and contributors working in this repository. All agent turns and modifications must strictly follow the four foundational frameworks configured in this environment:

1. **Spec Kit**: Spec-Driven Development (`github.com/github/spec-kit`)
2. **Context7**: Live Documentation System (`github.com/upstash/context7`)
3. **Impeccable**: High-Craft Frontend Design System (`impeccable.style`)
4. **Git-GitHub Manager**: High-Cadence Micro-Commit & Immediate-Push Protocol

---

## 🏛️ 1. Spec Kit — Spec-Driven Development (SDD) Protocol

Never "vibe code" architectural changes, new endpoints, or multi-component features without an authoritative specification.

### Workflow Phases
1. **Constitution Compliance**: Check `.specify/memory/constitution.md` before making design choices.
   - Zero-latency hydration (0ms on frame 1).
   - Integer paise financial arithmetic (`₹1 = 100 paise`).
   - Hard 5.0 km freshness perimeter from Kanuru Center (`16.4850° N, 80.6900° E`).
   - Staff PIN **`1979`** security.
2. **Specification (`spec.md`)**: Define user stories, acceptance criteria, data models, and out-of-scope boundaries.
3. **Plan (`plan.md`)**: Detail technical architecture, dependencies, circuit breakers, and database migrations.
4. **Tasks (`tasks.md`)**: Break implementation into small, atomic, verifiable checklist items.
5. **Implementation**: Execute task-by-task with verification at every step (`flutter test`, `dart test`, `flutter analyze`).

### Spec Kit Commands
- `/speckit-constitution`: Review or update project principles.
- `/speckit-specify`: Create or update feature specification.
- `/speckit-plan`: Create architectural technical plan.
- `/speckit-tasks`: Break plan into actionable tasks.
- `/speckit-implement`: Step through task execution.
- `/speckit-checklist`: Quality gates verification.

---

## 📚 2. Context7 — Live Documentation & MCP Protocol

Do not rely on static training data or guess API signatures for external packages and frameworks.

### Rules
- Use `ctx7` whenever querying API syntax, constructor parameters, configuration options, or breaking changes for:
  - Flutter & Dart libraries (`flutter_map`, `latlong2`, `provider`, `http`)
  - Serverpod backend framework (`serverpod`, `serverpod_client`, `serverpod_service_client`)
  - Database drivers & ORM (PostgreSQL, Redis)
  - 3P Integrations (Razorpay, PhonePe, Rapido, Shadowfax)
- **Step 1: Resolve Library ID**:
  ```bash
  npx ctx7@latest library "<Library Name>" "<Query>"
  ```
- **Step 2: Fetch Documentation**:
  ```bash
  npx ctx7@latest docs "<libraryId>" "<Topic>"
  ```
- Prompting shortcut: Include **"use context7"** when requesting third-party library details.

---

## 🎨 3. Impeccable — Frontend Craft & Quality Floor

All UI/UX work must respect the visual standards codified in [`DESIGN.md`](./DESIGN.md) and [`PRODUCT.md`](./PRODUCT.md).

### Palette Tokens
- **Cocoa** (`#3A241B`): AppBars, prominent headings, primary buttons, KOT headers.
- **Milk** (`#FFF9F0`): Scaffold and main background (warm, creamy off-white).
- **Cream** (`#FFF1D6`): Card surfaces, secondary badges, chip backgrounds.
- **Saffron** (`#E8A23A`): Brand amber accent, selected tabs, star ratings.
- **Mint** (`#72B7A1`): In-stock status, freshness highlights, savings badges.
- **Ink** (`#1E1B19`): High-contrast body text.
- **Muted** (`#786F66`): Descriptions, timestamps, secondary hints.
- **Border** (`#E8DEC8`): Card borders, input outlines, dividers.

### Deterministic Anti-Pattern Bans
- ❌ **No AI Slop**: Never use generic purple-to-blue gradients or unmotivated glassmorphism.
- ❌ **No Pure Gray/Black Text**: Use `#3A241B` for headings and `#1E1B19` for body copy.
- ❌ **No Small Touch Targets**: Interactive controls must be at least **44px × 44px**.
- ❌ **No Full-Screen Spinner Flashes**: Polling and background updates must execute silently in-place.
- ❌ **No Unstyled Empty States**: Always provide an intentional icon, empathetic copy, and an immediate CTA button.

### Impeccable Commands
- `/polish`: Final quality pass on alignment, spacing, and microcopy.
- `/audit`: Scan for a11y contrast ratios, performance, and responsive breakpoints.
- `/critique`: UX evaluation of visual hierarchy and cognitive load.
- `/distill`: Strip clutter and over-engineered elements.
- `/animate`: Add purposeful micro-interactions and smooth transitions.
- `/layout`: Fix grid rhythm, spacing consistency, and hierarchy.
- `/harden`: Production-ready edge cases, error states, and text overflow.

---

## ⚡ 4. Git & GitHub — Micro-Commit & Immediate-Push Protocol

1. **Micro-Commit Cadence**: Commit immediately after every notable change (widget update, bugfix, schema adjustment, passing test). Do not stockpile uncommitted changes across unrelated tasks.
2. **Immediate Push Cadence**: Push immediately after every commit to `origin main`. This guarantees remote backup, triggers CI pipelines in real time, and eliminates divergent histories.
3. **Atomic Commits**: Follow Conventional Commits format (`feat:`, `fix:`, `refactor:`, `perf:`, `style:`, `test:`, `docs:`).
4. **Deployable Main**: Run quality checks (`flutter analyze`, `flutter test`, `dart test`) before committing to keep `main` 100% green and deployable.

---

## 📋 5. Core Invariants Cheat Sheet

| Parameter | Value | Location |
| :--- | :--- | :--- |
| **Hub Address** | Kanuru Center, Bandar Road, Vijayawada | `GeoService`, `CatalogService` |
| **Hub Coordinates** | `16.4850° N, 80.6900° E` | `api_service.dart`, `interactive_map_picker.dart` |
| **Max Service Radius** | `5.0 km` (Hard geofence) | `GeoService.isServiceable()` |
| **Delivery Fee** | Base ₹30 (up to 2 km) + ₹10/km beyond | `_calculateFeePaise()` |
| **Monetary Unit** | Integer Paise (`₹1 = 100 paise`) | All models & databases |
| **Staff Console PIN** | **`1979`** | DB & `verifyStaffPin` |
| **State Hydration** | `0ms` (Frame 1 synchronous render) | `storefront_screen.dart`, `staff_console_screen.dart` |
