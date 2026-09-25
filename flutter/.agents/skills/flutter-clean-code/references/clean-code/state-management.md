# State Management Standards: flutter_it (Commands & ValueListenable)

> The official and exclusive state management standard for this project: **flutter_it** (`get_it`, `watch_it`, `command_it`, `listen_it`).

---

## 1. Core Architecture: PFA (Pragmatic Flutter Architecture)

State management in this workspace is organized into three clean layers:

1. **Services** (External boundaries):
   - Wrap raw technical APIs (REST, SQLite, Secure Storage, Location).
   - Convert data from/to DTOs and Domain Entities.
   - **Do NOT hold application UI state.**
2. **Managers** (Business logic & state holders):
   - Registered in `get_it`.
   - Wrap domain operations and manage data freshness.
   - Expose **`Command`** objects for async actions (automatic loading, success, and error states).
   - Expose **`ValueListenable`** / `ValueNotifier` for reactive properties.
3. **Views / Widgets** (UI presentation):
   - Extend **`WatchingWidget`** or **`WatchingStatefulWidget`**.
   - Read reactive data with `watchPropertyValue((m) => m.property)` or `watchIt<Manager>()`.
   - Trigger actions via `manager.someCommand()`.

---

## 2. The Command Pattern (command_it)

Forget manual `isLoading = true; notifyListeners(); try { ... } catch { ... }` boilers. Every async action is an object:

```dart
class DeliveryManager {
  final DeliveryService _service;

  // The command automatically manages executing, error, and value states
  late final Command<void, List<Delivery>> fetchDeliveriesCommand;
  late final Command<String, void> completeDeliveryCommand;

  DeliveryManager(this._service) {
    fetchDeliveriesCommand = Command.createAsyncNoParam(
      () => _service.getDeliveries(),
      initialValue: const [],
    );

    completeDeliveryCommand = Command.createAsync(
      (id) => _service.completeDelivery(id),
    );
  }
}
```

---

## 3. Reactive UI with WatchingWidget (watch_it)

Widgets bind directly to Manager state with zero boilerplate:

```dart
class DeliveryListView extends WatchingWidget {
  const DeliveryListView({super.key});

  @override
  Widget build(BuildContext context) {
    // Selectively rebuild only when deliveries or isExecuting changes
    final manager = di<DeliveryManager>();
    final isExecuting = watchPropertyValue((DeliveryManager m) => m.fetchDeliveriesCommand.isExecuting);
    final deliveries = watchPropertyValue((DeliveryManager m) => m.fetchDeliveriesCommand.value);
    final error = watchPropertyValue((DeliveryManager m) => m.fetchDeliveriesCommand.errors.value);

    if (isExecuting && deliveries.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    if (error != null) {
      return ErrorRetryWidget(
        message: error.toString(),
        onRetry: manager.fetchDeliveriesCommand.execute,
      );
    }

    return ListView.builder(
      itemCount: deliveries.length,
      itemBuilder: (context, index) => DeliveryCard(delivery: deliveries[index]),
    );
  }
}
```

---

## 4. Prohibited Legacy Patterns

To prevent confusion and redundant architectures, the following are **strictly prohibited** in new features:
- **No BLoC / Cubit**: Do not introduce `BlocProvider`, `BlocBuilder`, or event-state classes.
- **No Riverpod**: Do not use `WidgetRef`, `ProviderScope`, or `@riverpod` annotations.
- **No raw `setState` for business logic**: Local UI-only animation state is fine in `StatefulWidget`; domain/business state must reside in Managers.
