// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seeker/features/profile/application/profile_notifier.dart';
import 'package:seeker/features/profile/application/profile_providers.dart';
import 'package:seeker/theme/app_colors.dart';
import 'package:seeker/utils/logger.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  final _formKey = GlobalKey<FormState>();

  // Controllers for text fields - needed for editing
  // Initialized when switching to edit mode or on load if starting in edit mode
  final Map<String, TextEditingController> _controllers = {};

  // List of fields to display/edit based on your flat structure
  // Adjust this list based on EXACTLY what fields you want to show/edit
  final List<Map<String, dynamic>> _formFields = [
    {'key': 'name', 'label': 'Name', 'required': true},
    {'key': 'father_name', 'label': "Father's Name"},
    {'key': 'mother_name', 'label': "Mother's Name"},
    {
      'key': 'dob',
      'label': 'Date of Birth',
      'type': 'date',
    }, // Special type for date picker
    {
      'key': 'gender',
      'label': 'Gender',
      'type': 'gender',
    }, // Special type for radio

    {
      'key': 'hometown_and_locality',
      'label': 'Address',
      'maxLines': 3,
    }, // Maps to Address
    {
      'key': 'state_registration_number',
      'label': 'NCVT Roll No.',
      'required': true,
    }, // ITI
    {'key': 'institute_name', 'label': 'Institute Name'}, // ITI
    {'key': 'trade', 'label': 'Trade'}, // ITI
    {'key': 'training_duration', 'label': 'Training Duration'}, // ITI

    {
      'key': 'total_experience_years',
      'label': 'Total Experience (Years)',
      'keyboard': TextInputType.numberWithOptions(decimal: true),
    }, // Job Prefs
    {'key': 'current_location', 'label': 'Current Location'}, // Job Prefs
    {
      'key': 'preferred_job_location',
      'label': 'Preferred Job Locations',
      'hint': 'e.g., Mumbai, Bangalore',
    }, // Job Prefs
    {
      'key': 'languages_spoken',
      'label': 'Languages Spoken',
      'hint': 'e.g., English, Hindi',
    }, // Language
    {
      'key': 'current_monthly_salary',
      'label': 'Current Monthly Salary (INR)',
      'keyboard': TextInputType.number,
    }, // Job Prefs
    {
      'key': 'expected_monthly_salary',
      'label': 'Expected Monthly Salary (INR)',
      'keyboard': TextInputType.number,
    }, // Job Prefs
    {
      'key': 'user_consent',
      'label': 'I consent to my data usage', // Example Label - adjust as needed
      'type': 'checkbox',
      'editable': true, // This one can be changed by the user
    },
    {
      'key': 'iti_verified',
      'label': 'ITI Verified Status', // Example Label
      'type': 'checkbox',
      'editable': false, // This one cannot be changed by the user
    },
    // Add other fields from your flat structure here...
    // {'key': 'skills', 'label': 'Skills', 'type': 'chips'}, // Example for chips
  ];

  @override
  void initState() {
    super.initState();
    // Initialize controllers for all fields at start
    for (var field in _formFields) {
      if (field['type'] != 'gender') {
        // Gender handled by Radio group value
        _controllers[field['key']] = TextEditingController();
      }
    }
    // Initialize controllers AFTER first build using listener
    WidgetsBinding.instance.addPostFrameCallback((_) {
      logger.d("ProfileScreen: Post frame callback triggered");
      _setupListener();

      // Force immediate data load
      final profileData = ref.read(profileNotifierProvider).profileData;
      logger.d("ProfileScreen: Initial profileData: $profileData");
      _initializeFormFields(profileData: profileData);

      // // Force edit mode for testing
      // Future.delayed(const Duration(seconds: 1), () {
      //   if (mounted) {
      //     logger.d("ProfileScreen: Forcing edit mode for testing");
      //     ref.read(profileNotifierProvider.notifier).setEditMode(true);
      //   }
      // });
    });
  }

  void _setupListener() {
    logger.d("ProfileScreen: Setting up state listener");
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      logger.d("ProfileScreen: ProfileState changed");
      logger.d(
        "ProfileScreen: isLoading: ${next.isLoading}, dataLoaded: ${next.dataLoaded}",
      );

      // Only update fields if data is loaded and not in edit mode
      if (next.dataLoaded && !next.isLoading && !next.isEditing) {
        logger.d("ProfileScreen: Updating form fields from listener");
        _initializeFormFields(profileData: next.profileData);
      }

      // Handle save success/error messages via SnackBar
      if (previous?.isSaving == true && next.isSaving == false) {
        if (mounted) {
          if (next.errorMessage != null) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(next.errorMessage!),
                backgroundColor: Colors.red,
              ),
            );
          } else {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Profile saved successfully!'),
                backgroundColor: Colors.green,
              ),
            );
          }
        }
      }
    });
  }

  // Initialize/Update controllers based on state data
  void _initializeFormFields({Map<String, dynamic>? profileData}) {
    final data = profileData ?? ref.read(profileNotifierProvider).profileData;
    if (mounted) {
      logger.d(
        "ProfileScreen: Initializing/Updating form controllers with data: $data",
      );
      logger.d(
        "ProfileScreen: Data has ${data.length} fields with keys: ${data.keys.toList()}",
      );

      for (var field in _formFields) {
        final key = field['key'] as String;
        final controller = _controllers[key];
        if (controller != null) {
          // Check if controller exists (skip gender)
          final value = data[key]?.toString() ?? '';
          logger.d("ProfileScreen: Setting field '$key' to value: '$value'");
          controller.text = value;
        } else if (field['type'] == 'gender') {
          // For gender field, just log the value since it's handled by radio buttons
          final value = data[key]?.toString() ?? '';
          logger.d("ProfileScreen: Gender field value: '$value'");
        }
      }
    }
  }

  @override
  void dispose() {
    // Dispose all controllers
    _controllers.forEach((_, controller) => controller.dispose());
    super.dispose();
  }

  // Select Date action
  Future<void> _selectDate(BuildContext context) async {
    final notifier = ref.read(profileNotifierProvider.notifier);
    final currentDobString = notifier.state.profileData['dob'] as String?;
    DateTime initialDate = DateTime.now();
    try {
      if (currentDobString != null && currentDobString.isNotEmpty) {
        initialDate = DateFormat('dd-MM-yyyy').parse(currentDobString);
      }
    } catch (e) {
      /* ignore */
    }

    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
    );
    if (picked != null) {
      final formattedDate = DateFormat('dd-MM-yyyy').format(picked);
      _controllers['dob']?.text = formattedDate; // Update controller
      notifier.updateField('dob', formattedDate); // Update state
    }
  }

  // Save Form action
  void _saveForm() {
    if (_formKey.currentState!.validate()) {
      FocusScope.of(context).unfocus();
      ref
          .read(profileNotifierProvider.notifier)
          .saveProfile(); // Save triggers state update
    } else {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('Please fix errors.')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(profileNotifierProvider);
    final notifier = ref.read(profileNotifierProvider.notifier);
    final profileData = state.profileData;

    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    logger.d(
      "ProfileScreen: Building UI - isLoading: ${state.isLoading}, dataLoaded: ${state.dataLoaded}, isEditing: ${state.isEditing}",
    );

    // Handle initial loading state
    if (state.isLoading && !state.dataLoaded) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.onSurface,
          titleSpacing: 0,
          centerTitle: false,

          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text('View Profile', style: textTheme.headlineMedium),
          ),
        ),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Handle initial loading error state
    if (!state.dataLoaded && state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: theme.scaffoldBackgroundColor,
          foregroundColor: theme.colorScheme.onSurface,
          titleSpacing: 0,
          centerTitle: false,

          title: Padding(
            padding: const EdgeInsets.only(left: 16.0),
            child: Text(
              state.isEditing ? 'Edit Profile' : 'View Profile',
              style: textTheme.headlineMedium,
            ),
          ),
        ),
        body: Center(child: Text("Error: ${state.errorMessage}")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: theme.scaffoldBackgroundColor,
        foregroundColor: theme.colorScheme.onSurface,
        titleSpacing: 0,
        centerTitle: false,

        title: Padding(
          padding: const EdgeInsets.only(left: 16.0),
          child: Text(
            state.isEditing ? 'Edit Profile' : 'View Profile',
            style: textTheme.headlineMedium,
          ),
        ),
        actions: [
          // Toggle Edit/Cancel Button
          if (state.dataLoaded) // Show only if data loaded ok
            TextButton(
              onPressed:
                  state.isSaving
                      ? null
                      : () {
                        logger.d(
                          "Edit/Cancel button pressed, current isEditing: ${state.isEditing}",
                        );
                        notifier.setEditMode(!state.isEditing);
                      },
              child: Text(
                state.isEditing ? 'Cancel' : 'Edit',
                style: textTheme.titleMedium?.copyWith(
                  color: colorScheme.primary,
                ),
              ),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          // Force a refresh of the profile data
          ref.invalidate(profileProvider);
          await ref.read(profileProvider.future);
          _initializeFormFields();
        },
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // Main form content
              SingleChildScrollView(
                physics:
                    const AlwaysScrollableScrollPhysics(), // Always allow scrolling
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // // Debug info for development
                    // Container(
                    //   padding: const EdgeInsets.all(8),
                    //   color: Colors.amber.withOpacity(0.2),
                    //   child: Column(
                    //     crossAxisAlignment: CrossAxisAlignment.start,
                    //     children: [
                    //       Text("Debug - isEditing: ${state.isEditing}"),
                    //       Text("Debug - isLoading: ${state.isLoading}"),
                    //       Text("Debug - isSaving: ${state.isSaving}"),
                    //       Text("Debug - dataLoaded: ${state.dataLoaded}"),
                    //     ],
                    //   ),
                    // ),
                    // const SizedBox(height: 16),

                    // Form with fields
                    Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Dynamically build form fields
                          ..._formFields
                              .map(
                                (field) => _buildFormField(
                                  field,
                                  profileData,
                                  state.isEditing,
                                  notifier,
                                ),
                              )
                              .expand(
                                (widget) => [
                                  widget,
                                  const SizedBox(height: 24),
                                ],
                              ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 16), // Space before save button
                    // Save Button (visible only in edit mode)
                    if (state.isEditing)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: ElevatedButton(
                          onPressed: state.isSaving ? null : _saveForm,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Theme.of(context).primaryColor,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 32,
                              vertical: 12,
                            ),
                          ),
                          child:
                              state.isSaving
                                  ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      color: Colors.white,
                                    ),
                                  )
                                  : const Text('Save Changes'),
                        ),
                      ),

                    // Display Save Error Message Inline
                    if (state.errorMessage != null &&
                        !state.isLoading &&
                        !state.isSaving)
                      Padding(
                        padding: const EdgeInsets.only(top: 16.0),
                        child: Center(
                          child: Text(
                            state.errorMessage!,
                            style: TextStyle(color: theme.colorScheme.error),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),

                    const SizedBox(height: 24), // Bottom padding
                  ],
                ),
              ),

              // Overlay loading indicator when saving
              if (state.isSaving)
                Container(
                  color: Colors.black.withOpacity(0.1),
                  child: const Center(child: CircularProgressIndicator()),
                ),
            ],
          ),
        ),
      ),
      floatingActionButton:
          state.isEditing
              ? null
              : FloatingActionButton(
                onPressed: () {
                  logger.d("Edit FAB pressed");
                  notifier.setEditMode(true);
                },
                child: const Icon(Icons.edit),
              ),
    );
  }

  // --- Dynamic Form Field Builder ---
  Widget _buildFormField(
    Map<String, dynamic> fieldConfig,
    Map<String, dynamic> currentData,
    bool isEditing,
    ProfileNotifier notifier,
  ) {
    final String key = fieldConfig['key'];
    final String label = fieldConfig['label'];
    final bool isRequired = fieldConfig['required'] ?? false;
    final String type = fieldConfig['type'] ?? 'text'; // Default to text
    final int maxLines = fieldConfig['maxLines'] ?? 1;
    final TextInputType keyboard =
        fieldConfig['keyboard'] ?? TextInputType.text;
    final String? hint = fieldConfig['hint'];

    // Get controller (should exist unless it's a special type like gender)
    final controller = _controllers[key];
    final currentValue = currentData[key];

    logger.d(
      "Building field '$key' with isEditing=$isEditing, currentValue=$currentValue",
    );

    // IMPORTANT: Set the controller text value directly here to ensure it's always up to date
    if (controller != null && currentValue != null) {
      // Only update if different to avoid cursor jumps
      if (controller.text != currentValue.toString()) {
        controller.text = currentValue.toString();
        logger.d("Updated controller for '$key' to: '${controller.text}'");
      }
    }
    // Get Theme data once
    final theme = Theme.of(context);
    final textTheme = theme.textTheme;
    final colorScheme = theme.colorScheme;

    // --- Build based on type ---

    if (type == 'gender') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          Row(
            children: [
              _buildGenderRadio(
                'Male',
                currentValue as String?,
                notifier,
                isEditing,
              ),
              _buildGenderRadio('Female', currentValue, notifier, isEditing),
              _buildGenderRadio('Other', currentValue, notifier, isEditing),
            ],
          ),
        ],
      );
    }

    if (type == 'date') {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          TextFormField(
            controller: controller,
            readOnly: true, // Always read-only, rely on onTap
            enabled: isEditing, // Enable/disable based on edit mode
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              // Example: Use bodyLarge style from your theme as a base

              // Conditionally change color based on whether the field is enabled (editing)
              color:
                  isEditing
                      ? Theme.of(context)
                          .colorScheme
                          .onSurface // Use default text color when editing
                      : Colors.grey[700],
            ),
            decoration: InputDecoration(
              hintText: 'DD-MM-YYYY',
              suffixIcon: Icon(
                Icons.calendar_today,
                color: isEditing ? Theme.of(context).primaryColor : Colors.grey,
              ),
              border: const OutlineInputBorder(),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Theme.of(context).primaryColor),
              ),
              disabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: Colors.grey[100]!),
              ),
              filled: true,
              fillColor: isEditing ? Colors.white : Colors.grey[50],
            ),
            onTap: isEditing ? () => _selectDate(context) : null,
            validator:
                (value) =>
                    (isRequired && (value == null || value.isEmpty))
                        ? 'Required'
                        : null,
          ),
        ],
      );
    }

    if (type == 'checkbox') {
      final bool isFieldEditable =
          fieldConfig['editable'] ?? true; // Get editable flag from config
      // Safely get boolean value from data, default to false if null or wrong type
      final bool currentValueBool =
          (currentValue is bool) ? currentValue : false;

      // Determine if the checkbox interaction should be enabled
      final bool canChange = isEditing && isFieldEditable;

      return CheckboxListTile(
        title: Text(
          label,
          // Style to match other field labels or content
          style: textTheme.bodyMedium?.copyWith(
            // Grey out label if checkbox cannot be changed currently
            // color: canChange ? Colors.red : Colors.grey[50],
            color: Colors.grey[700],
          ),
        ),
        value: currentValueBool,
        onChanged:
            canChange
                ? (bool? newValue) {
                  // Callback only active if canChange is true
                  if (newValue != null) {
                    logger.d("Checkbox '$key' changed to: '$newValue'");
                    notifier.updateField(
                      key,
                      newValue,
                    ); // Update state via notifier
                  }
                }
                : null, // Setting onChanged to null visually disables the checkbox
        controlAffinity:
            ListTileControlAffinity.leading, // Checkbox appears first
        dense: true, // Reduces vertical height
        visualDensity: VisualDensity.compact,
        activeColor: colorScheme.primary, // Color when checked
        checkColor: colorScheme.onPrimary, // Color of the check mark itself
        // Ensure checkbox looks appropriately disabled visually when canChange is false
        // tileColor:
        //     canChange
        //         ? null
        //         : theme.disabledColor.withAlpha(
        //           153,
        //         ), // Subtle background when disabled
      );
    }
    // --- END OF ADDED BLOCK ---

    // Default: Text Field
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(
            context,
          ).textTheme.bodyMedium?.copyWith(color: Colors.grey[700]),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          enabled: isEditing, // Enable/disable based on edit mode
          keyboardType: keyboard,
          maxLines: maxLines,
          decoration: InputDecoration(
            hintText: hint,
            border: const OutlineInputBorder(),
            enabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Theme.of(context).primaryColor),
            ),
            disabledBorder: OutlineInputBorder(
              borderSide: BorderSide(color: Colors.grey[100]!),
            ),
            filled: true,
            fillColor: isEditing ? Colors.white : Colors.grey[50],
          ),
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: isEditing ? Colors.black : Colors.grey[700],
          ),
          validator:
              (value) =>
                  (isRequired && (value == null || value.trim().isEmpty))
                      ? 'Please enter $label'
                      : null,
          onChanged: (value) {
            logger.d("Field '$key' changed to: '$value'");
            notifier.updateField(key, value); // Update state on change
          },
        ),
      ],
    );
  }

  // Updated Gender Radio Helper
  Widget _buildGenderRadio(
    String title,
    String? groupValue,
    ProfileNotifier notifier,
    bool isEditing,
  ) {
    // Use InkWell + Row + Radio + Text for better layout control
    return Expanded(
      child: InkWell(
        onTap: isEditing ? () => notifier.updateField('gender', title) : null,
        child: Row(
          mainAxisSize: MainAxisSize.min, // Keep radio and text close
          children: [
            Radio<String>(
              value: title,
              groupValue: groupValue,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize:
                  MaterialTapTargetSize.shrinkWrap, // Reduce tap area padding
              onChanged:
                  isEditing
                      ? (String? value) {
                        logger.d(
                          "Gender radio changed to: $value, isEditing: $isEditing",
                        );
                        if (value != null) {
                          notifier.updateField('gender', value);
                        }
                      }
                      : null, // Disable if not editing
            ),
            Text(title),
          ],
        ),
      ),
    );
  }

  // Helper to build a text field row
} // End _ProfileScreenState
