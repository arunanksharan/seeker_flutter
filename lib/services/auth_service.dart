// lib/services/auth_service.dart
import 'dart:async'; // For Completer
import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart'
    as fb_auth; // Alias FirebaseAuth
import 'package:seeker/models/auth_models.dart'; // Your AuthResponse and User models
import 'package:seeker/services/token_service.dart';
import 'package:seeker/utils/logger.dart';
import 'package:seeker/core/errors/exceptions.dart';

class AuthService {
  final Dio _dio; // Main Dio instance from provider
  final TokenService _tokenService;
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;

  AuthService(this._dio, this._tokenService);

  // Add methods for authentication here
  // 1. requestOtp
  Future<String?> requestOtp(String phoneNumber) async {
    final Completer<String?> completer = Completer();
    String? verificationId;

    try {
      // Assuming phoneNumber is already E.164 compliant based on login screen logic
      final formattedNumber = phoneNumber;

      logger.i('Requesting Firebase OTP for: $formattedNumber');

      // Add reCAPTCHA verification for web/android
      await _firebaseAuth.verifyPhoneNumber(
        phoneNumber: formattedNumber,
        timeout: const Duration(seconds: 60),
        verificationCompleted: (fb_auth.PhoneAuthCredential credential) async {
          logger.i('Firebase verification completed automatically.');
          // Optional: Handle auto-retrieval if desired
        },
        verificationFailed: (fb_auth.FirebaseAuthException e) {
          logger.e('Firebase verification failed', error: e);

          // Add better error handling for common issues
          String errorMessage = 'Phone verification failed';
          if (e.code == 'missing-client-identifier') {
            errorMessage = 'App verification failed. Please try again later.';
          } else if (e.code == 'invalid-phone-number') {
            errorMessage = 'The phone number format is invalid.';
          } else if (e.code == 'too-many-requests') {
            errorMessage = 'Too many requests. Please try again later.';
          }

          // Map Firebase exception to a custom one if needed
          if (!completer.isCompleted)
            completer.completeError(Exception(errorMessage));
        },
        codeSent: (String verId, int? resendToken) {
          logger.i('Firebase code sent. Verification ID: $verId');
          verificationId = verId;
          if (!completer.isCompleted) {
            completer.complete(verificationId); // Complete with verification ID
          }
        },
        codeAutoRetrievalTimeout: (String verId) {
          logger.w(
            'Firebase auto-retrieval timed out. Verification ID: $verId',
          );
          // Only complete if not already completed by codeSent
          if (!completer.isCompleted && verificationId == null) {
            verificationId = verId;
            completer.complete(verificationId);
          }
        },
        // Add forceResendingToken if you implement resend functionality
      );

      return await completer.future;
    } catch (e) {
      logger.e('Error in requestOtp', error: e);
      rethrow;
    }
  }

  // Alias for requestOtp to match the method name used in login_screen.dart
  Future<String?> requestFirebaseOTP(String phoneNumber) {
    return requestOtp(phoneNumber);
  }

  // 2. Verify Firebase OTP
  Future<fb_auth.UserCredential?> verifyFirebaseOTP(
    String verificationId,
    String smsCode,
  ) async {
    try {
      logger.i('Verifying Firebase OTP with verification ID: $verificationId');
      final credential = fb_auth.PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );
      final userCredential = await _firebaseAuth.signInWithCredential(
        credential,
      );
      logger.i(
        'Firebase OTP verified successfully. User ID: ${userCredential.user?.uid}',
      );
      return userCredential;
    } on fb_auth.FirebaseAuthException catch (e, stackTrace) {
      logger.e(
        'Firebase OTP verification failed',
        error: e,
        stackTrace: stackTrace,
      );
      // Map specific Firebase errors to custom exceptions
      if (e.code == 'invalid-verification-code' ||
          e.code == 'invalid-verification-id') {
        throw InvalidCredentialsException(
          'Invalid OTP code or verification ID.',
          stackTrace,
        );
      } else if (e.code == 'session-expired') {
        throw InvalidCredentialsException(
          'Verification session expired. Please request a new OTP.',
          stackTrace,
        );
      } else if (e.code == 'credential-already-in-use') {
        throw InvalidCredentialsException(
          'This credential is already associated with another account.',
          stackTrace,
        );
      }
      // Throw a more general credentials exception for other Firebase auth errors
      throw InvalidCredentialsException(
        'Firebase authentication failed: ${e.message ?? e.code}',
        stackTrace,
      );
    } catch (e, stackTrace) {
      logger.e(
        'Unexpected error verifying OTP',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnexpectedErrorException(
        'An unexpected error occurred verifying OTP: $e',
        stackTrace,
      );
    }
  }

  // 3. Exchange Firebase Token with Backend (Using Custom Exceptions)
  Future<AuthResponse> exchangeFirebaseToken(
    fb_auth.UserCredential userCredential,
  ) async {
    final user = userCredential.user;
    if (user == null) {
      throw const InvalidCredentialsException(
        "Firebase user not available after sign-in.",
      );
    }

    try {
      final idToken = await user.getIdToken(true); // Force refresh
      if (idToken == null) {
        throw const InvalidCredentialsException(
          "Could not retrieve Firebase ID token.",
        );
      }
      logger.i('Firebase ID token retrieved. Length: ${idToken.length}');
      final apiUrl = _dio.options.baseUrl; // Get base URL from Dio instance
      logger.d(
        'Exchanging Firebase token via $apiUrl/api/v1/auth/exchange-firebase-token',
      );

      final response = await _dio.post(
        '/api/v1/auth/exchange-firebase-token',
        options: Options(
          headers: {'Authorization': 'Bearer $idToken'}, // Set specific header
        ),
        data: {}, // Empty body
      );

      logger.i('Backend token exchange successful. $response');
      // Add validation for response data structure if needed before parsing
      if (response.data is Map<String, dynamic>) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        await _tokenService.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        logger.d('Backend tokens saved.');
        return authResponse;
      } else {
        throw UnexpectedErrorException(
          "Invalid response format received from backend during token exchange.",
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.e(
        'DioException during token exchange',
        error: e,
        stackTrace: stackTrace,
      );
      // --- Throw Specific Exceptions based on DioError ---
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'Connection error during token exchange: ${e.message}',
          stackTrace,
        );
      } else if (e.response != null) {
        // Handle errors based on HTTP status code
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        // Try to extract backend's 'detail' message, otherwise use Dio message
        final detail =
            (responseData is Map && responseData.containsKey('detail'))
                ? responseData['detail']?.toString()
                : responseData?.toString();
        final message = detail ?? e.message ?? 'Unknown server error';

        if (statusCode == 404) {
          throw AccountNotFoundException(
            message,
            stackTrace,
          ); // Use backend message
        } else if (statusCode == 401 || statusCode == 403) {
          throw InvalidCredentialsException(
            'Backend authentication failed: $message',
            stackTrace,
          );
        } else if (statusCode != null && statusCode >= 500) {
          throw BackendServerException(
            'Backend server error ($statusCode): $message',
            stackTrace,
          );
        } else {
          throw UnexpectedErrorException(
            'Failed to exchange token with backend ($statusCode): $message',
            stackTrace,
          );
        }
      } else {
        // Error without a response (e.g., request setup error before sending)
        throw NetworkException(
          'Network error sending token exchange request: ${e.message}',
          stackTrace,
        );
      }
      // --- End Specific Exception Throwing ---
    } catch (e, stackTrace) {
      // Catch any other non-Dio errors (e.g., from getIdToken)
      logger.e(
        'Unexpected error during token exchange process',
        error: e,
        stackTrace: stackTrace,
      );
      // If it's already one of our custom exceptions, rethrow it, otherwise wrap it
      if (e is AppException) {
        rethrow;
      } else {
        throw UnexpectedErrorException(
          'An unexpected error occurred: ${e.toString()}',
          stackTrace,
        );
      }
    }
  }

  // --- Other Auth Methods ---

  Future<void> logout() async {
    try {
      // --- Best effort backend logout ---
      try {
        logger.i('Attempting backend logout call to /api/v1/auth/logout');
        await _dio.post('/api/v1/auth/logout');
        logger.d('Backend logout call successful or ignored.');
      } catch (e) {
        logger.w(
          'Backend logout call failed (continuing local logout)',
          error: e,
        );
      }
      // --- End of best effort backend logout ---

      // Firebase sign out
      logger.d('Signing out from Firebase...');
      await _firebaseAuth.signOut();

      // Clear local tokens
      logger.d('Clearing local tokens...');
      await _tokenService.clearTokens();

      logger.i('User logged out successfully (local state).');
      // State update is handled by AuthStateNotifier which calls this method
    } catch (e, stackTrace) {
      logger.e(
        'Error during core logout process (Firebase/Token Clear)',
        error: e,
        stackTrace: stackTrace,
      );
      // Attempt cleanup again in case only part of the try block succeeded before error
      try {
        await _firebaseAuth.signOut();
      } catch (_) {
        /* Ignore */
      }
      try {
        await _tokenService.clearTokens();
      } catch (_) {
        /* Ignore */
      }
      // Re-throw error after cleanup attempt
      throw UnexpectedErrorException('Core logout failed: $e', stackTrace);
    }
  }

  // Check local token existence (basic check)
  Future<bool> isAuthenticated() async {
    final accessToken = await _tokenService.getAccessToken();
    logger.d(
      'Checking authentication status. Access token exists: ${accessToken != null}',
    );
    // TODO: Add token expiration check for a more robust verification
    return accessToken != null;
  }

  // Fetch user details from backend /me endpoint
  Future<User?> getCurrentUser() async {
    if (!await isAuthenticated()) return null;
    try {
      logger.d('Fetching current user details from /api/v1/auth/me');
      final response = await _dio.get('/api/v1/auth/me');
      // Add validation for response data structure
      if (response.data is Map<String, dynamic>) {
        final user = User.fromJson(response.data as Map<String, dynamic>);
        logger.i('Current user details fetched: ${user.id}');
        return user;
      } else {
        throw UnexpectedErrorException(
          "Invalid response format received from /me endpoint.",
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.e(
        'Failed to fetch current user (DioException)',
        error: e,
        stackTrace: stackTrace,
      );
      // If /me returns 401/403, maybe tokens are invalid? Could clear them here.
      if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
        logger.w('Authentication error fetching /me, clearing local tokens.');
        await _tokenService.clearTokens();
      }
      return null; // Return null on error fetching user
    } catch (e, stackTrace) {
      logger.e(
        'Failed to fetch current user (Unexpected)',
        error: e,
        stackTrace: stackTrace,
      );
      return null;
    }
  }

  // TODO: Implement Google Sign-In flow
  // TODO: Implement other methods from auth.ts if needed (register, session timeout checks)
}
