// lib/services/token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seeker/utils/logger.dart'; // Your logger

class TokenService {
  // Create storage instance with optional Android encryption
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  // Define keys for storing tokens
  final String _accessTokenKey = 'seeker_access_token';
  final String _refreshTokenKey = 'seeker_refresh_token';

  /// Saves both access and refresh tokens securely.
  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      // Input validation (optional but good practice)
      if (accessToken.isEmpty || refreshToken.isEmpty) {
        logger.w('Attempted to save empty tokens.');
        // Depending on requirements, either throw an error or just log and return
        // throw ArgumentError('Access token and refresh token cannot be empty.');
        return;
      }
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      logger.d('Tokens saved securely.');
    } catch (e, stackTrace) {
      logger.e('Failed to save tokens', error: e, stackTrace: stackTrace);
      // Re-throw or handle as appropriate for your app's error strategy
      // throw Exception('Could not save authentication tokens.');
    }
  }

  /// Retrieves the stored access token. Returns null if not found or on error.
  Future<String?> getAccessToken() async {
    try {
      final token = await _storage.read(key: _accessTokenKey);
      logger.d(
        'Access token retrieved: ${token != null ? "Exists" : "Not Found"}',
      );
      return token;
    } catch (e, stackTrace) {
      logger.e('Failed to read access token', error: e, stackTrace: stackTrace);
      return null; // Return null on error to indicate token unavailability
    }
  }

  /// Retrieves the stored refresh token. Returns null if not found or on error.
  Future<String?> getRefreshToken() async {
    try {
      final token = await _storage.read(key: _refreshTokenKey);
      logger.d(
        'Refresh token retrieved: ${token != null ? "Exists" : "Not Found"}',
      );
      return token;
    } catch (e, stackTrace) {
      logger.e(
        'Failed to read refresh token',
        error: e,
        stackTrace: stackTrace,
      );
      return null; // Return null on error
    }
  }

  /// Deletes both access and refresh tokens from secure storage.
  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      logger.d(
        'Tokens cleared from secure storage.',
      ); // Use info level for successful clearing
    } catch (e, stackTrace) {
      logger.e('Failed to clear tokens', error: e, stackTrace: stackTrace);
      // Consider if you need to re-throw this error
    }
  }
}

// Reminder: Ensure flutter_secure_storage is added to your pubspec.yaml
// dependencies:
//   flutter_secure_storage: ^9.2.2 # Check latest version
