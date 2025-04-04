// lib/core/config.dart
class AppConfig {
  // TODO: Replace with a proper configuration mechanism (e.g., --dart-define)
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    // Default value used if --dart-define=API_URL=... is not provided
    defaultValue: 'https://api.itihiring.in',
  );
  static const int apiTimeoutMs = 30000; // 30 seconds
}

// How to run with --dart-define:
// flutter run --dart-define=API_URL=http://localhost:8001
