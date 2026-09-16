# Rule: Impeccable Design & Frontend Craft

All frontend, UI, visual, and UX work in this workspace must adhere to the **Impeccable** design framework (`impeccable.style`).

## Mandatory Sources of Truth
1. **`DESIGN.md`**: Design tokens, color palette (`AppTheme.cocoa`, `AppTheme.milk`, `AppTheme.saffron`, `AppTheme.cream`), typography scale, 4px/8px grid system, corner radii, and component specs.
2. **`PRODUCT.md`**: Brand personality, dairy parlor authenticity, target personas (Refreshment Seeker & Counter Staff), and core UX invariants.

## Deterministic Anti-Pattern Bans (Quality Floor)
- ❌ **No AI Slop**: Never generate generic purple-to-blue gradients, floating card shadows without light source logic, or novelty glassmorphism.
- ❌ **No Pure Grays or Blacks**: Always use Cocoa (`#3A241B`) for text and Ink (`#1E1B19`) for high contrast. Muted text must use `#786F66`.
- ❌ **No Cramped Touch Targets**: Every button, chip, stepper, and icon tap area must meet the **44px × 44px** minimum standard.
- ❌ **No Jittery Loading**: Never unmount existing UI or flash full-screen spinners on background updates or polling intervals. Keep state updates in-place.
- ❌ **No Dead Ends / Unstyled Empty States**: Every empty state must have an intentional icon, warm empathetic copy, and an immediate actionable button.

## Impeccable Commands Available
- `/polish [target]`: Final quality pass fixing alignment, spacing, contrast, and visual rhythm.
- `/audit [target]`: Scan for accessibility (a11y), contrast ratios, performance, and responsive breakpoints.
- `/critique [target]`: Structured heuristic UX evaluation of visual hierarchy and cognitive load.
- `/distill [target]`: Strip unnecessary visual clutter, over-complicated dialogs, or excessive controls.
- `/animate [target]`: Add purposeful micro-interactions, spring physics, or subtle haptic transitions.
- `/layout [target]`: Fix grid balance, whitespace rhythm, and typography hierarchy.
- `/harden [target]`: Prepare UI for production (error boundaries, edge-case text overflow, offline indicators).
