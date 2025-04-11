// lib/features/auth/presentation/screens/login_screen.dart
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/features/auth/application/auth_state.dart';
import 'package:phone_number/phone_number.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:seeker/utils/logger.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _formKeyPhone = GlobalKey<FormState>();
  final _formKeyOtp = GlobalKey<FormState>();

  // REMOVED: bool _showOtpView = false;

  String _formattedPhoneNumber = ''; // Still needed to display on OTP screen
  String? _registrationNumberError; // Still needed for specific error UI

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _setupListener();
    _otpController.addListener(_otpListener);
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   _setupListener();
    //   _initializeControllers(); // Initialize non-auth related controllers if any
    // });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _setupListener();
      }
    });
  }

  // Listener to handle side-effects like Snackbars or clearing fields
  void _setupListener() {
    if (!mounted) return;
  }

  void _otpListener() {
    // Log changes
    logger.d(
      "OTP Controller Listener: text='${_otpController.text}', length=${_otpController.text.length}",
    );
    // Crucial: Trigger a rebuild if using controller state directly in button logic
    // This ensures the button's enabled state re-evaluates when text changes.
    if (mounted) {
      setState(() {});
    }
  }

  // Initialize non-auth controllers if any were added
  void _initializeControllers({Map<String, dynamic>? profileData}) {
    logger.d(
      "Initializing LoginScreen controllers (if any needed besides phone/otp).",
    );
  }

  @override
  void dispose() {
    _otpController.removeListener(_otpListener); // Remove listener
    _phoneController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  // --- Actions ---
  Future<void> _sendOtp() async {
    FocusScope.of(context).unfocus();
    if (!_formKeyPhone.currentState!.validate()) return; // Use Form validation

    final String rawPhoneNumber = _phoneController.text.trim();
    try {
      final PhoneNumberUtil plugin = PhoneNumberUtil();
      final PhoneNumber number = await plugin.parse(
        rawPhoneNumber,
        regionCode: 'IN',
      );
      if (number.e164 == null) throw Exception('Could not format number.');
      _formattedPhoneNumber = number.e164!;
      logger.d("Validated phone number: $_formattedPhoneNumber");
    } catch (e) {
      logger.w("Phone number validation/parsing failed: $e");
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invalid mobile number format.')),
        );
      }
      return;
    }

    // Call notifier action. State change (including authStep) handled there.
    final success = await ref
        .read(authStateProvider.notifier)
        .requestFirebaseOtp(_formattedPhoneNumber);

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('OTP Sent! Check your messages.')),
      );
    } else if (!success && mounted) {
      // Update local _registrationNumberError based on the error set in the notifier state
      final authState = ref.read(authStateProvider);
      setState(() {
        _registrationNumberError = _extractRegistrationNumber(
          authState.errorMessage,
        );
      });
      // Error message display handled by UI watching state or listener showing SnackBar
    }
  }

  // Future<void> _verifyOtp() async {
  //   FocusScope.of(context).unfocus();
  //   if (!_formKeyOtp.currentState!.validate()) return; // Use Form validation

  //   final String smsCode = _otpController.text.trim();
  //   // Call notifier action. State change (success/fail/authStep) handled there.
  //   await ref
  //       .read(authStateProvider.notifier)
  //       .verifyFirebaseOtpAndLogin(smsCode);
  //   // Navigation/Error display is driven by watching/listening to authStateProvider
  // }
  Future<void> _verifyOtp() async {
    // No changes needed in _verifyOtp itself
    logger.i("_verifyOtp: Function CALLED.");
    FocusScope.of(context).unfocus();
    final String smsCode = _otpController.text.trim();
    logger.d("_verifyOtp: OTP Code = '$smsCode'");
    try {
      logger.d(
        "_verifyOtp: Calling authStateProvider.notifier.verifyFirebaseOtpAndLogin...",
      );
      await ref
          .read(authStateProvider.notifier)
          .verifyFirebaseOtpAndLogin(smsCode);
      logger.d("_verifyOtp: Call to notifier completed.");
    } catch (e, s) {
      logger.e(
        "_verifyOtp: Error calling verifyFirebaseOtpAndLogin!",
        error: e,
        stackTrace: s,
      );
      final errorMessage = "Verification failed: ${e.toString()}";
      ref
          .read(authStateProvider.notifier)
          .updateField('errorMessage', errorMessage);
      ref.read(authStateProvider.notifier).updateField('isLoading', false);
      _showErrorToast("Verification failed. Please try again.");
    }
  }

  // Helper function for showing toasts/snackbars
  void _showErrorToast(String message) {
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: Colors.blue,
          duration: const Duration(seconds: 1),
        ),
      );
    } else {
      logger.w(
        "Tried to show toast, but widget was not mounted. Message: $message",
      );
    }
  }

  // _callPhoneNumber remains the same
  void _callPhoneNumber(String phoneNumber) async {
    if (phoneNumber.isEmpty) return;
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    try {
      if (await canLaunchUrl(launchUri)) {
        await launchUrl(launchUri);
      } else {
        logger.w('Could not launch phone dialer for $phoneNumber');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Could not open dialer for $phoneNumber')),
          );
        }
      }
    } catch (e) {
      logger.e('Error launching phone dialer', error: e);
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error opening dialer: $e')));
      }
    }
  }

  // _extractRegistrationNumber remains the same
  String? _extractRegistrationNumber(String? errorMessage) {
    // Check for specific error message format set by AuthStateNotifier
    if (errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") == true) {
      final RegExp phoneRegExp = RegExp(r'\b\d{10,}\b');
      final Match? match = phoneRegExp.firstMatch(errorMessage!);
      if (match != null) return match.group(0);
      // Extract from default/config if not in message
      // Example: Parse message "ACCOUNT_NOT_FOUND: ... call 080..."
      // Fallback if parsing fails
      return "08035736454"; // Fallback
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    ref.listen<AuthState>(authStateProvider, (previous, next) {
      if (!mounted) {
        logger.w("AuthState listener fired but widget is no longer mounted.");
        return;
      }
      logger.d(
        "Listener triggered: Prev step=${previous?.authStep}, Next step=${next.authStep}, isLoading=${next.isLoading}, error=${next.errorMessage}",
      );
      // Clear OTP field when authStep changes back to phoneInput
      if (previous?.authStep == AuthStep.otpInput &&
          next.authStep == AuthStep.phoneInput) {
        _otpController.clear();
      }

      // Show Snackbars for general errors (not account not found)
      if (previous?.isLoading == true &&
          !next.isLoading &&
          next.errorMessage != null) {
        // Check if it's the specific account not found error message format
        final isAccountNotFoundError =
            next.errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") ?? false;
        // if (!isAccountNotFoundError) {
        //   if (mounted) {
        //     ScaffoldMessenger.of(context).showSnackBar(
        //       SnackBar(
        //         content: Text(next.errorMessage!),
        //         backgroundColor: Colors.red,
        //       ),
        //     );
        //   }
        // }
      }
      // Clear local registration number state if error message changes
      if (_registrationNumberError != null &&
          previous?.errorMessage != next.errorMessage) {
        if (mounted) {
          // Re-evaluate based on NEW error message
          setState(() {
            _registrationNumberError = _extractRegistrationNumber(
              next.errorMessage,
            );
          });
        }
      }
    });
    logger.d("AuthState listener setup complete.");

    // ref.listen<AuthState>(authStateProvider, (previous, next) {
    //   // --- CHANGE 4: Added safety check inside listener callback ---
    //   if (!mounted) return; // Exit if widget is no longer in the tree

    //   logger.d(
    //     "Listener triggered: Prev step=${previous?.authStep}, Next step=${next.authStep}",
    //   );
    //   // ... (rest of your listener logic: clearing OTP, showing SnackBars, setting _registrationNumberError state) ...

    //   // Example: Clear OTP field when authStep changes back to phoneInput
    //   if (previous?.authStep == AuthStep.otpInput &&
    //       next.authStep == AuthStep.phoneInput) {
    //     logger.d("Clearing OTP controller");
    //     _otpController.clear();
    //   }

    //   // Example: Show Snackbars for general errors
    //   if (previous?.isLoading == true &&
    //       !next.isLoading &&
    //       next.errorMessage != null) {
    //     final isAccountNotFoundError =
    //         next.errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") ?? false;
    //     if (!isAccountNotFoundError) {
    //       logger.d("Showing general error SnackBar");
    //       ScaffoldMessenger.of(context).showSnackBar(
    //         SnackBar(
    //           content: Text(next.errorMessage!),
    //           backgroundColor: Colors.red,
    //         ),
    //       );
    //     }
    //   }

    //   // Example: Update local state based on error message changes
    //   final newRegError = _extractRegistrationNumber(next.errorMessage);
    //   if (_registrationNumberError != newRegError) {
    //     logger.d(
    //       "Updating registration number error state from '$_registrationNumberError' to '$newRegError'",
    //     );
    //     // Note: setState is safe here because it's called from the listener callback,
    //     // not directly during the build phase, and we checked 'mounted'.
    //     setState(() {
    //       _registrationNumberError = newRegError;
    //     });
    //   }
    // });

    // Watch the full auth state
    final authState = ref.watch(authStateProvider);
    final isLoading = authState.isLoading;
    // --- Use authStep from state ---
    final currentAuthStep = authState.authStep;
    final otpAttempts = authState.otpAttempts;
    // --------------------------------

    // Listener defined in initState using _setupListener

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 40),
                // Header Section
                Column(
                  children: [
                    Image.asset(
                      'assets/logo.png',
                      height: 100,
                      width: 100,
                      errorBuilder:
                          (context, error, stackTrace) =>
                              const Icon(Icons.image_not_supported, size: 100),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Welcome to Seeker',
                      style: textTheme.displayMedium?.copyWith(
                        color: colorScheme.primary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    Text(
                      'Find your perfect job opportunity',
                      style: textTheme.bodyLarge?.copyWith(
                        color: colorScheme.onSurface.withAlpha(153),
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
                const SizedBox(height: 32),

                // --- Conditional Form: Use authState.authStep ---
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 100),
                  // Control visibility based on the authStep from the state provider
                  child:
                      currentAuthStep == AuthStep.otpInput
                          ? _buildOtpForm(
                            context,
                            theme,
                            textTheme,
                            colorScheme,
                            isLoading,
                            authState,
                            otpAttempts,
                          )
                          : _buildPhoneForm(
                            context,
                            theme,
                            textTheme,
                            colorScheme,
                            isLoading,
                            authState,
                          ),
                ),

                // --- --------------------------------------- ---
                const SizedBox(
                  height: 40,
                ), // Add space before footer pushes up too much
                // Footer Section
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Text(
                                'Powered by',
                                style: textTheme.bodySmall?.copyWith(
                                  color: colorScheme.onSurface.withAlpha(153),
                                ),
                              ),
                              const SizedBox(width: 4),
                              Image.asset(
                                'assets/onest-logo.png',
                                height: 18,
                                width: 40,
                                errorBuilder:
                                    (context, error, stackTrace) => const Text(
                                      'Onest',
                                      style: TextStyle(fontSize: 10),
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Expanded(child: Divider(color: Colors.grey.shade300)),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // --- Widget Builders for Forms ---

  Widget _buildPhoneForm(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isLoading,
    AuthState authState,
  ) {
    // Get specific error message for inline display if it's the account not found type
    // final inlineErrorMessage =
    //     (authState.errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") ?? false)
    //         ? authState.errorMessage
    //         : null;

    return Form(
      key: _formKeyPhone,
      child: Column(
        key: const ValueKey('phoneForm'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Mobile Number',
            style: textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 12,
                ),
                decoration: BoxDecoration(
                  color: theme.inputDecorationTheme.fillColor,
                  borderRadius: const BorderRadius.all(Radius.circular(8)),
                  // border: Border.all(
                  //   color:
                  //       theme
                  //           .inputDecorationTheme
                  //           .enabledBorder
                  //           ?.borderSide
                  //           .color ??
                  //       Colors.grey[300]!,
                  // ),
                ),
                child: Text('+91', style: textTheme.bodyLarge),
              ),
              Expanded(
                child: TextFormField(
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  maxLength: 10,
                  enabled: !isLoading,
                  decoration: const InputDecoration(counterText: ""),
                  style: textTheme.bodyLarge,
                  // Use validator with form key
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter your mobile number';
                    }
                    // Basic validation; more robust check happens in _sendOtp before API call
                    return null;
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // --- Refined Inline Error Display ---
          // Show specific "Account not found" error inline
          // if (inlineErrorMessage != null)
          //   Padding(
          //     padding: const EdgeInsets.only(bottom: 16.0),
          //     child: Text.rich(
          //       TextSpan(
          //         style: textTheme.bodyMedium?.copyWith(
          //           color: colorScheme.error,
          //         ),
          //         children: [
          //           // Show text before number placeholder
          //           TextSpan(
          //             text:
          //                 inlineErrorMessage
          //                     .replaceFirst("ACCOUNT_NOT_FOUND:", "")
          //                     .split(' Please call')[0]
          //                     .trim(),
          //           ),
          //           // Show clickable number if extracted
          //           if (_registrationNumberError != null)
          //             TextSpan(
          //               text: " Call $_registrationNumberError",
          //               style: TextStyle(
          //                 color: colorScheme.primary,
          //                 fontWeight: FontWeight.bold,
          //               ),
          //               recognizer:
          //                   TapGestureRecognizer()
          //                     ..onTap =
          //                         () => _callPhoneNumber(
          //                           _registrationNumberError!,
          //                         ),
          //             ),
          //         ],
          //       ),
          //       textAlign: TextAlign.center,
          //     ),
          //   ),

          // // --- ---------------------------- ---
          ElevatedButton(
            // Validate form before calling _sendOtp
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color>((
                Set<WidgetState> states,
              ) {
                // Always return primary color, even when disabled
                return colorScheme.primary;
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            onPressed:
                isLoading
                    ? null
                    : () {
                      if (_formKeyPhone.currentState!.validate()) _sendOtp();
                    },
            child:
                isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Send OTP'),
          ),
          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildOtpForm(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
    bool isLoading,
    AuthState authState,
    int otpAttempts,
  ) {
    final currentOtpLength = _otpController.text.length;
    final isButtonEnabled = !isLoading && currentOtpLength == 6;
    logger.d(
      "_buildOtpForm: isLoading=$isLoading, otpLength=$currentOtpLength, isButtonEnabled=$isButtonEnabled",
    );
    // Get general OTP error message (not account not found)
    final otpErrorMessage =
        (authState.errorMessage != null &&
                authState.errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") !=
                    true)
            ? authState.errorMessage
            : null;

    // // Check specifically for account not found error
    final bool isAccountNotFoundError =
        authState.errorMessage?.startsWith("ACCOUNT_NOT_FOUND:") ?? false;

    // Determine if OTP length is currently valid (exactly 6)
    final bool isOtpLengthValid = _otpController.text.trim().length == 6;

    logger.d(
      "_buildOtpForm: isLoading=$isLoading, otpLength=${_otpController.text.length}, isOtpLengthValid=$isOtpLengthValid",
    );

    // String? inlineErrorMessage;

    // if (authState.errorMessage != null) {
    //   if (!authState.errorMessage!.startsWith("ACCOUNT_NOT_FOUND:")) {
    //     inlineErrorMessage = authState.errorMessage;
    //   }
    // }

    return Form(
      key: _formKeyOtp,
      child: Column(
        key: const ValueKey('otpForm'),
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Enter the 6-digit code sent to $_formattedPhoneNumber',
            style: textTheme.bodyLarge?.copyWith(
              color: colorScheme.onSurface.withAlpha(153),
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: _otpController,
            keyboardType: TextInputType.number,
            maxLength: 6,
            enabled: !isLoading,
            textAlign: TextAlign.center,
            style: textTheme.bodyLarge,
            decoration: const InputDecoration(
              hintText: '- - - - - -',
              counterText: "",
            ),
            // Use validator with form key
            // onChanged: (value) {
            //   logger.d(
            //     "OTP TextFormField onChanged: '$value', length=${value.length}",
            //   );
            //   // Force rebuild when length changes - helps isolate if rebuild is the issue
            //   if (mounted) {
            //     setState(() {});
            //   }
            // },
            validator: (value) {
              if (value == null || value.trim().length != 6) {
                return 'Enter 6 digits';
              }
              return null;
            },
          ),
          const SizedBox(height: 16),

          // Display general OTP errors inline
          if (otpErrorMessage != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Text(
                otpErrorMessage,
                style: textTheme.bodyMedium?.copyWith(color: colorScheme.error),
                textAlign: TextAlign.center,
              ),
            ),

          ElevatedButton(
            // Validate form before calling _verifyOtp
            style: ButtonStyle(
              backgroundColor: WidgetStateProperty.resolveWith<Color?>((
                states,
              ) {
                if (states.contains(WidgetState.disabled)) {
                  // Make disabled state more obvious if needed
                  return colorScheme.primary.withAlpha(100);
                }
                return isOtpLengthValid
                    ? colorScheme
                        .primary // Fully opaque if length is valid
                    : colorScheme.primary.withAlpha(100); // 50% transparent
              }),
              foregroundColor: WidgetStateProperty.all(Colors.white),
              padding: WidgetStateProperty.all(
                const EdgeInsets.symmetric(vertical: 12),
              ),
              shape: WidgetStateProperty.all(
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            onPressed:
                isLoading // Only disable if currently loading
                    ? null
                    : () {
                      // Button is always enabled otherwise
                      logger.i("Verify OTP Button: PRESSED!");
                      final currentOtp = _otpController.text.trim();

                      // Check length BEFORE trying to validate/verify
                      if (currentOtp.length < 6) {
                        logger.w(
                          "Verify OTP Button: Pressed with invalid length (${currentOtp.length}). Showing SnackBar.",
                        );
                        // Remove any existing snackbar first
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                        // Show the length error snackbar
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('OTP must be 6 digits.'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        return; // Stop processing
                      }

                      // Length is 6, proceed with validation and verification
                      logger.d(
                        "Verify OTP Button: Length is valid. Proceeding with form validation...",
                      );
                      // Use form validation (optional but good practice if validator exists)
                      if (_formKeyOtp.currentState?.validate() ?? false) {
                        logger.d(
                          "Verify OTP Button: Form valid, calling _verifyOtp()...",
                        );
                        _verifyOtp(); // Call the actual verification function
                      } else {
                        // This might happen if validator has other rules,
                        // or if state is somehow inconsistent.
                        logger.w(
                          "Verify OTP Button: Length valid but form validation failed.",
                        );
                        // Optionally show the validator's error message via snackbar again
                        // _showErrorToast(_formKeyOtp.currentState?.validate() ?? "Validation error");
                      }
                    },
            child:
                isLoading
                    ? const SizedBox(
                      height: 24,
                      width: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                    : const Text('Verify OTP'),
          ),

          // New account not found message - permanent and below the verify button
          if (isAccountNotFoundError)
            Padding(
              padding: const EdgeInsets.only(top: 16.0),
              child: Container(
                padding: const EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.red[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.red[100]!),
                ),
                child: Column(
                  children: [
                    Text(
                      'No account found. Please call 08035736454 to register',
                      style: textTheme.bodyMedium?.copyWith(
                        color: Colors.red[800],
                        fontWeight: FontWeight.w500,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton.icon(
                      onPressed: () => _callPhoneNumber('8035736454'),
                      icon: const Icon(Icons.call, size: 18),
                      label: const Text('Call to Register'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red[700],
                        side: BorderSide(color: Colors.red[200]!),
                      ),
                    ),
                  ],
                ),
              ),
            ),

          const SizedBox(height: 8),
          TextButton(
            // Change state explicitly using notifier
            onPressed:
                isLoading
                    ? null
                    : () => ref
                        .read(authStateProvider.notifier)
                        .updateField('authStep', AuthStep.phoneInput),
            child: Text(
              'Change Mobile Number',
              style: TextStyle(color: colorScheme.primary),
            ),
          ),
        ],
      ),
    );
  }
} // End of _LoginScreenState
