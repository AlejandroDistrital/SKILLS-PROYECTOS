# Flutter Security, Secrets & OWASP Mobile Standards

> Rules for preventing secret leakage, insecure storage, and vulnerabilities in Flutter applications.

---

## 1. Secrets in Compiled Binaries: Absolute Rule

> **Any string compiled into an APK or IPA can be extracted within minutes using basic decompilation tools (jadx, strings, Hopper, Ghidra).**

- **Never** store backend API secrets, private keys, database passwords, or payment credentials in Dart code.
- Configuration keys (e.g. Firebase options, public analytics keys) should be injected via `--dart-define` or `--dart-define-from-file`, never checked into Git in plain files.

```bash
# Build with secure compile-time variables
flutter build apk --dart-define-from-file=config/env.json
```

```dart
// Accessing compile-time environment configuration
abstract final class EnvironmentConfig {
  static const apiBaseUrl = String.fromEnvironment(
    'API_BASE_URL',
    defaultValue: 'https://api.example.com',
  );
}
```

---

## 2. Insecure Data Storage: Tokens & Credentials

- **Prohibited**: Saving auth tokens, session cookies, passwords, or PII into standard `SharedPreferences`. `SharedPreferences` saves unencrypted XML/plist files on disk.
- **Mandatory**: Use `flutter_secure_storage` to write sensitive items to the OS-managed secure storage (**Android KeyStore** with AES encryption and **iOS Keychain**; hardware-backed protection is device- and configuration-dependent).

```dart
abstract interface class SecureStorageService {
  Future<void> saveAuthToken(String token);
  Future<String?> getAuthToken();
  Future<void> clearAuthToken();
}

class FlutterSecureStorageServiceImpl implements SecureStorageService {
  final FlutterSecureStorage _storage;

  const FlutterSecureStorageServiceImpl(this._storage);

  static const _tokenKey = 'auth_session_token';

  @override
  Future<void> saveAuthToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  @override
  Future<String?> getAuthToken() async {
    return _storage.read(key: _tokenKey);
  }

  @override
  Future<void> clearAuthToken() async {
    await _storage.delete(key: _tokenKey);
  }
}
```

---

## 3. Network Security & HTTPS

- Ensure all network calls use HTTPS/TLS.
- Never disable certificate verification (`badCertificateCallback = (cert, host, port) => true`) in production code.
- Implement network interceptors that automatically attach authentication headers without exposing tokens to UI widgets.
