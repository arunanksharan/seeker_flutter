// lib/core/config.dart
class AppConfig {
  // API URL loaded from build environment variable or default
  static const String apiUrl = String.fromEnvironment(
    'API_URL',
    defaultValue: 'https://api.itihiring.in', // Default from app.config.js
  );

  // API Timeout constant
  static const int apiTimeoutMs = 30000; // 30 seconds

  // Google Client ID loaded from build environment variable
  // Note: Might return empty string if not defined during build.
  // Handle potentially empty string where you use it.
  static const String googleClientId = String.fromEnvironment(
    'GOOGLE_CLIENT_ID',
    defaultValue: '', // Provide an empty default or handle null case
  );

  // EAS Project ID (might be useful for other services or logging)
  static const String easProjectId = String.fromEnvironment(
    'EAS_PROJECT_ID',
    // Default from app.config.js (optional)
    defaultValue: '7fbd8e64-55ff-47b1-b04a-41d386600a8a',
  );
}

// How to run with multiple --dart-define flags:
// flutter run \
//   --dart-define=API_URL=http://localhost:8001 \
//   --dart-define=GOOGLE_CLIENT_ID=YOUR_GOOGLE_CLIENT_ID_HERE \
//   --dart-define=EAS_PROJECT_ID=YOUR_EAS_ID_HERE
