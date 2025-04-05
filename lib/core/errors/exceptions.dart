// lib/core/errors/exceptions.dart

/// Base class for application-specific exceptions.
class AppException implements Exception {
  final String? message;
  final StackTrace? stackTrace;

  const AppException([this.message, this.stackTrace]);

  @override
  String toString() {
    String result = 'AppException';
    if (message != null) result = '$result: $message';
    // Note: Stack trace isn't typically included in user-facing messages
    return result;
  }
}

// --- Specific Exception Types ---

/// Exception for when an account is not found (e.g., 404 on login)
class AccountNotFoundException extends AppException {
  const AccountNotFoundException([
    super.message =
        'Account not found. Please ensure the phone number is registered.',
    super.stackTrace,
  ]);
}

/// Exception for invalid credentials or tokens (e.g., 401, 403)
class InvalidCredentialsException extends AppException {
  const InvalidCredentialsException([
    super.message =
        'Authentication failed. Please check credentials or try again.',
    super.stackTrace,
  ]);
}

/// Exception for network-related issues (timeout, no connection)
class NetworkException extends AppException {
  const NetworkException([
    super.message =
        'Network error. Please check your connection and try again.',
    super.stackTrace,
  ]);
}

/// Exception for general server errors (e.g., 5xx)
class BackendServerException extends AppException {
  const BackendServerException([
    super.message = 'An error occurred on the server. Please try again later.',
    super.stackTrace,
  ]);
}

/// Exception for unexpected errors during processing
class UnexpectedErrorException extends AppException {
  const UnexpectedErrorException([
    super.message = 'An unexpected error occurred.',
    super.stackTrace,
  ]);
}

class BadRequestException extends AppException {
  const BadRequestException([
    super.message = 'Invalid request data or state.',
    super.stackTrace,
  ]);
}

// Add other specific exception types as needed...
