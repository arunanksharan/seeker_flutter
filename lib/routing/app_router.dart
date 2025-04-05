// lib/routing/app_router.dart
import 'package:seeker/features/shell/presentation/screens/app_shell.dart'; // Import the shell
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'dart:async'; // For StreamSubscription

// State Notifier & State
import 'package:seeker/features/auth/application/auth_state.dart';

// Screens
import 'package:seeker/features/auth/presentation/screens/login_screen.dart';
import 'package:seeker/features/home/presentation/screens/home_screen.dart';
import 'package:seeker/features/profile/presentation/screens/profile_screen.dart';
import 'package:seeker/features/splash/splash_screen.dart';

// Utilities
import 'package:seeker/utils/logger.dart';

// Define route paths as constants
class AppRoutes {
  static const splash = '/';
  static const auth = '/auth';
  static const home = '/home';
  static const profile = '/profile'; // Keep consistent naming
}

// Helper class to convert Stream to Listenable for GoRouter's refreshListenable
class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners(); // Initial notification
    // Listen to the stream and notify listeners on each event
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

// Instantiate GoRouter using Riverpod for state access
final goRouterProvider = Provider<GoRouter>((ref) {
  // Listen to the auth state stream for refresh purposes
  // Watching the notifier directly ensures we react to state *changes*
  final authStateChanges = ref.watch(authStateProvider.notifier).stream;

  // Create Navigator Keys for ShellRoute branches if needed for state preservation
  // Optional but recommended for keeping state in each tab
  final rootNavigatorKey = GlobalKey<NavigatorState>();
  final shellNavigatorKeyHome = GlobalKey<NavigatorState>(
    debugLabel: 'shellHome',
  );
  final shellNavigatorKeyProfile = GlobalKey<NavigatorState>(
    debugLabel: 'shellProfile',
  );

  return GoRouter(
    navigatorKey: rootNavigatorKey, // Assign root navigator key
    initialLocation: AppRoutes.splash,
    debugLogDiagnostics: true,

    // refreshListenable triggers redirect check when auth state changes
    refreshListenable: GoRouterRefreshStream(authStateChanges),

    // Redirect logic based on authentication status
    redirect: (BuildContext context, GoRouterState state) {
      // Use read for the *current* value within redirect
      final authStatus = ref.read(authStateProvider).status;
      final currentLocation = state.matchedLocation;

      logger.d(
        'Router Redirect Check: Location = $currentLocation, Auth Status = $authStatus',
      );

      final isSplashRoute = (currentLocation == AppRoutes.splash);
      final isAuthRoute = (currentLocation == AppRoutes.auth);

      // final isShellRoute =
      //     currentLocation.startsWith(AppRoutes.home) ||
      //     currentLocation.startsWith(
      //       AppRoutes.profile,
      //     ); // Add other shell routes here

      // While state is unknown (initial loading), always stay on/go to splash
      if (authStatus == AuthStatus.unknown) {
        logger.d(
          'Redirect: Auth status unknown -> ${isSplashRoute ? "Staying" : "Going to"} splash.',
        );
        return isSplashRoute ? null : AppRoutes.splash;
      }

      // If user is authenticated
      if (authStatus == AuthStatus.authenticated) {
        // If they are on splash or auth screen, redirect to home
        if (isSplashRoute || isAuthRoute) {
          logger.d(
            'Redirect: Authenticated on splash/auth -> Redirecting to home.',
          );
          return AppRoutes.home;
        }
        // Otherwise, they can access any other route (including /home, /profile/edit, etc.)
        logger.d(
          'Redirect: Authenticated accessing allowed route: $currentLocation',
        );
        return null; // No redirect needed
      }

      // If user is unauthenticated
      if (authStatus == AuthStatus.unauthenticated) {
        // If they are on splash or auth screen, allow them to stay
        if (isSplashRoute) {
          return AppRoutes.auth;
        }
        if (isAuthRoute) {
          logger.d('Redirect: Unauthenticated on splash/auth -> Allowed.');
          return null; // No redirect needed
        }
        // If trying to access any other route, redirect to auth
        logger.d(
          'Redirect: Unauthenticated accessing ($currentLocation) -> Redirecting to auth.',
        );
        return AppRoutes.auth;
      }

      // Default case (shouldn't be reached)
      return null;
    },

    routes: <RouteBase>[
      // Splash Screen
      GoRoute(
        path: AppRoutes.splash,
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),

      // Authentication
      GoRoute(
        path: AppRoutes.auth,
        name: 'auth',
        builder: (context, state) => const LoginScreen(),
      ),
      // --- Main Application Shell ---
      StatefulShellRoute.indexedStack(
        // This builder creates the actual shell UI (Scaffold with BottomNavBar)
        builder: (context, state, navigationShell) {
          // Return the AppShell widget, passing the navigationShell
          return AppShell(navigationShell: navigationShell);
        },
        // Define the branches (tabs) for the shell
        branches: <StatefulShellBranch>[
          // Branch 1: Home Tab
          StatefulShellBranch(
            navigatorKey:
                shellNavigatorKeyHome, // Assign navigator key for this branch
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.home, // e.g., /home
                name: 'home',
                builder: (context, state) => const HomeScreen(),
              ),
            ],
          ),

          // Branch 2: Profile Tab
          StatefulShellBranch(
            navigatorKey:
                shellNavigatorKeyProfile, // Assign navigator key for this branch
            routes: <RouteBase>[
              GoRoute(
                path: AppRoutes.profile, // e.g., /profile
                name: 'profile',
                builder: (context, state) => const ProfileScreen(),
              ),
            ],
          ),

          // Add Branch 3, 4 etc. for more tabs here...
        ],
      ),

      // --- End Main Application Shell ---
    ],

    // Error page
    errorBuilder:
        (context, state) => Scaffold(
          appBar: AppBar(title: const Text('Error')),
          body: Center(child: Text('Page not found or Error: ${state.error}')),
        ),
  );
});
