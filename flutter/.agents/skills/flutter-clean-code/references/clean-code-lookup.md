# Flutter Clean Code & flutter_it Reference Lookup

Use this guide to find the exact reference documents for any architectural, structural, or code quality task in Flutter/Dart.
All files are located in `references/clean-code/` relative to this skill.

---

## Quick Topic Mapping

### 1. Architecture & Structural Patterns (PFA & flutter_it)
| Topic | Reference File | Key Concepts |
|---|---|---|
| **Pragmatic Architecture (PFA)** | `architecture-layers.md` | Services, Managers, Views, feature layout (`_shared/`, `features/`), Proxy Pattern, DataRepository, Scoped Services, InteractionManager, allReady(), testing |
| **State Management with flutter_it** | `state-management.md` | Exclusive standard: `Command`, `ValueListenable`, `WatchingWidget` |
| **Dependency Injection** | `get-it.md` | `get_it` registration, scopes, async init, singleton vs factory, testing |
| **Reactive UI & Widgets** | `watch-it.md` | `WatchingWidget`, `watchIt()`, `watchPropertyValue()`, micro-rebuilds |
| **Async Operations & Commands** | `command-it.md` | `Command.createAsync()`, automatic isExecuting/errors, restrictions |
| **Functional Reactivity** | `listen-it.md` | ValueListenable operators: `map`, `debounce`, `where`, `combineLatest` |
| **Paged Feeds & Infinite Scroll**| `feed-datasource.md` | `FeedDataSource`, cursor-based pagination, proxy lifecycle |
| **Data Sources & Repositories** | `repository-and-data.md` | Services/Repositories, Remote/Local Sources, DTOs vs Domain Entities |

### 2. Dart Craftsmanship & Code Quality
| Topic | Reference File | Key Concepts |
|---|---|---|
| **Effective Dart & Encapsulation** | `effective-dart.md` | Library-private `_` prefix, immutability, naming, records & patterns |
| **SOLID Principles in Dart** | `solid-principles.md` | SRP, OCP, LSP, ISP, DIP applied with concrete Dart examples |
| **Error Handling & Failures** | `error-handling.md` | Explicit exceptions, `Result<T, Failure>`, sealed class error states |

### 3. Flutter Framework, UI & Performance
| Topic | Reference File | Key Concepts |
|---|---|---|
| **Widget Architecture & Lifecycle** | `widget-lifecycle-ui.md` | `const` performance, widget extraction, avoiding deep nesting, dispose |
| **Performance Optimization** | `performance-optimization.md` | Repaint boundaries, ListView builders, image caching, memory hygiene |
| **Linting & Code Standards** | `linting-and-standards.md` | `analysis_options.yaml`, strict typing, analysis rules |

### 4. Security & Production Readiness
| Topic | Reference File | Key Concepts |
|---|---|---|
| **Security & Secrets Handling** | `security-and-secrets.md` | `--dart-define`, `flutter_secure_storage`, APK decompilation risks, OWASP |
| **Testing Standards** | `testing-standards.md` | Unit testing (Managers/Services), Mocktail/Mockito, Widget testing |

---

## How to Cite References in Code Reviews

When identifying an anti-pattern or guiding a refactor, cite the standard directly:

> **Architecture Standard — PFA**: "Views must never interact with technical services directly. Views observe Managers via `watchPropertyValue` and trigger actions via `Command`."

> **Effective Dart — Encapsulation**: "Private mutable state must be prefixed with `_` and exposed only through unmodifiable getters or immutable streams."
