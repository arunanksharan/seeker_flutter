// lib/features/auth/application/auth_state.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart'; // Need to add freezed package
import 'package:seeker/models/auth_models.dart'; // Your User model
import 'package:seeker/services/auth_service.dart';
import 'package:seeker/services/api_client.dart'; // For dioProvider used in authServiceProvider
import 'package:seeker/utils/logger.dart'; // For tokenServiceProvider used in authServiceProvider

import 'package:seeker/core/errors/exceptions.dart';

part 'auth_state.freezed.dart'; // Requires build_runner and freezed_annotation

// Enum to represent different auth states
enum AuthStatus { unknown, authenticated, unauthenticated }

enum AuthStep { phoneInput, otpInput, unknown }

@freezed
class AuthState with _$AuthState {
  const factory AuthState({
    @Default(AuthStatus.unknown) AuthStatus status,
    User? user, // Logged in user data
    String? errorMessage, // Any error message during auth process
    @Default(false) bool isLoading, // Indicate loading state
    @Default(AuthStep.unknown) AuthStep authStep,
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

  // Check initial Auth Status
  Future<void> _checkInitialAuthStatus() async {
    state = state.copyWith(isLoading: true, errorMessage: null);

    try {
      // Check Local Authentication (e.g., token existence)
      final isAuthenticated = await _authService.isAuthenticated();

      if (isAuthenticated) {
        // Optionally fetch user details if needed on startup
        final user = await _authService.getCurrentUser();
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
          isLoading: false,
          authStep: AuthStep.phoneInput,
        );
      } else {
        state = state.copyWith(
          status: AuthStatus.unauthenticated,
          isLoading: false,
          authStep: AuthStep.phoneInput,
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unknown,
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
    if (_verificationId == null) {
      state = state.copyWith(
        errorMessage: "Verification ID not found. Please request OTP again.",
        // Go back to phone input if error.
        authStep: AuthStep.phoneInput,
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
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: authResponse.user,
          isLoading: false,
          authStep: AuthStep.phoneInput,
          errorMessage: null,
        );
        _verificationId = null; // Clear verification ID after use
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
        errorMessage: e.message, // Use message from exception
        status: AuthStatus.unauthenticated,
        authStep: AuthStep.phoneInput, // Go back to phone input
      );
      _verificationId = null;
      return false;
    } on InvalidCredentialsException catch (e) {
      // Catch specific exception
      logger.w("InvalidCredentialsException caught: ${e.message}");
      state = state.copyWith(
        isLoading: false,
        errorMessage: e.message, // Use message from exception
        status: AuthStatus.unauthenticated,
        authStep:
            AuthStep
                .otpInput, // Stay on OTP screen to allow retry? Or phoneInput? Let's stay here for now.
      );
      _verificationId = null; // Clear verification ID on auth errors too
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
      state = state.copyWith(
        isLoading: false,
        errorMessage:
            e is AppException
                ? e.message
                : 'An unexpected error occurred. Please try again.', // Use message if it's our custom type
        status: AuthStatus.unauthenticated,
        authStep:
            AuthStep.otpInput, // Default stay on OTP screen for general errors
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
      );
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.unauthenticated,
        user: null,
        errorMessage: 'Logout failed: $e',
        isLoading: false,
        // Ensure step is phone input after logout attempt fails too
        authStep: AuthStep.phoneInput,
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


// You'll need to add freezed, freezed_annotation, and build_runner to pubspec.yaml:
// dependencies:
//   freezed_annotation: ^2.4.1
// dev_dependencies:
//   build_runner: ^2.4.11
//   freezed: ^2.5.2
// Then run: flutter pub run build_runner build --delete-conflicting-outputs