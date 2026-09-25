# SOLID Principles in Dart & Flutter

> Practical application of SOLID design principles in idiomatic Dart.

---

## 1. Single Responsibility Principle (SRP)
*A class should have one, and only one, reason to change.*

- **In Flutter**: Keep widgets responsible only for layout and user interaction. Business logic, network requests, and persistence belong in dedicated Services, UseCases, or Managers.
- **Anti-Pattern**: A `ProfileScreen` StatefulWidget that builds UI, executes HTTP POST calls, parses JSON responses, and caches the avatar image to SQLite.
- **Clean Pattern**:
  - `ProfileView`: Renders UI and invokes manager commands.
  - `ProfileManager`: Orchestrates state and triggers data operations.
  - `UserApiService`: Handles remote HTTP communication.
  - `UserLocalCache`: Handles SQLite or SecureStorage operations.

---

## 2. Open/Closed Principle (OCP)
*Software entities should be open for extension, but closed for modification.*

- **In Dart**: Use abstract classes, sealed interfaces, and composition instead of massive `switch`/`if-else` chains on concrete types across multiple files.
- **Example**:
  ```dart
  abstract interface class PaymentGateway {
    Future<PaymentResult> processPayment(double amount);
  }

  class StripeGateway implements PaymentGateway {
    @override
    Future<PaymentResult> processPayment(double amount) async {
      // Stripe-specific logic
      return PaymentResult.success();
    }
  }

  class NequiGateway implements PaymentGateway {
    @override
    Future<PaymentResult> processPayment(double amount) async {
      // Nequi-specific logic
      return PaymentResult.success();
    }
  }
  ```

---

## 3. Liskov Substitution Principle (LSP)
*Subtypes must be substitutable for their base types without altering program correctness.*

- **In Dart**: When implementing an interface, never throw `UnimplementedError()` for methods the subtype "doesn't need", and never silently fail to deliver the contract's guarantee.
- If a subtype cannot implement all methods meaningfully, the interface is too fat (violating ISP).

---

## 4. Interface Segregation Principle (ISP)
*Clients should not be forced to depend on interfaces they do not use.*

- **In Dart**: Prefer small, focused interfaces rather than god interfaces.
- **Example**:
  ```dart
  // Bad: Fat interface forces unnecessary implementations
  abstract interface class OrderRepository {
    Future<List<Order>> getOrders();
    Future<void> saveOrder(Order order);
    Future<void> printReceipt(Order order); // Hardware concern!
    Future<void> syncWithCloud(); // Network sync concern!
  }

  // Good: Segregated, focused contracts
  abstract interface class OrderReader {
    Future<List<Order>> getOrders();
  }

  abstract interface class OrderWriter {
    Future<void> saveOrder(Order order);
  }

  abstract interface class ReceiptPrinter {
    Future<void> printReceipt(Order order);
  }
  ```

---

## 5. Dependency Inversion Principle (DIP)
*High-level modules should not depend on low-level modules. Both should depend on abstractions.*

- **In Flutter**: UI ViewModels, Managers, and UseCases must depend on abstract repository interfaces (`abstract interface class DeliveryRepository`), never on concrete implementations (`DeliveryRepositoryImpl`, `DioClient`, `DriftDatabase`).
- Dependencies are injected via constructor injection or Service Locator (`get_it`).
