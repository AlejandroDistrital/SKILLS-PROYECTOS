# Repository Pattern, Data Sources & Models

> Standardizing data flow, caching, and serialization in Flutter.

---

> **PFA Context**: In simple features, Managers call Services directly — the Repository layer is **optional**, not mandatory. Add it only when there is real complexity: multiple data sources (remote + local cache), offline-first logic, or when the same data access contract needs to be swapped between implementations. Do not introduce a Repository layer just for the sake of Clean Architecture purity.

## 1. The Repository Contract

The **Repository** acts as the mediator between the domain/presentation layer and technical data sources. It provides a clean, domain-focused collection-like interface. Use it when a Manager needs to coordinate ≥2 data sources or offline caching strategy.

```dart
// domain/repositories/delivery_repository.dart
abstract interface class DeliveryRepository {
  Future<List<Delivery>> getActiveDeliveries();
  Future<Delivery> getDeliveryById(String id);
  Future<void> completeDelivery(String id);
}
```

---

## 2. DTO (Data Transfer Object) vs Domain Entity

Never let raw API models or JSON structures leak into the UI or Domain layer.

### Rule:
- **DTO (`*Model`)**: Mirrors API/database format, contains serialization (`fromJson`, `toJson`), handles backend-specific quirks and nullability.
- **Domain Entity**: Pure Dart representation used across business logic and UI presentation. Contains zero JSON annotations.

```dart
// 1. Data Layer: Model / DTO
class DeliveryModel {
  final String id;
  final double amountCents;
  final String rawStatus;

  const DeliveryModel({
    required this.id,
    required this.amountCents,
    required this.rawStatus,
  });

  factory DeliveryModel.fromJson(Map<String, dynamic> json) {
    return DeliveryModel(
      id: json['id'] as String,
      amountCents: (json['amount_cents'] as num).toDouble(),
      rawStatus: json['status'] as String,
    );
  }

  // Mapper to clean Domain Entity
  Delivery toDomain() {
    return Delivery(
      id: id,
      amount: amountCents / 100.0,
      status: DeliveryStatus.fromString(rawStatus),
    );
  }
}

// 2. Domain Layer: Pure Business Entity
class Delivery {
  final String id;
  final double amount;
  final DeliveryStatus status;

  const Delivery({
    required this.id,
    required this.amount,
    required this.status,
  });
}
```

---

## 3. Coordinating Remote & Local Data Sources

The repository decides whether to fetch from local storage (offline-first / cache) or make a network call:

```dart
class DeliveryRepositoryImpl implements DeliveryRepository {
  final DeliveryRemoteDataSource _remote;
  final DeliveryLocalDataSource _local;

  const DeliveryRepositoryImpl({
    required DeliveryRemoteDataSource remote,
    required DeliveryLocalDataSource local,
  })  : _remote = remote,
        _local = local;

  @override
  Future<Result<List<Delivery>, Failure>> getActiveDeliveries() async {
    try {
      final models = await _remote.fetchActiveDeliveries();
      await _local.cacheDeliveries(models);
      return Result.ok(models.map((m) => m.toDomain()).toList());
    } catch (e) {
      // Offline fallback: load from local cache
      final cachedModels = await _local.getCachedDeliveries();
      if (cachedModels.isEmpty) {
        return Result.error(const CacheFailure('No deliveries available offline'));
      }
      return Result.ok(cachedModels.map((m) => m.toDomain()).toList());
    }
  }
}
```
