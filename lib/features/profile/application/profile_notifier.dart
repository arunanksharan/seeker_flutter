// lib/features/profile/application/profile_notifier.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:seeker/features/profile/application/profile_providers.dart'; // Import profileProvider
import 'package:seeker/models/profile_models.dart'; // Import ALL profile models
import 'package:seeker/services/profile_service.dart'; // Import ProfileService provider definition
import 'package:seeker/utils/logger.dart';
import 'package:seeker/core/errors/exceptions.dart'; // Import custom exceptions

part 'profile_notifier.freezed.dart'; // Link to generated file

// --- State Definition ---
@freezed
abstract class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(true) bool isLoading,
    @Default(false) bool isEditing,
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default(<String, dynamic>{}) Map<String, dynamic> profileData,
    String? id, // Changed from profileId
    String? seekerId,
    @Default(false) bool dataLoaded,
    @Default(false) bool dataLoadAttempted,
  }) = _ProfileState;
}

// --- Notifier Definition ---
class ProfileNotifier extends StateNotifier<ProfileState> {
  final Ref _ref;

  ProfileNotifier(this._ref) : super(const ProfileState()) {
    _loadInitialData();
  }

  // Load initial data from the main profileProvider
  // Merges data from nested fields into the flat map if current_profile is missing keys.
  Future<void> _loadInitialData() async {
    // Ensure we only load once unless invalidated
    if (state.dataLoadAttempted) return;

    logger.d("ProfileNotifier: Starting _loadInitialData()");
    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      dataLoadAttempted: true,
    );
    logger.d("ProfileNotifier: Loading initial data...");
    try {
      final profileApiResponse = await _ref.read(profileProvider.future);

      if (profileApiResponse != null) {
        logger.d(
          "ProfileNotifier: Profile API response received: ${profileApiResponse.id}, ${profileApiResponse.seekerId}, ${profileApiResponse.currentProfile}",
        );

        // Debug the API response to see what's coming from the backend
        logger.d("ProfileNotifier: API response ID: ${profileApiResponse.id}");
        logger.d(
          "ProfileNotifier: API response seekerId: ${profileApiResponse.seekerId}",
        );
        logger.d(
          "ProfileNotifier: Has personalDetails: ${profileApiResponse.personalDetails != null}",
        );
        logger.d(
          "ProfileNotifier: Has contactDetails: ${profileApiResponse.contactDetails != null}",
        );
        logger.d(
          "ProfileNotifier: Has currentProfile: ${profileApiResponse.currentProfile != null}",
        );
        if (profileApiResponse.currentProfile != null) {
          logger.d(
            "ProfileNotifier: currentProfile keys: ${profileApiResponse.currentProfile!.keys.toList()}",
          );
        }

        // Create initialData map - IMPORTANT FIX: Check if currentProfile is null before using it
        Map<String, dynamic> initialData =
            profileApiResponse.currentProfile != null
                ? Map<String, dynamic>.from(profileApiResponse.currentProfile!)
                : <String, dynamic>{};

        logger.d("Initial data from current_profile: $initialData");

        // --- Merge/Default values from nested structures if needed ---

        final itiVerifiedValue = initialData['iti_verified'];
        if (itiVerifiedValue != null) {
          if (itiVerifiedValue is String) {
            // If it's a string, convert "true" to bool true, otherwise false
            initialData['iti_verified'] =
                (itiVerifiedValue.toLowerCase() == 'true');
            logger.d(
              "Corrected 'iti_verified' from String to bool: ${initialData['iti_verified']}",
            );
          } else if (itiVerifiedValue is bool) {
            // Already a bool, no change needed
            logger.d("'iti_verified' is already bool: $itiVerifiedValue");
          } else {
            // Handle other unexpected types if necessary, default to false
            logger.w(
              "Unexpected type for 'iti_verified': ${itiVerifiedValue.runtimeType}, defaulting to false.",
            );
            initialData['iti_verified'] = false;
          }
        } else {
          // Handle null case if needed, default to false
          logger.d(
            "'iti_verified' key not found or null, defaulting to false.",
          );
          initialData['iti_verified'] = false;
        }

        // Correct 'user_consent'
        final userConsentValue = initialData['user_consent'];
        if (userConsentValue != null) {
          if (userConsentValue is String) {
            initialData['user_consent'] =
                (userConsentValue.toLowerCase() == 'true');
            logger.d(
              "Corrected 'user_consent' from String to bool: ${initialData['user_consent']}",
            );
          } else if (userConsentValue is bool) {
            logger.d("'user_consent' is already bool: $userConsentValue");
          } else {
            logger.w(
              "Unexpected type for 'user_consent': ${userConsentValue.runtimeType}, defaulting to false.",
            );
            initialData['user_consent'] = false;
          }
        } else {
          logger.d(
            "'user_consent' key not found or null, defaulting to false.",
          );
          initialData['user_consent'] = false;
        }
        // --- *** END
        final pd = profileApiResponse.personalDetails;
        if (pd != null) {
          logger.d("ProfileNotifier: Adding personalDetails to initialData");
          // Only add if not already present in currentProfile
          initialData.putIfAbsent('name', () => pd.name);
          initialData.putIfAbsent('father_name', () => pd.fatherName);
          initialData.putIfAbsent('mother_name', () => pd.motherName);
          initialData.putIfAbsent('gender', () => pd.gender);
          initialData.putIfAbsent('dob', () => pd.dob);
        }
        final cd = profileApiResponse.contactDetails;
        if (cd != null) {
          initialData.putIfAbsent(
            'hometown_and_locality',
            () => cd.currentAddress?.street ?? cd.permanentAddress?.street,
          );
          initialData.putIfAbsent('primary_mobile', () => cd.primaryMobile);
          initialData.putIfAbsent('email', () => cd.email);
        }
        final iti =
            profileApiResponse.itiDetails?.isNotEmpty == true
                ? profileApiResponse.itiDetails!.first
                : null;
        if (iti != null) {
          initialData.putIfAbsent('institute_name', () => iti.instituteName);
          initialData.putIfAbsent('trade', () => iti.trade);
          initialData.putIfAbsent(
            'training_duration',
            () => iti.trainingDuration,
          );
          initialData.putIfAbsent(
            'state_registration_number',
            () => iti.rollNumber,
          );
        }
        final jp = profileApiResponse.jobPreferences;
        if (jp != null) {
          initialData.putIfAbsent(
            'preferred_job_location',
            () => jp.preferredJobLocations,
          );
          initialData.putIfAbsent('current_location', () => jp.currentLocation);
          initialData.putIfAbsent(
            'total_experience_years',
            () => jp.totalExperienceYears,
          );
          initialData.putIfAbsent(
            'current_monthly_salary',
            () => jp.currentMonthlySalary,
          );
          initialData.putIfAbsent(
            'expected_monthly_salary',
            () => jp.maxSalaryExpectation,
          );
        }
        final languages = profileApiResponse.languageProficiencies;
        if (languages != null && languages.isNotEmpty) {
          initialData.putIfAbsent(
            'languages_spoken',
            () => languages.map((l) => l.language).join(', '),
          );
        }

        // Update state with loaded data
        state = state.copyWith(
          isLoading: false,
          errorMessage: null,
          id: profileApiResponse.id,
          seekerId: profileApiResponse.seekerId,
          profileData: initialData,
          dataLoaded: true,
        );
        logger.d(
          "ProfileNotifier: Data loaded successfully with ${initialData.length} fields.",
        );
      } else {
        // Handle case where profile doesn't exist yet
        state = state.copyWith(
          isLoading: false,
          errorMessage: null, // No error, just empty profile
          profileData: <String, dynamic>{},
          dataLoaded: true, // Mark as loaded, just empty
        );
        logger.d("ProfileNotifier: No profile data exists yet.");
      }
    } catch (e, stackTrace) {
      logger.e(
        "ProfileNotifier: Error loading profile data",
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        errorMessage: "Failed to load profile: ${e.toString()}",
        dataLoaded: false,
      );
    }
  }

  // Toggle edit mode
  void setEditMode(bool isEditing) {
    if (isEditing == state.isEditing) {
      logger.d(
        "ProfileNotifier: Edit mode already set to $isEditing, no change needed",
      );
      return; // No change needed
    }

    logger.d(
      "ProfileNotifier: Changing edit mode from ${state.isEditing} to $isEditing",
    );

    // Create a new state with updated isEditing flag
    final newState = state.copyWith(
      isEditing: isEditing,
      // Clear error message when entering edit mode
      errorMessage: isEditing ? null : state.errorMessage,
    );

    // Update the state
    state = newState;

    logger.d(
      "ProfileNotifier: Edit mode set to $isEditing, isEditing in new state: ${newState.isEditing}",
    );
  }

  // Update a single field in the profile data
  void updateField(String key, dynamic value) {
    logger.d("ProfileNotifier: Updating field '$key' to '$value'");
    final updatedData = Map<String, dynamic>.from(state.profileData);
    updatedData[key] = value;
    state = state.copyWith(profileData: updatedData);
    logger.d(
      "ProfileNotifier: Field updated, profileData now has keys: ${updatedData.keys.toList()}",
    );
  }

  // Save profile changes
  Future<bool> saveProfile() async {
    state = state.copyWith(isSaving: true, errorMessage: null);
    logger.d("ProfileNotifier: Saving profile...");

    try {
      final profileMap = Map<String, dynamic>.from(state.profileData);
      final isUpdate = state.id != null;

      // --- ** Begin Mapping Step ** ---
      // 1. Map PersonalDetails
      final personalDetails = PersonalDetails(
        name: profileMap['name'] as String?,
        fatherName: profileMap['father_name'] as String?,
        motherName: profileMap['mother_name'] as String?,
        gender: profileMap['gender'] as String?,
        dob: profileMap['dob'] as String?,
      );

      // 2. Map ContactDetails with nested Address
      final contactDetails = ContactDetails(
        primaryMobile: profileMap['primary_mobile'] as String?,
        email: profileMap['email'] as String?,
        // Map addresses if needed
        currentAddress: Address(
          street: profileMap['hometown_and_locality'] as String?,
          // Add other address fields if needed
        ),
        // permanentAddress can be added similarly if needed
      );

      // 3. Map ITIDetails
      final itiDetails = [
        ITIDetail(
          instituteName: profileMap['institute_name'] as String?,
          trade: profileMap['trade'] as String?,
          trainingDuration: profileMap['training_duration'] as String?,
          rollNumber: profileMap['state_registration_number'] as String?,
          // Add other ITI fields if needed
        ),
      ];

      // 4. Map JobPreferences
      final jobPreferences = JobPreferences(
        preferredJobLocations: profileMap['preferred_job_location'] as String?,
        currentLocation: profileMap['current_location'] as String?,
        totalExperienceYears:
            tryParseNum(profileMap['total_experience_years'])?.toString(),
        currentMonthlySalary:
            profileMap['current_monthly_salary']
                ?.toString(), // API might expect string or num
        maxSalaryExpectation:
            profileMap['expected_monthly_salary']
                ?.toString(), // API might expect string or num
        // Map lists if needed:
        // jobTypes: (profileMap['job_types'] as List?)?.cast<String>().toList(),
      );

      // 5. Map LanguageProficiencies
      List<LanguageProficiency>? languageProficiencies;
      final languagesString = profileMap['languages_spoken'] as String?;
      if (languagesString != null && languagesString.trim().isNotEmpty) {
        languageProficiencies =
            languagesString
                .split(',')
                .where(
                  (lang) => lang.trim().isNotEmpty,
                ) // Ensure non-empty after splitting
                .map((lang) => LanguageProficiency(language: lang.trim()))
                .toList();
        if (languageProficiencies.isEmpty) languageProficiencies = null;
      }

      // --- Construct the final request object ---
      // Include all mapped nested objects AND the flat currentProfile map
      final requestData = SeekerProfileApiRequest(
        personalDetails: personalDetails,
        contactDetails: contactDetails,
        itiDetails: itiDetails,
        jobPreferences: jobPreferences,
        languageProficiencies: languageProficiencies,
        // **** ADD MAPPINGS FOR OTHER SECTIONS IF EDITED ****
        // skills: ...,
        // workExperiences: ...,
        // certifications: ...,
        // identificationDocs: ...,
        // bankDetails: ...,
        // *****************************************************
        currentProfile: profileMap, // Send the modified flat map too
      );
      // logger.d("Mapped request data: ${requestData.toJson()}"); // Careful logging sensitive data
      // --- ** End Mapping Step **-

      final profileService = _ref.read(profileServiceProvider);
      final savedProfile = await profileService.updateProfile(
        profileData: requestData,
        isUpdate: isUpdate,
      );

      // Update state with saved data from the response
      final updatedProfileMap = Map<String, dynamic>.from(
        savedProfile.currentProfile ?? profileMap,
      );
      state = state.copyWith(
        isSaving: false,
        errorMessage: null,
        id: savedProfile.id, // Use 'id' here
        seekerId: savedProfile.seekerId,
        profileData: updatedProfileMap,
        isEditing: false, // Exit edit mode on successful save
        dataLoaded: true,
        isLoading: false,
      );

      // Invalidate profileProvider so other parts of the app get the fresh data
      _ref.invalidate(profileProvider);
      logger.i("Profile saved successfully. Invalidated profileProvider.");
      return true;
    } on BadRequestException catch (e, stackTrace) {
      // Catch specific validation/conflict errors
      logger.e(
        "BadRequestException saving profile",
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Failed to save: ${e.message}",
      ); // Show specific message
      return false;
    } on NetworkException catch (e, stackTrace) {
      // Catch specific network errors
      logger.e(
        "NetworkException saving profile",
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Network Error: ${e.message}. Please check connection.",
      );
      return false;
    } catch (e, stackTrace) {
      // Catch any other errors
      logger.e("Error saving profile", error: e, stackTrace: stackTrace);
      state = state.copyWith(
        isSaving: false,
        errorMessage: "Failed to save profile: ${e.toString()}",
      );
      return false;
    }
  }

  // Helper to safely parse numbers
  num? tryParseNum(dynamic value) {
    if (value == null) return null;
    if (value is num) return value;
    if (value is String) return num.tryParse(value);
    return null;
  }
}

// Remember to run build_runner if ProfileState was modified:
// flutter pub run build_runner build --delete-conflicting-outputs
