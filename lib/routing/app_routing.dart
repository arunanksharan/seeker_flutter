import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

// Import placeholder screens (we'll create these next)
import 'package:seeker_flutter/features/splash/splash_screen.dart';
import 'package:seeker_flutter/features/auth/presentation/screens/auth_screen.dart';
// Import other screens as you create them
// import 'package:seeker_flutter/features/jobs/presentation/screens/job_list_screen.dart';
// import 'package:seeker_flutter/features/profile/presentation/screens/profile_screen.dart';

// Define route paths as constants for type safety and easy reference
class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home'; // Example: Might contain bottom navigation
  static const jobList = '/jobs'; // Example
  static const jobDetails = '/jobs/:jobId'; // Example with parameter
  static const profile = '/profile'; // Example
  // Add other routes here
}

class AppRouter {
  // Private constructor for singleton pattern (optional)
  // AppRouter._();

  // Static instance of the router
  static final GoRouter router = GoRouter(
    initialLocation: AppRoutes.splash, // Start at the splash screen
    debugLogDiagnostics: true, // Log routing diagnostics in debug mode

    routes: <RouteBase>[
      // Splash/Loading Screen Route
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash', // Optional: name for navigation by name
        builder: (BuildContext context, GoRouterState state) {
          return const SplashScreen(); // Placeholder screen
        },
      ),

      // Authentication Route
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (BuildContext context, GoRouterState state) {
          return const AuthScreen(); // Placeholder screen
        },
      ),

      // Add other top-level routes here
      // Example: Home route (could be a shell route for bottom nav)
      // GoRoute(
      //   path: AppRoutes.home,
      //   name: 'home',
      //   builder: (context, state) => const HomeScreen(), // Placeholder
      //   routes: [ // Nested routes if needed
      //     GoRoute(
      //       path: 'profile', // Relative path: /home/profile
      //       name: 'home-profile',
      //       builder: (context, state) => const ProfileScreen(), // Placeholder
      //     ),
      //   ]
      // ),
    ],

    // TODO: Add error handling (e.g., errorBuilder for 404s)
    // errorBuilder: (context, state) => ErrorScreen(error: state.error),

    // TODO: Add redirect logic for authentication checks later
    // redirect: (BuildContext context, GoRouterState state) {
    //   // Check auth state here using Riverpod (ref.watch)
    //   final bool loggedIn = ... // Get auth state
    //   final bool loggingIn = state.matchedLocation == AppRoutes.auth;
    //
    //   // If not logged in and not trying to log in, redirect to auth
    //   if (!loggedIn && !loggingIn) {
    //     return AppRoutes.auth;
    //   }
    //
    //   // If logged in and trying to access auth screen, redirect to home
    //   if (loggedIn && loggingIn) {
    //     return AppRoutes.home; // Or wherever logged-in users should go
    //   }
    //
    //   // No redirect needed
    //   return null;
    // },
  );
}
