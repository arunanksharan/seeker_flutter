// lib/features/home/presentation/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:seeker/features/auth/application/auth_state.dart';
// Import providers
// Removed JobCard import as it's not used for now
// import 'package:seeker/features/home/presentation/widgets/job_card.dart';
// Removed JobModels import as it's not used for now
// import 'package:seeker/models/job_models.dart';
import 'package:seeker/routing/app_router.dart';
import 'package:seeker/utils/logger.dart';
import 'package:seeker/features/profile/application/profile_providers.dart';
import 'package:seeker/theme/app_colors.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // --- WATCH ONLY NECESSARY PROVIDERS ---
    // 1. Watch profile provider for greeting name and profile card status
    final profileAsync = ref.watch(profileProvider);
    // 2. Watch auth state for logout and potentially getting user ID if profile fails
    // final authState = ref.watch(authStateProvider); // Watched implicitly by logout button reading notifier

    // --- REMOVED PROVIDER WATCHES FOR DEPRIORITIZED FEATURES ---
    // final recommendedJobsAsync = ref.watch(recommendedJobsProvider); // DON'T watch jobs
    // final recentJobsAsync = ref.watch(recentJobsProvider);           // DON'T watch jobs
    // final profileCompletion = ref.watch(profileCompletionProvider);  // REMOVED profile completion

    // --- Refresh function only needs to invalidate profile now ---
    Future<void> refreshData() async {
      logger.i("Refreshing HomeScreen data (Profile Only)...");
      // Invalidate only the providers we are actively using on this screen
      ref.invalidate(profileProvider);
      // If other home-specific, non-job providers were added, invalidate them too
      await ref.read(profileProvider.future); // Wait for profile reload
    }

    // Get user's name for greeting
    final greetingName = profileAsync.maybeWhen(
      data: (profile) => profile?.personalDetails?.name?.split(' ').first,
      orElse: () => null, // Use default 'Hi!' if loading or error
    );

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        titleSpacing: 0,
        centerTitle: false,
        title: Padding(
          // Wrap the Column with Padding
          padding: const EdgeInsets.only(
            left: 16.0,
            top: 16.0,
          ), // <-- Add desired left padding here
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                greetingName != null ? 'Hi $greetingName!' : 'Hi!',
                style: textTheme.headlineMedium,
              ),
              Text(
                'Find your dream job today',
                style: textTheme.bodyMedium?.copyWith(
                  // Use withAlpha instead of withOpacity
                  color: colorScheme.onSurface.withAlpha(153), // 60% opacity
                ),
              ),
            ],
          ),
        ),
        actions: [
          // Logout Button remains the same
          IconButton(
            icon: Icon(
              Icons.logout,
              color: colorScheme.onSurface.withAlpha(153),
            ),
            tooltip: 'Logout',
            onPressed: () {
              showDialog(
                context: context,
                builder:
                    (context) => AlertDialog(
                      title: const Text('Confirm Logout'),
                      content: const Text('Are you sure you want to log out?'),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.of(context).pop(),
                          child: Text('Cancel', style: textTheme.bodyMedium),
                        ),
                        TextButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                            ref.read(authStateProvider.notifier).logout();
                          },
                          child: Text('Logout', style: textTheme.bodyMedium),
                        ),
                      ],
                    ),
              );
            },
          ),
          const SizedBox(width: 16),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: refreshData,
        child: ListView(
          // Use ListView for scrollability and refresh indicator
          padding: EdgeInsets.zero,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 16),

                  // --- Simplified Profile Prompt Card ---
                  profileAsync.when(
                    data:
                        (profile) => _buildProfilePromptCard(
                          // Always show prompt card for now
                          context,
                          theme,
                          textTheme,
                          colorScheme,
                          profile == null
                              ? "Create Your Profile"
                              : "Edit Profile", // Adjusted title
                          profile == null
                              ? "Get started to find job recommendations."
                              : "Keep your profile details up to date.",
                        ),
                    error:
                        (e, _) => _buildProfilePromptCard(
                          // Show error state card
                          context,
                          theme,
                          textTheme,
                          colorScheme,
                          "Edit Profile",
                          "Could not load profile details.",
                          null,
                          true,
                        ), // isError flag = true
                    loading:
                        () => const Padding(
                          // Show loading placeholder for card area
                          padding: EdgeInsets.symmetric(vertical: 16.0),
                          child: Center(
                            child: SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            ),
                          ),
                        ),
                  ),

                  // --- End Profile Prompt Card ---
                  const SizedBox(height: 24.0),

                  // --- Search Placeholder (remains the same) ---
                  InkWell(
                    onTap: () {
                      logger.i(
                        "Search tapped - Navigate to search screen (Not Implemented)",
                      );
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Search Coming Soon!")),
                      );
                    },
                    child: Container(
                      /* ... search bar styling ... */
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 12.0,
                      ),
                      decoration: BoxDecoration(
                        color: theme.scaffoldBackgroundColor,
                        borderRadius: BorderRadius.circular(8.0),
                        border: Border.all(color: Colors.grey[100]!),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.search,
                            size: 20,
                            color: colorScheme.onSurface.withAlpha(153),
                          ),
                          const SizedBox(width: 8.0),
                          Text(
                            'Search for jobs, skills, companies...',
                            style: textTheme.bodyMedium?.copyWith(
                              color: colorScheme.onSurface.withAlpha(153),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 24.0),
                ],
              ),
            ), // End of Padding wrapper
            // --- Recommended Jobs Section (Placeholder UI) ---
            _buildSectionHeader(context, 'Recommended for you', () {
              // Show "Coming Soon" directly on tap
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Job Recommendations Coming Soon!"),
                ),
              );
            }),
            // Display placeholder content instead of watching provider
            _buildJobSectionPlaceholder(context, true), // true for horizontal
            const SizedBox(height: 32.0),

            // --- Recent Jobs Section (Placeholder UI) ---
            _buildSectionHeader(context, 'Recent jobs', () {
              // Show "Coming Soon" directly on tap
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text("Recent Jobs List Coming Soon!")),
              );
            }),
            // Display placeholder content instead of watching provider
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: _buildJobSectionPlaceholder(
                context,
                false,
              ), // false for vertical
            ),
            const SizedBox(height: 40.0), // Bottom padding
          ],
        ),
      ),
    );
  }

  // --- Helper Widgets ---

  // Keep section header
  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    VoidCallback onSeeAllTap,
  ) {
    // ... (implementation remains the same) ...
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: theme.textTheme.headlineSmall),
          TextButton(
            onPressed: onSeeAllTap, // Use the passed callback
            child: Text(
              'See all',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Keep simple empty/error states if needed by profile card
  // Widget _buildEmptyState(String message) {
  //   /* ... remains the same ... */
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
  //     child: Center(
  //       child: Text(
  //         message,
  //         style: TextStyle(color: Colors.grey[600]),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildErrorState(String message) {
  //   /* ... remains the same ... */
  //   return Padding(
  //     padding: const EdgeInsets.symmetric(vertical: 32.0, horizontal: 24.0),
  //     child: Center(
  //       child: Text(
  //         message,
  //         style: TextStyle(color: Colors.red[600]),
  //         textAlign: TextAlign.center,
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildLoadingState() {
  //   /* ... remains the same ... */
  //   return const Padding(
  //     padding: EdgeInsets.symmetric(vertical: 48.0),
  //     child: Center(child: CircularProgressIndicator()),
  //   );
  // }

  // Keep and simplify Profile Prompt Card (no progress bar)
  Widget _buildProfilePromptCard(
    BuildContext context,
    ThemeData theme,
    TextTheme textTheme,
    ColorScheme colorScheme,
    String title,
    String message, [
    double? progress,
    bool isError = false, // Progress ignored now
  ]) {
    return Card(
      clipBehavior: Clip.antiAlias,
      color: isError ? colorScheme.error.withAlpha(153) : AppColors.primary50,
      elevation: isError ? 0 : 1, // No shadow for error?
      shape: RoundedRectangleBorder(
        side:
            isError
                ? BorderSide(color: colorScheme.error)
                : BorderSide.none, // Optional border for error
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: InkWell(
        onTap: () {
          if (!isError) {
            // Only navigate if not an error card
            logger.i("Navigating to Profile Edit screen...");
            context.push(AppRoutes.profile);
          } else {
            // Option: Allow retry on error tap
            logger.i("Profile error card tapped.");
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text("Error loading profile.")),
            );
            // Potentially invalidate provider: ref.invalidate(profileProvider);
          }
        },
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16.0,
            vertical: 20.0,
          ), // Adjusted padding
          child: Row(
            children: [
              Icon(
                isError
                    ? Icons.error_outline
                    : Icons.person_outline, // Changed icon
                color:
                    isError
                        ? colorScheme.error
                        : colorScheme.primary, // Use primary/error color
                size: 24,
              ),
              const SizedBox(width: 12.0),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4.0),
                    Text(message, style: textTheme.bodyMedium),
                  ],
                ),
              ),
              if (!isError) // Show arrow only if not error
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
                  color: colorScheme.onSurface.withAlpha(153),
                ),
            ],
          ),
        ),
      ),
    );
  }

  // --- NEW: Placeholder for Job Sections ---
  Widget _buildJobSectionPlaceholder(BuildContext context, bool isHorizontal) {
    // Simple placeholder, replace with actual UI if needed later
    return Container(
      height:
          isHorizontal
              ? 100
              : null, // Give some height for horizontal scroll area
      padding: const EdgeInsets.symmetric(vertical: 32),
      alignment: Alignment.center,
      child: Text(
        "${isHorizontal ? 'Recommended' : 'Recent'} Jobs Coming Soon!",
        style: Theme.of(
          context,
        ).textTheme.bodyMedium?.copyWith(color: Colors.grey),
      ),
      // Optionally add placeholder cards:
      // child: isHorizontal ? Row(...) : Column(...)
    );
  }
} // End of HomeScreen Widget
