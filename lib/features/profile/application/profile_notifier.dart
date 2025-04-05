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
class ProfileState with _$ProfileState {
  const factory ProfileState({
    @Default(true) bool isLoading,
    @Default(false) bool isEditing,
    @Default(false) bool isSaving,
    String? errorMessage,
    @Default({}) Map<String, dynamic> profileData,
    String? id, // Changed from profileId
    String? seekerId,
    @Default(false) bool dataLoaded,
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

    state = state.copyWith(
      isLoading: true,
      errorMessage: null,
      dataLoadAttempted: true,
    );
    logger.d("ProfileNotifier: Loading initial data...");
    try {
      final profileApiResponse = await _ref.read(profileProvider.future);

      if (profileApiResponse != null) {
        logger.d("ProfileNotifier: Profile API response received.");
        Map<String, dynamic> initialData = Map<String, dynamic>.from(
          profileApiResponse.currentProfile ?? {},
        );
        logger.d("Initial data from current_profile: $initialData");

        // --- Merge/Default values from nested structures if needed ---
        final pd = profileApiResponse.personalDetails;
        if (pd != null) {
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
        initialData.removeWhere((key, value) => value == null);
        logger.d("Final initial data after merge: $initialData");

        state = state.copyWith(
          profileData: initialData,
          id: profileApiResponse.id, // Use 'id' here
          seekerId: profileApiResponse.seekerId,
          isLoading: false,
          dataLoaded: true,
          errorMessage: null,
        );
        logger.i("ProfileNotifier: State initialized successfully.");
      } else {
        state = state.copyWith(
          isLoading: false,
          dataLoaded: true,
          errorMessage: null,
          profileData: {},
        );
        logger.i(
          "ProfileNotifier: No existing profile found, initializing empty state.",
        );
      }
    } catch (e, stackTrace) {
      logger.e(
        "ProfileNotifier: Error loading initial profile data",
        error: e,
        stackTrace: stackTrace,
      );
      state = state.copyWith(
        isLoading: false,
        dataLoaded: false,
        errorMessage: "Failed to load profile data: $e",
      );
    }
  }

  // Toggle between view and edit mode
  void setEditMode(bool isEditing) {
    state = state.copyWith(isEditing: isEditing, errorMessage: null);
    if (!isEditing && state.dataLoaded) {
      // If cancelling edit, reload initial data to discard changes made in the map
      logger.i("Edit cancelled, reloading initial data for form.");
      // Re-trigger the load to reset the map to the last fetched state
      // Setting dataLoadAttempted back to false ensures reload happens
      state = state.copyWith(dataLoadAttempted: false);
      _loadInitialData();
    }
  }

  // Update a specific field in the local state map during editing
  void updateField(String key, dynamic value) {
    if (!state.isEditing) return;
    logger.d("Updating field: $key = $value");
    state = state.copyWith(
      profileData: {...state.profileData, key: value},
      errorMessage: null,
    );
  }

  // Save the profile data (Create or Update) - WITH FULL MAPPING
  Future<bool> saveProfile() async {
    if (!state.dataLoaded && !state.isLoading) {
      state = state.copyWith(
        errorMessage: "Cannot save, profile data not loaded.",
      );
      return false;
    }
    if (state.isSaving) {
      logger.w("SaveProfile called while already saving.");
      return false;
    }

    state = state.copyWith(isSaving: true, errorMessage: null);
    final profileMap = state.profileData;
    // Determine if creating new (no id) or updating existing
    final isUpdate = state.id != null && state.id!.isNotEmpty;
    logger.i("Attempting to save profile. Is update: $isUpdate");

    try {
      // --- ** MAPPING: Flat Map -> Nested Request Object ** ---
      logger.d("Mapping flat profile data to nested request object...");

      // Helper function to safely parse string to num (int/double)
      num? tryParseNum(dynamic value) {
        if (value is num) return value;
        if (value is String) return num.tryParse(value);
        return null;
      }

      // 1. Map PersonalDetails
      final personalDetails = PersonalDetails(
        name: profileMap['name'] as String?,
        fatherName: profileMap['father_name'] as String?,
        motherName: profileMap['mother_name'] as String?,
        gender: profileMap['gender'] as String?,
        dob: profileMap['dob'] as String?,
        // Map other fields like guardianName, profilePictureUrl if they are in profileMap
      );

      // 2. Map ContactDetails
      final contactDetails = ContactDetails(
        primaryMobile: profileMap['primary_mobile'] as String?,
        email: profileMap['email'] as String?,
        currentAddress: Address(
          street: profileMap['hometown_and_locality'] as String?,
        ),
        // Map permanentAddress if needed
      );

      // 3. Map ITIDetails (assuming one entry)
      final itiDetails =
          (profileMap.containsKey('institute_name') ||
                  profileMap.containsKey('trade') ||
                  profileMap.containsKey('state_registration_number'))
              ? [
                ITIDetail(
                  instituteName: profileMap['institute_name'] as String?,
                  trade: profileMap['trade'] as String?,
                  trainingDuration: profileMap['training_duration'] as String?,
                  rollNumber:
                      profileMap['state_registration_number'] as String?,
                  // Map passingYear, dates etc. if present in profileMap
                ),
              ]
              : null;

      // 4. Map JobPreferences
      final jobPreferences = JobPreferences(
        preferredJobLocations: profileMap['preferred_job_location'] as String?,
        currentLocation: profileMap['current_location'] as String?,
        totalExperienceYears:
            profileMap['total_experience_years']
                ?.toString(), // API might expect string or num
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
      // --- ** End Mapping Step ** ---

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
}


// Remember to run build_runner if ProfileState was modified:
// flutter pub run build_runner build --delete-conflicting-outputs