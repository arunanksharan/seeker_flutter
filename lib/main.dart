import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/core/presentation/screens/initialization_error_screen.dart';

// Import the generated Firebase options and your App widget
import 'package:seeker/utils/logger.dart';
import 'package:seeker/firebase_options.dart'; // Make sure you ran `flutterfire configure`
import 'package:seeker/app.dart'; // We will create this file next

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase using the generated options
  // This must be done before running the app
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    logger.i('Firebase initialized successfully'); // Add print for confirmation
    // Run the main app wrapped in ProviderScope on success
    runApp(const ProviderScope(child: App()));
  } catch (e, stackTrace) {
    // Log error if Firebase initialization fails
    logger.e(
      'Failed to initialize Firebase',
      error: e, // Pass the error object
      stackTrace: stackTrace, // Pass the stack trace
    );

    // Show a dedicated error screen to the user
    runApp(
      InitializationErrorScreen(
        errorMessage: e.toString(), // Pass the error message to the screen
      ),
    );
  }
}
