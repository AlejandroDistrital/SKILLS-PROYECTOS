# Error Handling, Exceptions & Result Types

> Handling exceptional conditions reliably and explicitly in Flutter.

---

## 1. Fail Closed, Never Swallow Errors

Empty catch blocks violate both clean code standards and global security rules:

```dart
// FORBIDDEN: Silent failure
try {
  await repository.syncData();
} catch (e) {
  // Silent ignore: bugs hide here
}

// CLEAN (flutter_it): Errors flow through Command.errors automatically.
// In Managers, wrap the operation in a Command — no manual notifyListeners() needed:
late final syncCommand = Command.createAsyncNoParamNoResult(
  () => _repository.syncData(),
  // Command auto-sets isExecuting, errors, and result on every run
);

// CLEAN (Service/non-Command context): Explicit typed failure propagation
Future<Result<void, Failure>> syncData() async {
  try {
    await _api.syncData();
    return const Result.ok(null);
  } on NetworkException catch (e, stackTrace) {
    _logger.warning('Sync failed due to network', e, stackTrace);
    return Result.error(NetworkFailure(e.message));
  } catch (e, stackTrace) {
    _logger.error('Unexpected sync failure', e, stackTrace);
    return Result.error(const UnknownFailure());
  }
}
```

---

## 2. Typed Failures & Result Pattern

Instead of throwing unhandled exceptions across architecture layers, return a typed `Result` or `Either`:

```dart
sealed class Result<T> {
  const Result();
}

final class Success<T> extends Result<T> {
  final T data;
  const Success(this.data);
}

final class Failure<T> extends Result<T> {
  final AppError error;
  const Failure(this.error);
}

// Usage in Repository:
Future<Result<List<Delivery>>> getDeliveries() async {
  try {
    final list = await _api.fetchDeliveries();
    return Success(list.map((e) => e.toDomain()).toList());
  } on SocketException {
    return const Failure(NetworkError('No internet connection'));
  } on ServerException catch (e) {
    return Failure(ServerError(e.message));
  }
}
```

This guarantees the ViewModel or Presentation layer explicitly accounts for failure states at compile-time.
