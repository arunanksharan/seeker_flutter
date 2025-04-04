import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Import your router configuration (we'll create this next)
import 'package:seeker_flutter/routing/app_router.dart';
import 'package:seeker_flutter/theme/app_theme.dart'; // Import the AppTheme

// Use ConsumerWidget for easy access to providers if needed directly here,
// or StatelessWidget if you configure the router provider elsewhere.
// ConsumerWidget is generally flexible for the root.

class App extends ConsumerWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get the router configuration. We'll set up the routerProvider soon.
    // For now, we create it directly, but ideally, it becomes a provider.
    final router = AppRouter.router; // Accessing the static router instance

    return MaterialApp.router(
      title: 'Seeker App', // Replace with dynamic title later if needed
      debugShowCheckedModeBanner: false, // Hides the debug banner
      // Router configuration from go_router
      routerDelegate: router.routerDelegate,
      routeInformationParser: router.routeInformationParser,
      routeInformationProvider: router.routeInformationProvider,

      // Apply the custom theme
      theme:
          AppTheme.lightTheme, // Use the light theme defined in app_theme.dart
      // Optionally configure dark theme:
      // darkTheme: AppTheme.darkTheme,
      // themeMode: ThemeMode.system, // Or ThemeMode.light, ThemeMode.dark
    );
  }
}
