import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/features/auth/application/auth_state.dart';
import 'package:seeker/utils/logger.dart';

class SplashScreen extends ConsumerWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);

    // Log auth state for debugging
    logger.d(
      'SplashScreen - Auth Status: ${authState.status}, IsLoading: ${authState.isLoading}',
    );

    return Scaffold(
      body: Center(
        child: Image.asset(
          'assets/logo.png',
          height: 96, // Adjust size as needed
          width: 96, // Adjust size as needed
          // Optional: Add an error builder in case the image fails to load
          errorBuilder: (context, error, stackTrace) {
            // You could return a placeholder icon or SizedBox
            return const SizedBox(
              height: 150,
              width: 150,
            ); // Example placeholder
          },
        ),
        // child: Column(
        //   mainAxisAlignment: MainAxisAlignment.center,
        //   children: [
        //     const CircularProgressIndicator(),
        //     const SizedBox(height: 20),
        //     Text('Auth Status: ${authState.status}'),
        //     if (authState.isLoading)
        //       const Text('Loading...'),
        //     if (authState.errorMessage != null)
        //       Padding(
        //         padding: const EdgeInsets.all(16.0),
        //         child: Text(
        //           'Error: ${authState.errorMessage}',
        //           style: const TextStyle(color: Colors.red),
        //           textAlign: TextAlign.center,
        //         ),
        //       ),
        //   ],
        // ),
      ),
    );
  }
}
