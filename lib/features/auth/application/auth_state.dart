// lib/features/auth/application/auth_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // Need to add freezed package
import 'package:seeker/models/auth_models.dart'; // Your User model
import 'package:seeker/services/auth_service.dart';
import 'package:seeker/services/api_client.dart'; // For dioProvider used in authServiceProvider
import 'package:seeker/utils/logger.dart';

import 'package:seeker/core/errors/exceptions.dart';

part 'auth_state.freezed.dart'; // Requires build_runner and freezed_annotation

// Enum to represent different auth states
enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthStep { phoneInput, otpInput, unknown }

@freezed
abstract class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    User? user, // Logged in user data
    String? errorMessage, // Any error message during auth process
    @Default(false) bool isLoading, // Indicate loading state
    @Default(AuthStep.unknown) AuthStep authStep,
    @Default(0) int otpAttempts,
  }) = _AuthState;
}

class AuthStateNotifier extends StateNotifier<AuthState> {
  // Keep AuthService private or pass ref if needed for other providers
  final AuthService _authService;

  // Store verificationId temporarily during OTP flow
  String? _verificationId;

  AuthStateNotifier(this._authService) : super(const AuthState()) {
    _checkInitialAuthStatus(); // Check auth status on init
  }

  // Update a single field in the state
  void updateField(String field, dynamic value) {
    if (field == 'authStep' && value is AuthStep) {
      final newState = state.copyWith(
        authStep: value,
        // Reset attempts if moving back to phone input
        otpAttempts: (value == AuthStep.phoneInput) ? 0 : state.otpAttempts,
      );
      state = newState;
    } else if (field == 'errorMessage' && value is String?) {
      state = state.copyWith(errorMessage: value);
    } else if (field == 'isLoading' && value is bool) {
      state = state.copyWith(isLoading: value);
    } else if (field == 'status' && value is AuthStatus) {
      state = state.copyWith(status: value);
    }
    // Add other fields as needed
  }

  // Check initial Auth Status
  Future<void> _checkInitialAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Set timeout safety to prevent indefinite loading
      bool timeoutReached = false;
      Future.delayed(const Duration(seconds: 5), () {
        if (state.status == AuthStatus.unknown && !timeoutReached) {
          timeoutReached = true;
          logger.w(
            'Auth status check timed out - forcing unauthenticated state',
          );
          state = state.copyWith(
            status: AuthStatus.unauthenticated,
            isLoading: false,
            errorMessage: 'Authentication check timed out',
            authStep: AuthStep.phoneInput,
          );
        }
      });

      // Check Local Authentication (e.g., token existence)
      final isAuthenticated = await _authService.isAuthenticated();

      // If timeout already occurred, don't update state again
      if (timeoutReached) return;

      if (isAuthenticated) {
        // Optionally fetch user details if needed on startup
        try {
          final user = await _authService.getCurrentUser();
          state = state.copyWith(
            status: AuthStatus.authenticated,
            user: user,
            isLoading: false,
            authStep: AuthStep.phoneInput,
          );
        } catch (e) {
          // Handle user fetch error but still consider authenticated
          logger.e('Error fetching user details', error: e);
          state = state.copyWith(
            status: AuthStatus.authenticated,
            isLoading: false,
            authStep: AuthStep.phoneInput,
            errorMessage: 'Authenticated but failed to load user details',
          );
        }
      } else {
        logger.d('User is not authenticated, redirecting to auth screen');
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          authStep: AuthStep.phoneInput,
        );
      }
    } catch (e) {
      logger.e('Error checking auth status', error: e);
      state = state.copyWith(
        status:
            AuthStatus
                .unauthenticated, // Change to unauthenticated instead of unknown
        errorMessage: e.toString(),
        isLoading: false,
        authStep: AuthStep.phoneInput,
      );
    }
  }

  Future<bool> requestFirebaseOtp(String phoneNumber) async {
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      authStep: AuthStep.phoneInput,
      otpAttempts: 0,
    );
    try {
      _verificationId = await _authService.requestFirebaseOTP(phoneNumber);
      final bool success = _verificationId != null;

      state = state.copyWith(
        isLoading: false,
        // Go to OTP input on success, stay on phone input on failure
        authStep: success ? AuthStep.otpInput : AuthStep.phoneInput,
      );
      return success;
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.toString(),
        authStep: AuthStep.phoneInput, // Stay on phone input on error
      );
      return false;
    }
  }

  // Verify OTP & Login
  Future<bool> verifyFirebaseOtpAndLogin(String smsCode) async {
    // --- CHECK MAX ATTEMPTS FIRST ---
    if (state.otpAttempts >= 3) {
      logger.w("OTP verification blocked: Max attempts reached.");
      state = state.copyWith(
        errorMessage: "Maximum OTP attempts reached. Please request a new OTP.",
        isLoading: false, // Ensure loading is off
        // Optionally force back to phone input, or keep on OTP screen disabled
        // authStep: AuthStep.phoneInput,
      );
      return false;
    }
    // --- END MAX ATTEMPTS CHECK ---

    if (_verificationId == null) {
      state = state.copyWith(
        errorMessage: "Verification ID not found. Please request OTP again.",
        // Go back to phone input if error.
        authStep: AuthStep.phoneInput,
        otpAttempts: 0,
      );
      return false;
    }
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      authStep: AuthStep.otpInput,
    );

    try {
      // Verify OTP with firebase
      final userCredential = await _authService.verifyFirebaseOTP(
        _verificationId!,
        smsCode,
      );
      if (userCredential?.user != null) {
        final authResponse = await _authService.exchangeFirebaseToken(
          userCredential!,
        );
        // Update state with user data and auth status
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          status: AuthStatus.authenticated,
          user: authResponse.user,
          otpAttempts: 0,
          // Keep authStep as otpInput since navigation will be handled by router
        );
        logger.i("User authenticated successfully: ${authResponse.user.id}");
        return true;
      } else {
        throw const UnexpectedErrorException(
          "Firebase sign-in failed during OTP confirmation.",
        );
      }
    } on AccountNotFoundException catch (e) {
      // Catch specific exception
      logger.w("AccountNotFoundException caught: ${e.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            "ACCOUNT_NOT_FOUND: ${e.message}", // Prefix error message for UI to detect
        status: AuthStatus.unauthenticated,
        authStep: AuthStep.otpInput, // Stay on OTP input to show the message
      );
      _verificationId = null;
      return false;
    } on InvalidCredentialsException catch (e) {
      // Catch specific invalid OTP error
      logger.w(
        "InvalidCredentialsException caught during OTP verify: ${e.message}",
      );
      final currentAttempts = state.otpAttempts + 1; // Increment attempts
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            currentAttempts >= 3
                ? "Incorrect OTP. Maximum attempts reached. Please request a new OTP."
                : "Incorrect OTP. Please try again (${3 - currentAttempts} attempts remaining).",
        status: AuthStatus.unauthenticated,
        authStep: AuthStep.otpInput, // STAY on OTP input
        otpAttempts: currentAttempts, // <-- UPDATE ATTEMPTS
      );
      _verificationId =
          null; // Clear verification ID on auth errors too? Maybe not if allowing retry? Keep it for now.
      return false;
    } on NetworkException catch (e) {
      // Catch specific exception
      logger.w("NetworkException caught: ${e.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message, // Use message from exception
        status:
            AuthStatus
                .unauthenticated, // Or keep 'unknown' if preferred for network issues? Stay unauthenticated.
        authStep: AuthStep.otpInput, // Stay on OTP screen to allow retry
      );
      // Don't clear verification ID on network errors, allow retry with same ID
      return false;
    } catch (e, stackTrace) {
      // Catch any other Exception
      logger.e(
        "Generic error during OTP verification or token exchange",
        error: e,
        stackTrace: stackTrace,
      );
      final currentAttempts = state.otpAttempts + 1;
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            currentAttempts >= 3
                ? "Verification failed. Maximum attempts reached. Please request a new OTP."
                : (e is AppException
                    ? e.message ?? 'Verification failed. Please try again.'
                    : 'An unexpected error occurred. Please try again.'),
        status: AuthStatus.unauthenticated,
        authStep: AuthStep.otpInput, // STAY on OTP input
        otpAttempts: currentAttempts, // <-- UPDATE ATTEMPTS
      );
      _verificationId = null; // Clear verification ID
      return false;
    }
  }

  Future<void> logout() async {
    state = state.copyWith(isLoading: true, errorMessage: null);
    try {
      await _authService.logout();
      // Reset state completely, including setting step back to phone input
      state = const AuthState(
        status: AuthStatus.unauthenticated,
        authStep: AuthStep.phoneInput,
        otpAttempts: 0,
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: 'Logout failed: $e',
        isLoading: false,
        // Ensure step is phone input after logout attempt fails too
        authStep: AuthStep.phoneInput,
        otpAttempts: 0,
      );
    }
  }
}

// Providers - authServiceProvider
final authServiceProvider = Provider<AuthService>((ref) {
  // Use watch here if ApiClient might change (e.g., re-login changes headers internally)
  // Use read if ApiClient is considered stable after init
  final dio = ref.watch(dioProvider);
  final tokenService = ref.watch(tokenServiceProvider);
  // FirebaseAuth can be accessed directly via instance
  return AuthService(dio, tokenService);
});

// Providers - authStateProvider
final authStateProvider = StateNotifierProvider<AuthStateNotifier, AuthState>((
  ref,
) {
  // Pass the AuthService instance to the Notifier
  final authService = ref.watch(authServiceProvider);
  return AuthStateNotifier(authService);
});
