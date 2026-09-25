# Flutter Testing Standards & Testability

> Unit, widget, and integration testing standards for clean Flutter codebases.

---

## 1. Testing Pyramid for Flutter

```
        / \
       /   \        Integration Tests (Critical user journeys)
      /=====\
     / Widget\      Widget Tests (UI component interaction & state rendering)
    /=========\
   / Unit Tests\    Unit Tests (ViewModels, Repositories, Use Cases, Models)
  /─────────────\
```

---

## 2. Testability Rule: Dependency Injection

To make classes testable, pass dependencies via constructor parameters rather than instantiating them internally or relying on global singletons:

```dart
// ✅ PRIMARY (PFA / flutter_it): use get_it scopes to swap real services with mocks
setUp(() {
  GetIt.I.pushNewScope(
    init: (scope) {
      scope.registerSingleton<AuthRepository>(MockAuthRepository());
    },
  );
});

tearDown(() async {
  await GetIt.I.popScope();
});

// Manager under test resolves its deps from get_it — no constructor change needed
final manager = di<AuthManager>();
```

```dart
// ✅ ALTERNATIVE: constructor injection (simpler for pure-Dart unit tests
// where the class has no get_it dependencies at all)
class AuthViewModel extends ChangeNotifier {
  final AuthRepository _repository;

  AuthViewModel({required AuthRepository repository}) : _repository = repository;
}
```

---

## 3. Writing Unit Tests with Mocktail / Mockito

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockRepository;
  late AuthViewModel viewModel;

  setUp(() {
    mockRepository = MockAuthRepository();
    viewModel = AuthViewModel(repository: mockRepository);
  });

  group('AuthViewModel - login', () {
    test('emits authenticated state when repository succeeds', () async {
      const user = User(id: '123', email: 'test@example.com');
      when(() => mockRepository.login(email: 'test@example.com', password: 'secret'))
          .thenAnswer((_) async => user);

      await viewModel.login('test@example.com', 'secret');

      expect(viewModel.state, isA<Authenticated>());
      verify(() => mockRepository.login(email: 'test@example.com', password: 'secret')).called(1);
    });

    test('emits error state when repository throws exception', () async {
      when(() => mockRepository.login(email: any(named: 'email'), password: any(named: 'password')))
          .thenThrow(const NetworkException('Connection failed'));

      await viewModel.login('test@example.com', 'bad_pass');

      expect(viewModel.state, isA<AuthError>());
    });
  });
}
```
