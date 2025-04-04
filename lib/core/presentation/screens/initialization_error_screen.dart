import 'package:flutter/material.dart';

class InitializationErrorScreen extends StatelessWidget {
  final String errorMessage;

  const InitializationErrorScreen({super.key, required this.errorMessage});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      // Use a basic MaterialApp here as the main app's theme/routing might not be available
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 60),
                const SizedBox(height: 20),
                const Text(
                  'Application Initialization Failed',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 10),
                Text(
                  'Could not initialize essential services. Please try restarting the app. Error details:\n\n$errorMessage',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey[700]),
                ),
                // Optionally add a button to retry or close
              ],
            ),
          ),
        ),
      ),
    );
  }
}
