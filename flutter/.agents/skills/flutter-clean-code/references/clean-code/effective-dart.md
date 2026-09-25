# Effective Dart & Clean Dart Coding Standards

> Source: [Dart Style Guide](https://dart.dev/guides/language/effective-dart) & Clean Code in Dart.

---

## 1. Encapsulation: Library-Private by Default

Unlike languages with explicit `private`, `protected`, and `public` keywords, Dart utilizes library-level encapsulation via the underscore `_` prefix:

- **A leading `_` = Library-Private**: Only accessible within the declaring `.dart` file.
- **No `_` = Public**: Exported and accessible by any importer.

### Rule of Clean Encapsulation:
Always make internal state, controllers, listeners, and private helper functions library-private:

```dart
// Bad: Leaking mutable state and controller to the outside world
class ProfileViewModel extends ChangeNotifier {
  List<Item> items = []; // Can be modified from anywhere without notifying listeners
  TextEditingController searchCtrl = TextEditingController();
}

// Good: Strictly encapsulated state with read-only exposure
class ProfileViewModel extends ChangeNotifier {
  final List<Item> _items = [];
  late final TextEditingController _searchController;

  ProfileViewModel() {
    _searchController = TextEditingController();
  }

  // Expose unmodifiable view or copy
  List<Item> get items => List.unmodifiable(_items);

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }
}
```

---

## 2. Immutability & Modern Dart Features

### A. Prefer `final` and Immutable Classes
Always mark classes that represent state, configuration, or business data as `@immutable` with `final` fields:

```dart
import 'package:flutter/foundation.dart';

@immutable
class UserEntity {
  final String id;
  final String email;
  final DateTime createdAt;

  const UserEntity({
    required this.id,
    required this.email,
    required this.createdAt,
  });

  UserEntity copyWith({
    String? id,
    String? email,
    DateTime? createdAt,
  }) {
    return UserEntity(
      id: id ?? this.id,
      email: email ?? this.email,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
```

### B. Use Dart 3 Sealed Classes for State Modeling
Represent UI and business states using `sealed class` hierarchies. This enables exhaustive compile-time pattern matching with `switch`:

```dart
sealed class FetchState<T> {
  const FetchState();
}

final class Initial<T> extends FetchState<T> {
  const Initial();
}

final class Loading<T> extends FetchState<T> {
  const Loading();
}

final class Success<T> extends FetchState<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends FetchState<T> {
  final String message;
  const Failure(this.message);
}

// In the UI View Widget:
Widget build(BuildContext context) {
  return switch (state) {
    Initial() => const SizedBox.shrink(),
    Loading() => const Center(child: CircularProgressIndicator()),
    Success(:final data) => DataListWidget(data: data),
    Failure(:final message) => ErrorNotice(message: message),
  };
}
```

---

## 3. Clean Naming & Function Conventions

- **Clear, Descriptive Names**: Avoid abbreviations (`usrRepo`, `calc`, `tmp`). Use `UserRepository`, `calculateOrderTotal`, `currentSessionCache`.
- **Function Size**: Functions should do one thing and fit within 20–30 lines. If a function requires scrolling to read, break it into private helper methods or dedicated classes.
- **Avoid Magic Numbers**:
  ```dart
  // Bad
  SizedBox(height: 16.0);
  
  // Good
  SizedBox(height: AppSpacing.md);
  ```
- **Avoid `dynamic`**: Explicitly type all variables, method parameters, and returns. Never leave un-typed maps or responses like `Future<dynamic>`.
