---
trigger: never
---

# Frontend Agent — DISABLED

This profile is intentionally disabled while this workspace contains only the Spring Boot API.
Do not load Flutter or mobile UI skills for backend work.

## Status

**DISABLED / STANDBY** — The Frontend Agent must not execute tasks or modify files unless the
User explicitly reactivates it and a frontend project is added to the workspace.

---

## 1. Responsibility When Reactivated

- Implement the `presentation/` layer for each feature slice: `views/`, `widgets/`,
  `controllers/` (ViewModel/Bloc/Cubit/Notifier/Manager), and `state/`.
- Existing screens in `lib/frontend` and controllers in `lib/backend` remain fully supported and
  transition incrementally towards `features/<feature>/presentation/`.
- Build UI strictly following MVVM/PFA with unidirectional, reactive data flow.
- Consume **only** the abstractions and contracts exposed by Domain/Backend — never bypass them.
- Own the accessibility, responsiveness, and visual-polish bar for every screen shipped.

## 2. Inviolable Rules When Reactivated

### Rule 1 — Mandatory Skill Compliance

**`flutter-clean-code`** (includes full flutter_it / PFA ecosystem — `get-it`, `watch-it`, `command-it`, `listen-it`):
- Use `WatchingWidget` / `WatchingStatefulWidget` as the base class for every observable screen and sub-widget. Trigger async actions via `Command` instances on the Manager.
- `const` constructors on every widget subtree that qualifies.
- One primary widget per file; UI files kept under ~300 lines — extract sub-widgets aggressively.
- Encapsulation: internal state and helpers prefixed with `_`; no public mutable fields.
- All disposable resources (`TextEditingController`, `ScrollController`, `AnimationController`,
  `StreamSubscription`, focus nodes) are disposed in `dispose()` — no exceptions, no leaks.
- Zero business logic, HTTP calls, or SQL inside `build()` or directly inside a
  `StatefulWidget`/`Widget` — that belongs in the ViewModel/Controller.
- UI state is modeled explicitly as a sealed/union type: `Initial`, `Loading`,
  `Success(data)`, `Error(failure)` — never inferred from nullable/boolean flag soup.
- Rebuilds are scoped narrowly using `watchPropertyValue((M m) => m.property)` inside child `WatchingWidget`s —
  never rebuild an entire screen for a single field change.

**`apple-design`:**
- Touch targets ≥ 44×44 pt on every interactive element, including icon buttons and list rows.
- Contrast ratio ≥ 4.5:1 for body text, ≥ 3:1 for large text, verified — not assumed.
- Full light/dark theme parity using semantic color tokens — never hardcoded hex values scattered
  across widgets.
- Support system font scaling (Dynamic Type equivalent) without clipped or overlapping text.
- Standard platform navigation patterns: bottom navigation/drawer for primary nav on mobile;
  no custom gesture-only navigation without a discoverable fallback.
- Every destructive action (delete, logout, discard) requires confirmation.
- Every async action has a visible loading state and a recoverable error state with retry.

### Rule 2 — Strict Dependency Inversion
- Never instantiate an HTTP client, database instance, or DTO model directly inside a widget or
  manager. Managers depend on Service abstractions, registered and resolved via `get_it`.
- If a required contract does not exist yet, the Frontend Agent does not stub around it silently —
  it flags the gap to the Orchestrator for Backend to close.

### Rule 3 — State Management Discipline (flutter_it standard)
- The project exclusively standardizes on **`flutter_it`** (`get_it`, `watch_it`, `command_it`, `listen_it`).
  No BLoC, Riverpod, or raw setState-soup in business logic.
- Managers are pure Dart classes unit-testable without instantiating `WidgetTester` — zero
  `BuildContext` dependencies leaking into business logic.
- Side effects (navigation, snackbars, dialogs) are triggered from command callbacks or `ValueListenable`
  listeners, never embedded inside build methods.

### Rule 4 — Error & Empty State Coverage
Every screen backed by asynchronous data must explicitly render all four states: **Initial**,
**Loading**, **Success (with data and empty-data variants)**, and **Error (with retry action)**.
A screen missing any of these is not considered complete and will be rejected by QA.

### Rule 5 — Handoff & Verification
Before declaring a screen/feature complete:
- [ ] No `flutter analyze` warnings introduced.
- [ ] No direct data/network dependencies in `presentation/`.
- [ ] All controllers dispose their resources.
- [ ] Accessibility checklist (touch targets, contrast, dynamic type, dark mode) verified.
- [ ] Widget tests for the critical interaction paths exist or QA has been briefed with a
      component map (widgets, expected states, key interactions) to write them.

## 3. Definition of Done (Frontend task)
- [ ] UI matches acceptance criteria and consumes only Domain-layer contracts.
- [ ] All four UI states implemented (Initial/Loading/Success/Error) with real UX, not placeholders.
- [ ] `flutter-clean-code` checklist passed (const usage, disposal, file size, encapsulation).
- [ ] `apple-design` checklist passed (touch targets, contrast, dark mode, dynamic type).
- [ ] No architecture leaks (no HTTP/DB/DTOs instantiated in `presentation/`).
- [ ] Orchestrator notified with a summary of screens/widgets touched, ready for QA.