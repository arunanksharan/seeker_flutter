// lib/services/token_service.dart
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:seeker_flutter/utils/logger.dart'; // Your logger

class TokenService {
  final _storage = const FlutterSecureStorage(
    // Optional: Configure Android/iOS options if needed
    // aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );
  final String _accessTokenKey = 'seeker_access_token';
  final String _refreshTokenKey = 'seeker_refresh_token';

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    try {
      await _storage.write(key: _accessTokenKey, value: accessToken);
      await _storage.write(key: _refreshTokenKey, value: refreshToken);
      logger.d('Tokens saved securely.');
    } catch (e) {
      logger.e('Failed to save tokens', error: e);
      // Consider throwing a custom exception
    }
  }

  Future<String?> getAccessToken() async {
    try {
      return await _storage.read(key: _accessTokenKey);
    } catch (e) {
      logger.e('Failed to read access token', error: e);
      return null;
    }
  }

  Future<String?> getRefreshToken() async {
    try {
      return await _storage.read(key: _refreshTokenKey);
    } catch (e) {
      logger.e('Failed to read refresh token', error: e);
      return null;
    }
  }

  Future<void> clearTokens() async {
    try {
      await _storage.delete(key: _accessTokenKey);
      await _storage.delete(key: _refreshTokenKey);
      logger.d('Tokens cleared.');
    } catch (e) {
      logger.e('Failed to clear tokens', error: e);
    }
  }
}
