// lib/models/auth_models.dart

import 'dart:convert'; // For jsonEncode if needed for debugging

// Represents the User object returned by the API
class User {
  final String id;
  final String mobile;
  final String? email;
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt;
  // --- FIX: Make updatedAt nullable ---
  final DateTime? updatedAt;
  // --- End Fix ---
  final String? role;
  final DateTime? lastLogin;

  User({
    required this.id,
    required this.mobile,
    this.email,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    this.updatedAt, // Now optional
    this.role,
    this.lastLogin,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    // Helper for safe date parsing
    DateTime? _parseDateTime(dynamic value) {
      if (value is String && value.isNotEmpty) {
        try {
          return DateTime.parse(value);
        } catch (e) {
          // Optional: Log parse error
          print("Error parsing date: $value, Error: $e");
          return null;
        }
      }
      return null;
    }

    return User(
      id:
          json['id'] as String? ??
          '', // Use ?? '' as fallback if ID could be missing/null but required
      mobile: json['mobile'] as String? ?? '', // Use ?? '' as fallback
      email: json['email'] as String?,
      isActive:
          json['is_active'] as bool? ??
          false, // Default to false if missing/null
      isVerified:
          json['is_verified'] as bool? ??
          false, // Default to false if missing/null
      createdAt:
          _parseDateTime(json['created_at']) ??
          DateTime(1970), // Provide a default/fallback date
      // --- FIX: Handle nullable updatedAt ---
      updatedAt: _parseDateTime(json['updated_at']),
      // --- End Fix ---
      role: json['role'] as String?,
      lastLogin: _parseDateTime(json['last_login']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'email': email,
      'is_active': isActive,
      'is_verified': isVerified,
      'created_at': createdAt.toIso8601String(),
      // --- FIX: Handle nullable updatedAt ---
      'updated_at': updatedAt?.toIso8601String(),
      // --- End Fix ---
      'role': role,
      'last_login': lastLogin?.toIso8601String(),
    };
  }
}

// Represents the overall Authentication Response from the API
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int? expiresIn; // Made nullable for safety
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    this.expiresIn, // Now nullable
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    // Helper for safe int parsing
    int? _parseInt(dynamic value) {
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      if (value is num) return value.toInt(); // Handle potential doubles
      return null;
    }

    return AuthResponse(
      accessToken: json['access_token'] as String? ?? '', // Use fallback
      refreshToken: json['refresh_token'] as String? ?? '', // Use fallback
      tokenType: json['token_type'] as String? ?? 'bearer', // Use fallback
      // --- FIX: Safer parsing for expires_in ---
      expiresIn: _parseInt(json['expires_in']), // Use safe helper, allow null
      // --- End Fix ---
      user: User.fromJson(
        json['user'] as Map<String, dynamic>? ?? {},
      ), // Handle null user map
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'refresh_token': refreshToken,
      'token_type': tokenType,
      'expires_in': expiresIn,
      'user': user.toJson(),
    };
  }
}
