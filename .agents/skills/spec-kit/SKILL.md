---
name: spec-kit
description: Spec-Driven Development (SDD) framework and workflow management using GitHub Spec Kit. Enforces specs as the single source of truth, guiding AI agents through Constitution, Specification, Planning, Tasks breakdown, and Implementation. Use whenever designing a new feature, planning an architectural refactor, creating new schemas or API endpoints, or when the user mentions "spec", "specify", "constitution", "SDD", or asks to plan before coding. Prevents unstructured vibe-coding and ensures all work adheres to ratified project invariants.
---

# Spec Kit — Spec-Driven Development

Spec Kit provides a structured, phased workflow that anchors AI pair-programming in rigorous, verified specifications.

## The 5-Phase SDD Lifecycle

```
┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐     ┌──────────────┐
│  Phase 1     │ ──> │  Phase 2     │ ──> │  Phase 3     │ ──> │  Phase 4     │ ──> │  Phase 5     │
│ Constitution │     │ Specification│     │ Technical Plan│    │ Task Breakout│     │ Implementation│
│ (.specify/)  │     │  (spec.md)   │     │  (plan.md)   │     │  (tasks.md)  │     │ & Verification│
└──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘     └──────────────┘
```

### Phase 1: Constitution Check
Before writing any code or plans, verify compliance with the project constitution in `.specify/memory/constitution.md`:
1. **Zero-Latency Hydration**: Frame-1 UI render in 0ms without blocking network spinners.
2. **Integer Paise Arithmetic**: All monetary values calculated in paise (`₹1 = 100 paise`).
3. **Strict 5.0 km Freshness Perimeter**: Hard geofence centered on Kanuru Center (`16.4850° N, 80.6900° E`).
4. **Staff Security**: Counter operations console protected by staff PIN **`1979`**.
5. **Micro-Commit Cadence**: Commit after every notable milestone; push immediately to `origin main`.

### Phase 2: Specification (`spec.md`)
Draft or update the specification artifact using `.specify/templates/spec-template.md`:
- **User Scenarios & Stories**: Detail the who, what, and why.
- **Acceptance Criteria**: Concrete, testable conditions of satisfaction.
- **Data Model & Invariants**: Schemas, entity relationships, validation rules.
- **Out of Scope**: Explicit boundary constraints to avoid scope creep.

### Phase 3: Technical Plan (`plan.md`)
Draft the architectural blueprint using `.specify/templates/plan-template.md`:
- **Architecture Impact**: Backend endpoints, state management, UI components affected.
- **Failure Modes & Fallbacks**: Offline behavior, timeout policies, circuit breakers.
- **API Contracts**: Serverpod protocol definitions and request/response payloads.

### Phase 4: Task Breakout (`tasks.md`)
Break the plan into small, atomic tasks using `.specify/templates/tasks-template.md`:
- Every task must take less than 15 minutes of work.
- Every task must define an explicit verification command (e.g., `flutter test`, `flutter analyze`, `dart test`).
- Tasks must be ordered with dependencies first.

### Phase 5: Implementation & Verification
- Execute tasks one at a time.
- Verify tests pass cleanly after every task.
- Commit immediately using conventional commit messages and push to `origin main`.

## CLI Tool Usage

The `specify` CLI is available in the environment:
```powershell
$env:PATH = "C:\Users\DELL\.local\bin;$env:PATH"
specify check
specify self check
```

## Slash Commands Reference
- `/speckit-constitution`: Review or update project laws in `.specify/memory/constitution.md`.
- `/speckit-specify`: Create or update a feature specification.
- `/speckit-plan`: Create an architectural implementation plan.
- `/speckit-tasks`: Generate actionable task checklist.
- `/speckit-implement`: Step through implementation of tasks.
- `/speckit-checklist`: Verify consistency and quality gates.
