# Rule: Spec Kit & Spec-Driven Development (SDD)

All coding agents operating in this workspace must adhere to the **Spec Kit** Spec-Driven Development framework (`github.com/github/spec-kit`).

## Principles
1. **Never "Vibe Code"**: Do not make unstructured, unreviewed changes to core architecture, schemas, state management, or multi-component workflows without a clear specification.
2. **Source of Truth**: Specifications (`spec.md`) and technical plans (`plan.md`) are the authoritative blueprints. Code is an implementation detail derived from the spec.
3. **Spec Kit Phases**:
   - **Phase 1: Constitution (`.specify/memory/constitution.md`)**: Always respect non-negotiable project laws (0ms hydration, integer paise, 5.0 km radius, PIN 1979).
   - **Phase 2: Specify (`.specify/templates/spec-template.md`)**: Clarify user stories, acceptance criteria, edge cases, and out-of-scope boundaries.
   - **Phase 3: Plan (`.specify/templates/plan-template.md`)**: Define technical blueprints, component architecture, and dependencies.
   - **Phase 4: Tasks (`.specify/templates/tasks-template.md`)**: Break work into small, atomic, verifiable steps.
   - **Phase 5: Implement**: Execute tasks one-by-one, verifying against tests at every step.
4. **Commands Available**:
   - `/speckit-constitution`: Check or update project principles.
   - `/speckit-specify`: Generate or update feature specification.
   - `/speckit-plan`: Create architectural implementation plan.
   - `/speckit-tasks`: Break down plan into actionable task checklist.
   - `/speckit-implement`: Step through implementation of tasks.
   - `/speckit-checklist`: Run quality and consistency checklist before delivery.
