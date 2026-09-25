# Flutter Clean Code Skill

Production-grade architectural standard and code reviewer for Flutter & Dart applications. Grounded in the official Flutter Architecture guidelines, Effective Dart, and Clean Code principles.

Mirrors the professional review structure and systematic methodology of the Apple Design skill.

---

## What It Does

- **Clean Code & Architectural Audit** — Systematic evaluation against modular guidelines covering layer separation, state management, repository patterns, encapsulation, and error handling.
- **Actionable Refactoring Guides** — Concrete, copy-pasteable before-and-after Dart patterns replacing anti-patterns with SOLID designs.
- **Production Security Review** — Protection against APK/IPA decompilation, safe compilation flags (`--dart-define`), and hardware-backed storage (`flutter_secure_storage`).
- **Performance & Lifecycle Hygiene** — Elimination of memory leaks, uncontrolled widget rebuilds, and missing controller disposals.
- **Comprehensive Testing Verification** — Unit testing for ViewModels/Repositories and dependency injection patterns.

---

## Skill Architecture

```
flutter-clean-code/
├── SKILL.md                          # Core review methodology, audit lenses, and severity framework
├── README.md                         # Overview and quick-start guide
└── references/
    ├── clean-code-lookup.md          # Topic routing table
    └── clean-code/                   # Reference guideline documents
        ├── architecture-layers.md    # Feature-first, Presentation/Domain/Data separation
        ├── effective-dart.md         # Encapsulation (_), immutability, sealed classes
        ├── widget-lifecycle-ui.md    # const constructors, widget extraction, disposal
        ├── state-management.md       # Unidirectional data flow, state modeling
        ├── repository-and-data.md    # Repositories, DTO vs Domain Entity mapping
        ├── security-and-secrets.md   # Secrets, secure storage, and OWASP mobile rules
        ├── error-handling.md         # Result types, fail-closed handling
        └── testing-standards.md      # DI, Mocktail, unit and widget test patterns
```

---

## Quick Usage

When auditing or asking for architectural recommendations:
- *"Audit this Flutter screen for Clean Code and layer leaks"*
- *"Refactor this ViewModel to follow the Repository pattern and Clean Architecture"*
- *"Check my Flutter state management and lifecycle for memory leaks"*
- *"Review this feature against the Flutter Clean Code skill"*
