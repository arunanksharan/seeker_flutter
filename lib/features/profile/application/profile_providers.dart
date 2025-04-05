// lib/features/profile/application/profile_providers.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/models/profile_models.dart';
import 'package:seeker/services/profile_service.dart';
// Import the Notifier and State definitions
import 'package:seeker/features/profile/application/profile_notifier.dart';

// Provider to fetch the user's profile data (Master Copy)
// Moved from home_providers.dart
final profileProvider = FutureProvider.autoDispose<SeekerProfileApiResponse?>((
  ref,
) async {
  // Can add .keepAlive() if needed across app sessions frequently
  final profileService = ref.watch(
    profileServiceProvider,
  ); // Assuming profileServiceProvider exists
  return profileService.getProfile();
});

// Provider for the ProfileNotifier (Manages Editing State)
// Moved from profile_edit_state.dart / profile_notifier.dart
final profileNotifierProvider = StateNotifierProvider.autoDispose<
  ProfileNotifier,
  ProfileState
>((ref) {
  // Pass ref so the notifier can read other providers like profileProvider and profileServiceProvider
  return ProfileNotifier(ref);
});

// Provider for the ProfileService (assuming it's defined elsewhere or define here)
// Example if not defined elsewhere:
// final profileServiceProvider = Provider<ProfileService>((ref) {
//   final dio = ref.watch(dioProvider); // Assuming dioProvider exists
//   return ProfileService(dio);
// });
