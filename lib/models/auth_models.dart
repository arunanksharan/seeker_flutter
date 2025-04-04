// Based on seeker-rn-files/types/auth.ts

// Represents the User object returned by the API
class User {
  final int id;
  final String mobile;
  final String? email; // Nullable string
  final bool isActive;
  final bool isVerified;
  final DateTime createdAt; // Use DateTime for dates
  final DateTime updatedAt; // Use DateTime for dates
  // final String? role; // Present in CurrentUserResponse in api-interfaces.ts
  // final DateTime? lastLogin; // Present in CurrentUserResponse

  User({
    required this.id,
    required this.mobile,
    this.email,
    required this.isActive,
    required this.isVerified,
    required this.createdAt,
    required this.updatedAt,
    // this.role,
    // this.lastLogin,
  });

  // Factory constructor to create a User from JSON
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] as int,
      mobile: json['mobile'] as String,
      email: json['email'] as String?,
      isActive: json['is_active'] as bool,
      isVerified: json['is_verified'] as bool,
      // Parse ISO 8601 date strings into DateTime objects
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      // role: json['role'] as String?, // Uncomment if adding from api-interfaces.ts
      // lastLogin: json['last_login'] == null ? null : DateTime.parse(json['last_login'] as String), // Uncomment
    );
  }

  // Method to convert User object to JSON (useful for sending data)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'mobile': mobile,
      'email': email,
      'is_active': isActive,
      'is_verified': isVerified,
      // Convert DateTime objects back to ISO 8601 strings
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
      // 'role': role, // Uncomment if adding
      // 'last_login': lastLogin?.toIso8601String(), // Uncomment
    };
  }
}

// Represents the overall Authentication Response from the API
class AuthResponse {
  final String accessToken;
  final String refreshToken;
  final String tokenType;
  final int expiresIn; // Duration in seconds
  final User user;

  AuthResponse({
    required this.accessToken,
    required this.refreshToken,
    required this.tokenType,
    required this.expiresIn,
    required this.user,
  });

  // Factory constructor to create an AuthResponse from JSON
  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    return AuthResponse(
      // Map keys from snake_case (API) to camelCase (Dart convention)
      accessToken: json['access_token'] as String,
      refreshToken: json['refresh_token'] as String,
      tokenType: json['token_type'] as String,
      expiresIn: json['expires_in'] as int,
      user: User.fromJson(json['user'] as Map<String, dynamic>),
    );
  }

  // Method to convert AuthResponse object to JSON
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

// Note: We don't typically need separate classes for simple request payloads like
// LoginRequest, OTPRequest, OTPVerify, RegisterRequest etc. unless they become complex.
// Often, a Map<String, dynamic> is sufficient when sending data to the service layer.
// However, defining them can provide better type safety if preferred.

// Example for RegisterRequest if needed:
// class RegisterRequest {
//   final String mobile;
//   final String? email;
//
//   RegisterRequest({required this.mobile, this.email});
//
//   Map<String, dynamic> toJson() => {
//         'mobile': mobile,
//         if (email != null) 'email': email,
//       };
// }

// We don't need AuthState defined here, as that relates to UI state management (Riverpod/Bloc)
// We don't need TokenPayload here, as JWT parsing is usually handled internally by auth logic or backend.
