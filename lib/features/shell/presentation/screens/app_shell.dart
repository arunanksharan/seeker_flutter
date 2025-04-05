// lib/features/shell/presentation/screens/app_shell.dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/routing/app_router.dart'; // Import AppRoutes

class AppShell extends StatelessWidget {
  /// The navigation shell and container for the branch Navigators.
  final StatefulNavigationShell navigationShell;

  const AppShell({super.key, required this.navigationShell});

  // Calculates the current index based on the router location
  static int _calculateSelectedIndex(BuildContext context) {
    final String location = GoRouterState.of(context).matchedLocation;
    if (location.startsWith(AppRoutes.home)) {
      return 0; // Home is index 0
    }
    if (location.startsWith(AppRoutes.profile)) {
      return 1; // Profile is index 1
    }
    // Default to home if route doesn't match known tabs
    return 0;
  }

  // Navigates to the correct tab route using GoRouter branch mechanism
  void _onTabTap(int index) {
    // use GoRouterStateExt switchTab method to navigate to the new tab
    // The index typically corresponds to the index of the routes defined within
    // the ShellRoute in app_router.dart
    navigationShell.goBranch(
      index,
      // Navigate to the initial location when tapping the item that is already active
      initialLocation: index == navigationShell.currentIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentIndex = _calculateSelectedIndex(context);

    return Scaffold(
      // The body will be the actual screen content from the nested routes
      // managed by StatefulNavigationShell
      body: navigationShell, // This displays the current tab's screen
      // The persistent bottom navigation bar
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex, // Highlights the correct tab
        onTap: _onTabTap, // Handles navigation when a tab is tapped
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_outlined),
            activeIcon: Icon(
              Icons.home,
            ), // Optional: different icon when active
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person_outline),
            activeIcon: Icon(Icons.person), // Optional
            label: 'Profile',
          ),
          // Add other items here if you have more tabs later
        ],
        // Optional: Customize appearance (type, colors, etc.)
        // type: BottomNavigationBarType.fixed,
        // selectedItemColor: Theme.of(context).colorScheme.primary,
        // unselectedItemColor: Colors.grey,
      ),
    );
  }
}
