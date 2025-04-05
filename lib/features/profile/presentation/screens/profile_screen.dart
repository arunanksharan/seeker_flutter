// lib/features/profile/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:seeker/features/profile/application/profile_notifier.dart';
import 'package:seeker/features/profile/application/profile_providers.dart';
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
      'key': 'gender',
      'label': 'Gender',
      'type': 'gender',
    }, // Special type for radio
    {
      'key': 'dob',
      'label': 'Date of Birth',
      'type': 'date',
    }, // Special type for date picker
    {
      'key': 'hometown_and_locality',
      'label': 'Address',
      'maxLines': 3,
    }, // Maps to Address
    {'key': 'institute_name', 'label': 'Institute Name'}, // ITI
    {'key': 'trade', 'label': 'Trade'}, // ITI
    {'key': 'training_duration', 'label': 'Training Duration'}, // ITI
    {
      'key': 'state_registration_number',
      'label': 'NCVT Roll No.',
      'required': true,
    }, // ITI
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
      _setupListener();
      _initializeFormFields();
    });
  }

  void _setupListener() {
    ref.listen<ProfileState>(profileNotifierProvider, (previous, next) {
      final wasLoaded = previous?.dataLoaded ?? false;
      if (!wasLoaded && next.dataLoaded) {
        logger.d(
          "ProfileScreen: Data loaded, initializing form fields via listener.",
        );
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
      logger.d("ProfileScreen: Initializing/Updating form controllers.");
      for (var field in _formFields) {
        final key = field['key'] as String;
        final controller = _controllers[key];
        if (controller != null) {
          // Check if controller exists (skip gender)
          controller.text = data[key]?.toString() ?? '';
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

    // Handle initial loading state
    if (state.isLoading && !state.dataLoaded) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: const Center(child: CircularProgressIndicator()),
      );
    }
    // Handle initial loading error state
    if (!state.dataLoaded && state.errorMessage != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Profile')),
        body: Center(child: Text("Error: ${state.errorMessage}")),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(state.isEditing ? 'Edit Profile' : 'View Profile'),
        actions: [
          // Toggle Edit/Cancel Button
          if (state.dataLoaded &&
              state.errorMessage == null) // Show only if data loaded ok
            TextButton(
              onPressed:
                  state.isSaving
                      ? null
                      : () => notifier.setEditMode(!state.isEditing),
              child: Text(state.isEditing ? 'Cancel' : 'Edit'),
            ),
          const SizedBox(width: 8),
        ],
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        child: AbsorbPointer(
          // Disable input fields if not in edit mode
          absorbing:
              !state.isEditing &&
              !state.isLoading, // Absorb taps when not editing/loading
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch, // Stretch labels/fields
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
                      .expand((widget) => [widget, const SizedBox(height: 24)]),

                  const SizedBox(height: 16), // Space before save button
                  // Save Button (visible only in edit mode)
                  if (state.isEditing)
                    Center(
                      child: ElevatedButton(
                        onPressed: state.isSaving ? null : _saveForm,
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
          ),
        ),
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
          IgnorePointer(
            // Use IgnorePointer to disable radio buttons in view mode
            ignoring: !isEditing,
            child: Row(
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
            decoration: InputDecoration(
              hintText: 'DD-MM-YYYY',
              suffixIcon: Icon(
                Icons.calendar_today,
                color: isEditing ? Theme.of(context).primaryColor : Colors.grey,
              ),
            ),
            onTap:
                isEditing
                    ? () => _selectDate(context)
                    : null, // Only allow tap in edit mode
            validator:
                (value) =>
                    (isRequired && (value == null || value.isEmpty))
                        ? 'Required'
                        : null,
          ),
        ],
      );
    }

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
          decoration: InputDecoration(hintText: hint),
          style: Theme.of(context).textTheme.bodyLarge,
          validator:
              (value) =>
                  (isRequired && (value == null || value.trim().isEmpty))
                      ? 'Please enter $label'
                      : null,
          onChanged:
              (value) =>
                  notifier.updateField(key, value), // Update state on change
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
    return Expanded(
      child: RadioListTile<String>(
        title: Text(title),
        value: title,
        groupValue: groupValue,
        // Only allow changes if in edit mode
        onChanged:
            isEditing
                ? (String? value) {
                  if (value != null) {
                    notifier.updateField('gender', value);
                  }
                }
                : null,
        contentPadding: EdgeInsets.zero,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
} // End _ProfileScreenState
