# Linting & Code Standards

> Linting rules, strict typing, and analysis configuration in Flutter & Dart.

---

## 1. Analysis Configuration (`analysis_options.yaml`)

Use strict type checks to catch nullability and typing errors at compile time:

```yaml
include: package:flutter_lints/flutter.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: ignore

linter:
  rules:
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_locals
    - unawaited_futures
    - cancel_subscriptions
    - close_sinks
    - avoid_print
```

---

## 2. Core Lint Enforcements

- **No `avoid_print`**: Use structured logging (`developer.log` or a dedicated logging service) rather than `print()`. Never log sensitive user PII or auth tokens.
- **Strict Null Safety**: Never use `!` unless preceded by an explicit null check in the immediately surrounding code. Prefer `?`, `??`, or pattern matching.
- **Avoid Unawaited Futures**: Mark async operations that run detached with `unawaited(...)` explicitly, or `await` them to handle errors properly.
