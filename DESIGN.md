# DS Milk World — Design System (DESIGN.md)

This document is the single source of truth for the visual design system, styling conventions, tokens, and UX guidelines across the DS Milk World customer and outlet applications. All AI agents, contributors, and interfaces must strictly conform to these rules.

---

## 🎨 1. Color System & Semantic Palette

Our palette reflects the authentic, artisanal heritage of pure farm milk, cocoa, saffron, and traditional Indian dairy treats.

### Core Tokens
| Token | Hex | Role | Usage |
| :--- | :--- | :--- | :--- |
| `AppTheme.cocoa` | `#3A241B` | Primary / Dark Brand | App bars, prominent titles, primary buttons, KOT receipt headers |
| `AppTheme.milk` | `#FFF9F0` | Primary Background | Scaffold and screen background (warm, creamy off-white) |
| `AppTheme.cream` | `#FFF1D6` | Surface / Card Tint | Card backgrounds, badge containers, secondary chip surfaces |
| `AppTheme.saffron` | `#E8A23A` | Brand Accent / Amber | Interactive accents, highlights, selected state indicators, star ratings |
| `AppTheme.mint` | `#72B7A1` | Success / Chilled | In-stock badges, delivered status, savings highlights, freshness tags |
| `AppTheme.rose` | `#D86773` | Delight Accent | Special flavor tags, discounts, falooda syrups, festive highlights |
| `AppTheme.error` | `#B63A3A` | Destructive / Alert | Out-of-stock badges, rejection alerts, cancellation buttons |
| `AppTheme.ink` | `#1E1B19` | High-Contrast Text | Body copy, prices, customer details |
| `AppTheme.muted` | `#786F66` | Secondary Text | Descriptions, subtitles, timestamps, placeholder text |
| `AppTheme.border` | `#E8DEC8` | Dividers & Outlines | Card outlines, input borders, structural separators |

### Gradient & Radial Rules
- **Rule**: Never use generic "AI slop" gradients (e.g., purple-to-blue, neon cyberpunk, or synthetic neon cyan).
- **Allowed Gradients**:
  - Warm Cocoa Radial: `radial-gradient(circle, #4D3227 0%, #3A241B 100%)` (used in splash & banners).
  - Saffron Shimmer: `linear-gradient(90deg, #E8A23A, #FFB366)` (used in progress indicators & special tags).

---

## ✍️ 2. Typography & Scale

- **Primary Font**: Sans-serif (`-apple-system`, `BlinkMacSystemFont`, `Segoe UI`, `Roboto`, `Helvetica`, `Arial`).
- **Monospace Font**: Monospace (`SFMono-Regular`, `Consolas`, `Liberation Mono`, `Courier New`) used strictly for:
  - Thermal KOT Kitchen Tickets
  - Order numbers (`#DSMW-20260910-01`)
  - Distance & coordinates readouts

### Type Scale
| Role | Size | Weight | Line Height | Letter Spacing | Context |
| :--- | :--- | :--- | :--- | :--- | :--- |
| **Hero Title** | 22px – 24px | 800 (Extrabold) | 1.2 | -0.3px | Outlet header, modal headings |
| **Section Title** | 16px – 18px | 800 (Bold) | 1.3 | -0.2px | Category headers, sheet headers |
| **Card Title** | 14px – 15px | 700 (Bold) | 1.3 | 0.0px | Product item names, order numbers |
| **Body Primary** | 13px – 14px | 500 (Medium) | 1.4 | 0.0px | Item descriptions, form labels |
| **Caption / Meta** | 11px – 12px | 500 (Regular) | 1.4 | +0.2px | Timestamps, distance badges, hints |
| **Badge / Pill** | 10px – 11px | 800 (Extrabold) | 1.0 | +0.5px | Veg marks, size badges, status pills |

---

## 📐 3. Spacing, Sizing & Layout Rhythm

We follow a strict **4px / 8px grid system**:
- `4px`: Micro spacing (badge padding, icon-text gap).
- `8px`: Compact spacing (chip spacing, variant pill gaps).
- `12px`: Standard element spacing (inside cards, form rows).
- `16px`: Screen padding, card internal padding, list separators.
- `20px` – `24px`: Section gaps, modal bottom padding.
- `32px`+: Major section dividers.

### Target Constraints
- **Max Content Width**: `860px` for mobile/tablet web storefront.
- **Minimum Touch Target**: Every button, chip, and interactive control must be at least **`44px × 44px`** (or 44px height for pills).
- **Corner Radii**:
  - `6px`: Small badges, KOT tags, status pills.
  - `8px` – `10px`: Standard cards, input fields, action buttons.
  - `16px` – `20px`: Bottom sheets, modal dialogs, category chips.
  - `999px`: Fully rounded pill buttons (`ADD`, quantity steppers, variant selectors).

---

## 📱 4. Component Patterns & Invariants

### 1. Product Cards (`ProductCard`)
- Must display authentic prices in integer paise formatted as `₹XX` via `AppTheme.formatPaise()`.
- Green square-dot veg indicator on all pure vegetarian dairy items.
- Size variants (*300ml*, *650ml*, *Regular*, *Large*) presented as horizontal pill toggles.
- Add button transitions smoothly to `[-] QTY [+]` stepper with haptic/tactile feedback.

### 2. Category Rail (`CategoryRail`)
- Sticky horizontal scroll rail with item count badges (*e.g., "Thick Shakes (18)"*).
- Active category marked with Cocoa background `#3A241B` and Cream text `#FFF1D6`.

### 3. OpenStreetMap Delivery Map (`InteractiveMapPicker`)
- Must use OpenStreetMap raster tiles (`tile.openstreetmap.org`) with proper tile attribution.
- Clear 5.0 km geofence circle overlay centered at Kanuru Center (`16.4850° N, 80.6900° E`).
- Real-time GPS geolocator pinpoint button + fast landmark chips (*Kanuru Center, Tadigadapa, Poranki, Auto Nagar, Patamata, Benz Circle*).
- Rapido parcel rate card showing base ₹30 + ₹10/km live fee.

### 4. Staff Console Kanban Board (`StaffConsoleScreen`)
- Tab structure: `New Paid`, `Preparing`, `Ready for Pickup`, `Out for Delivery`, `Completed`, `Menu Catalog`, `Reports & Stats`.
- PIN security: **`1979`**.
- Prep time selector (*15, 20, 25, 30, 45 mins*).
- Itemized packaging checklist before dispatch.
- Thermal Kitchen Order Ticket (KOT) 80mm preview.

---

## 🚫 5. Anti-Patterns & Quality Floor (Deterministic Rules)

1. **No Generic AI Slop**: Never apply generic AI-generated styles (random purple neon cards, floating translucent glassmorphism without purpose).
2. **No Unstyled Empty States**: Every empty state (empty cart, no orders, search with 0 results) must feature an intentional icon, warm empathetic copy, and an immediate call to action button.
3. **No Pure Black (#000000) or Pure Gray (#808080)**: Use Cocoa `#3A241B` for dark text and `#786F66` for muted secondary copy.
4. **No Unreachable Controls**: All primary checkout, floating cart, and counter action buttons must remain pinned within thumbs-reach on mobile viewports.
5. **No Visual Jitter**: Transitions, quantity increments, and polling updates must occur silently in-place without flashing full-screen loading spinners.
