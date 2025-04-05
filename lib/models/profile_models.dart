// lib/models/profile_models.dart
import 'package:seeker/utils/logger.dart'; // Import logger for enum helper

// --- Enums ---

enum EducationLevel {
  tenth, // '10th'
  twelfth, // '12th'
  diploma, // 'Diploma'
  iti, // 'ITI'
  graduate, // 'Graduate'
  postGraduate, // 'Post Graduate'
  doctorate, // 'Doctorate'
}

enum Gender {
  male, // 'Male'
  female, // 'Female'
  other, // 'Other'
}

enum ProficiencyLevel {
  beginner, // 'Beginner'
  intermediate, // 'Intermediate'
  advanced, // 'Advanced'
  native, // 'Native'
}

enum VerificationStatus {
  pending, // 'Pending'
  verified, // 'Verified'
  rejected, // 'Rejected'
}

enum JobType {
  fullTime, // 'Full-time'
  partTime, // 'Part-time'
  contract, // 'Contract'
  internship, // 'Internship'
  freelance, // 'Freelance'
}

enum WorkLocationType {
  onsite, // 'Onsite'
  remote, // 'Remote'
  hybrid, // 'Hybrid'
}

// --- Enum Parsing/Serialization Helpers ---

/// Safely parses a string into an enum value, returning null or default if invalid.
T? enumFromStringSafe<T extends Enum>(
  Iterable<T> values,
  String? value, {
  T? defaultValue,
}) {
  if (value == null || value.isEmpty) return defaultValue;
  try {
    // Find enum value matching the string (case-insensitive comparison with Dart enum .name)
    // This assumes API strings match Dart enum names ignoring case (e.g., "male" -> Gender.male)
    // Adjust comparison logic if API sends different strings (e.g., "Full-time")
    return values.firstWhere(
      (type) => type.name.toLowerCase() == value.toLowerCase(),
    );
  } catch (e) {
    logger.w(
      'Invalid enum string "$value" for type $T. Returning default: $defaultValue',
    );
    return defaultValue;
  }
}

/// Converts an enum value to a string suitable for API serialization.
/// **IMPORTANT:** Adjust this based on what format your API expects!
String? enumToString<T extends Enum>(T? value) {
  // Option 1: Send the Dart enum name (e.g., "postGraduate")
  // return value?.name;

  // Option 2: Send the display name (e.g., "Post Graduate") - Use ONLY if API expects this format
  // return value?.displayName;

  // Option 3: Send specific strings matching original TS/API values
  // This is often the safest if API values differ from Dart names
  switch (value.runtimeType) {
    case EducationLevel _:
      switch (value as EducationLevel?) {
        case EducationLevel.tenth:
          return '10th';
        case EducationLevel.twelfth:
          return '12th';
        case EducationLevel.diploma:
          return 'Diploma';
        case EducationLevel.iti:
          return 'ITI';
        case EducationLevel.graduate:
          return 'Graduate';
        case EducationLevel.postGraduate:
          return 'Post Graduate';
        case EducationLevel.doctorate:
          return 'Doctorate';
        case null:
          return null;
      }
    case Gender _:
      switch (value as Gender?) {
        case Gender.male:
          return 'Male';
        case Gender.female:
          return 'Female';
        case Gender.other:
          return 'Other';
        case null:
          return null;
      }
    case VerificationStatus _:
      switch (value as VerificationStatus?) {
        case VerificationStatus.pending:
          return 'Pending';
        case VerificationStatus.verified:
          return 'Verified';
        case VerificationStatus.rejected:
          return 'Rejected';
        case null:
          return null;
      }
    // Add cases for JobType, WorkLocationType, ProficiencyLevel if needed for serialization
    default:
      return value?.name; // Fallback to Dart name
  }
}

// --- Enum Display Name Extensions ---
// These provide human-readable strings for UI display

extension EducationLevelDisplay on EducationLevel {
  String get displayName {
    switch (this) {
      case EducationLevel.tenth:
        return '10th';
      case EducationLevel.twelfth:
        return '12th';
      case EducationLevel.diploma:
        return 'Diploma';
      case EducationLevel.iti:
        return 'ITI';
      case EducationLevel.graduate:
        return 'Graduate';
      case EducationLevel.postGraduate:
        return 'Post Graduate';
      case EducationLevel.doctorate:
        return 'Doctorate';
      // Fallback
    }
  }
}

extension GenderDisplay on Gender {
  String get displayName {
    switch (this) {
      case Gender.male:
        return 'Male';
      case Gender.female:
        return 'Female';
      case Gender.other:
        return 'Other';
    }
  }
}

extension ProficiencyLevelDisplay on ProficiencyLevel {
  String get displayName {
    switch (this) {
      case ProficiencyLevel.beginner:
        return 'Beginner';
      case ProficiencyLevel.intermediate:
        return 'Intermediate';
      case ProficiencyLevel.advanced:
        return 'Advanced';
      case ProficiencyLevel.native:
        return 'Native';
    }
  }
}

extension VerificationStatusDisplay on VerificationStatus {
  String get displayName {
    switch (this) {
      case VerificationStatus.pending:
        return 'Pending';
      case VerificationStatus.verified:
        return 'Verified';
      case VerificationStatus.rejected:
        return 'Rejected';
    }
  }
}

extension JobTypeDisplay on JobType {
  String get displayName {
    switch (this) {
      case JobType.fullTime:
        return 'Full-time';
      case JobType.partTime:
        return 'Part-time';
      case JobType.contract:
        return 'Contract';
      case JobType.internship:
        return 'Internship';
      case JobType.freelance:
        return 'Freelance';
    }
  }
}

extension WorkLocationTypeDisplay on WorkLocationType {
  String get displayName {
    switch (this) {
      case WorkLocationType.onsite:
        return 'Onsite';
      case WorkLocationType.remote:
        return 'Remote';
      case WorkLocationType.hybrid:
        return 'Hybrid';
    }
  }
}

// --- Classes (with updated enum parsing/serialization) ---

// Address, PersonalDetails, ContactDetails, WorkExperience, Skill,
// IdentificationDoc, BankDetail, Review classes remain structurally the same
// but ensure their fromJson/toJson methods use the safe helpers if they
// contain enums (they don't currently, except maybe 'gender' if changed).

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode;
  final String? country;
  final bool? isCurrent;
  Address({
    this.street,
    this.city,
    this.state,
    this.postalCode,
    this.country,
    this.isCurrent,
  });
  factory Address.fromJson(Map<String, dynamic> json) {
    return Address(
      street: json['street'] as String?,
      city: json['city'] as String?,
      state: json['state'] as String?,
      postalCode: json['postal_code'] as String?,
      country: json['country'] as String?,
      isCurrent: json['is_current'] as bool?,
    );
  }
  Map<String, dynamic> toJson() => {
    'street': street,
    'city': city,
    'state': state,
    'postal_code': postalCode,
    'country': country,
    'is_current': isCurrent,
  };
}

class PersonalDetails {
  final String? name;
  final String? fatherName;
  final String? motherName;
  final String? gender;
  final String? dob;
  final String? guardianName;
  final String? profilePictureUrl;
  PersonalDetails({
    this.name,
    this.fatherName,
    this.motherName,
    this.gender,
    this.dob,
    this.guardianName,
    this.profilePictureUrl,
  });
  factory PersonalDetails.fromJson(Map<String, dynamic> json) {
    return PersonalDetails(
      name: json['name'] as String?,
      fatherName: json['father_name'] as String?,
      motherName: json['mother_name'] as String?,
      gender: json['gender'] as String?,
      dob: json['dob'] as String?,
      guardianName: json['guardian_name'] as String?,
      profilePictureUrl: json['profile_picture_url'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'father_name': fatherName,
    'mother_name': motherName,
    'gender': gender,
    'dob': dob,
    'guardian_name': guardianName,
    'profile_picture_url': profilePictureUrl,
  };
}

class ContactDetails {
  final String? primaryMobile;
  final String? secondaryMobile;
  final String? email;
  final Address? permanentAddress;
  final Address? currentAddress;
  ContactDetails({
    this.primaryMobile,
    this.secondaryMobile,
    this.email,
    this.permanentAddress,
    this.currentAddress,
  });
  factory ContactDetails.fromJson(Map<String, dynamic> json) {
    return ContactDetails(
      primaryMobile: json['primary_mobile'] as String?,
      secondaryMobile: json['secondary_mobile'] as String?,
      email: json['email'] as String?,
      permanentAddress:
          json['permanent_address'] == null
              ? null
              : Address.fromJson(
                json['permanent_address'] as Map<String, dynamic>,
              ),
      currentAddress:
          json['current_address'] == null
              ? null
              : Address.fromJson(
                json['current_address'] as Map<String, dynamic>,
              ),
    );
  }
  Map<String, dynamic> toJson() => {
    'primary_mobile': primaryMobile,
    'secondary_mobile': secondaryMobile,
    'email': email,
    'permanent_address': permanentAddress?.toJson(),
    'current_address': currentAddress?.toJson(),
  };
}

class EducationDetail {
  final String? instituteName;
  final String? fieldOfStudy;
  final String? startDate;
  final String? endDate;
  final int? yearOfPassing;
  final num? gradePercentageCgpa;
  final bool? isCurrent;
  final List<String>? marksheetUrl;
  final List<String>? certificateUrl;
  final VerificationStatus? verificationStatus; // Enum field

  EducationDetail({
    this.instituteName,
    this.fieldOfStudy,
    this.startDate,
    this.endDate,
    this.yearOfPassing,
    this.gradePercentageCgpa,
    this.isCurrent,
    this.marksheetUrl,
    this.certificateUrl,
    this.verificationStatus,
  });

  factory EducationDetail.fromJson(Map<String, dynamic> json) {
    return EducationDetail(
      instituteName: json['institute_name'] as String?,
      fieldOfStudy: json['field_of_study'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      yearOfPassing: json['year_of_passing'] as int?,
      gradePercentageCgpa: json['grade_percentage_cgpa'] as num?,
      isCurrent: json['is_current'] as bool?,
      marksheetUrl:
          (json['marksheet_url'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      certificateUrl:
          (json['certificate_url'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      // Use safe parsing helper
      verificationStatus: enumFromStringSafe(
        VerificationStatus.values,
        json['verification_status'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'institute_name': instituteName,
    'field_of_study': fieldOfStudy,
    'start_date': startDate,
    'end_date': endDate,
    'year_of_passing': yearOfPassing,
    'grade_percentage_cgpa': gradePercentageCgpa,
    'is_current': isCurrent,
    'marksheet_url': marksheetUrl,
    'certificate_url': certificateUrl,
    // Use specific serialization helper
    'verification_status': enumToString(verificationStatus),
  };
}

class EducationDetails {
  final String?
      highestLevel; // Kept as String, use enumFromStringSafe/enumToString if changed to Enum
  final List<EducationDetail>? educationDetails;
  EducationDetails({this.highestLevel, this.educationDetails});
  factory EducationDetails.fromJson(Map<String, dynamic> json) {
    return EducationDetails(
      highestLevel: json['highest_level'] as String?,
      educationDetails:
          (json['education_details'] as List<dynamic>?)
              ?.map((e) => EducationDetail.fromJson(e as Map<String, dynamic>))
              .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'highest_level': highestLevel,
    'education_details': educationDetails?.map((e) => e.toJson()).toList(),
  };
}

class WorkExperience {
  /* ... remains the same ... */
  final String? companyName;
  final String? designation;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final String? description;
  final List<String>? experienceLetterUrl;
  final List<String>? payslipUrls;
  WorkExperience({
    this.companyName,
    this.designation,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.description,
    this.experienceLetterUrl,
    this.payslipUrls,
  });
  factory WorkExperience.fromJson(Map<String, dynamic> json) {
    return WorkExperience(
      companyName: json['company_name'] as String?,
      designation: json['designation'] as String?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool?,
      description: json['description'] as String?,
      experienceLetterUrl:
          (json['experience_letter_url'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      payslipUrls:
          (json['payslip_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'company_name': companyName,
    'designation': designation,
    'start_date': startDate,
    'end_date': endDate,
    'is_current': isCurrent,
    'description': description,
    'experience_letter_url': experienceLetterUrl,
    'payslip_urls': payslipUrls,
  };
}

class Skill {
  /* ... remains the same ... */
  final String? name;
  final String? proficiencyLevel;
  final String? experience;
  Skill({this.name, this.proficiencyLevel, this.experience});
  factory Skill.fromJson(Map<String, dynamic> json) {
    return Skill(
      name: json['name'] as String?,
      proficiencyLevel: json['proficiency_level'] as String?,
      experience: json['experience'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'proficiency_level': proficiencyLevel,
    'experience': experience,
  };
}

class Certification {
  /* ... updated ... */
  final String name;
  final String? issuingOrganization;
  final String? issueDate;
  final String? expiryDate;
  final String? credentialId;
  final String? credentialUrl;
  final String? certificateUrl;
  final VerificationStatus? verificationStatus; // Enum field

  Certification({
    required this.name,
    this.issuingOrganization,
    this.issueDate,
    this.expiryDate,
    this.credentialId,
    this.credentialUrl,
    this.certificateUrl,
    this.verificationStatus,
  });
  factory Certification.fromJson(Map<String, dynamic> json) {
    return Certification(
      name: json['name'] as String,
      issuingOrganization: json['issuing_organization'] as String?,
      issueDate: json['issue_date'] as String?,
      expiryDate: json['expiry_date'] as String?,
      credentialId: json['credential_id'] as String?,
      credentialUrl: json['credential_url'] as String?,
      certificateUrl: json['certificate_url'] as String?,
      verificationStatus: enumFromStringSafe(
        VerificationStatus.values,
        json['verification_status'] as String?,
      ),
    );
  }
  Map<String, dynamic> toJson() => {
    'name': name,
    'issuing_organization': issuingOrganization,
    'issue_date': issueDate,
    'expiry_date': expiryDate,
    'credential_id': credentialId,
    'credential_url': credentialUrl,
    'certificate_url': certificateUrl,
    'verification_status': enumToString(verificationStatus),
  };
}

class LanguageProficiency {
  /* ... remains the same ... */
  final String language;
  final String? spoken;
  final String? written;
  final String? reading;
  LanguageProficiency({
    required this.language,
    this.spoken,
    this.written,
    this.reading,
  });
  factory LanguageProficiency.fromJson(Map<String, dynamic> json) {
    return LanguageProficiency(
      language: json['language'] as String,
      spoken: json['spoken'] as String?,
      written: json['written'] as String?,
      reading: json['reading'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'language': language,
    'spoken': spoken,
    'written': written,
    'reading': reading,
  };
}

class ITIDetail {
  /* ... updated ... */
  final String? instituteName;
  final String? trade;
  final String? trainingDuration;
  final int? passingYear;
  final String? startDate;
  final String? endDate;
  final bool? isCurrent;
  final List<String>? certificateUrls;
  final String? grade;
  final String? rollNumber;
  final String? certificateNumber;
  final VerificationStatus? verificationStatus; // Enum field

  ITIDetail({
    this.instituteName,
    this.trade,
    this.trainingDuration,
    this.passingYear,
    this.startDate,
    this.endDate,
    this.isCurrent,
    this.certificateUrls,
    this.grade,
    this.rollNumber,
    this.certificateNumber,
    this.verificationStatus,
  });
  factory ITIDetail.fromJson(Map<String, dynamic> json) {
    return ITIDetail(
      instituteName: json['institute_name'] as String?,
      trade: json['trade'] as String?,
      trainingDuration: json['training_duration'] as String?,
      passingYear: json['passing_year'] as int?,
      startDate: json['start_date'] as String?,
      endDate: json['end_date'] as String?,
      isCurrent: json['is_current'] as bool?,
      certificateUrls:
          (json['certificate_urls'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      grade: json['grade'] as String?,
      rollNumber: json['roll_number'] as String?,
      certificateNumber: json['certificate_number'] as String?,
      verificationStatus: enumFromStringSafe(
        VerificationStatus.values,
        json['verification_status'] as String?,
      ),
    );
  }
  Map<String, dynamic> toJson() => {
    'institute_name': instituteName,
    'trade': trade,
    'training_duration': trainingDuration,
    'passing_year': passingYear,
    'start_date': startDate,
    'end_date': endDate,
    'is_current': isCurrent,
    'certificate_urls': certificateUrls,
    'grade': grade,
    'roll_number': rollNumber,
    'certificate_number': certificateNumber,
    'verification_status': enumToString(verificationStatus),
  };
}

class IdentificationDoc {
  /* ... remains the same ... */
  final String? docType;
  final String? docNumber;
  final String? name;
  final List<String>? urls;
  IdentificationDoc({this.docType, this.docNumber, this.name, this.urls});
  factory IdentificationDoc.fromJson(Map<String, dynamic> json) {
    return IdentificationDoc(
      docType: json['doc_type'] as String?,
      docNumber: json['doc_number'] as String?,
      name: json['name'] as String?,
      urls: (json['urls'] as List<dynamic>?)?.map((e) => e as String).toList(),
    );
  }
  Map<String, dynamic> toJson() => {
    'doc_type': docType,
    'doc_number': docNumber,
    'name': name,
    'urls': urls,
  };
}

class BankDetail {
  /* ... remains the same ... */
  final String? accountNumber;
  final String? ifscCode;
  final String? bankName;
  final String? branchName;
  final String? accountHolderName;
  BankDetail({
    this.accountNumber,
    this.ifscCode,
    this.bankName,
    this.branchName,
    this.accountHolderName,
  });
  factory BankDetail.fromJson(Map<String, dynamic> json) {
    return BankDetail(
      accountNumber: json['account_number'] as String?,
      ifscCode: json['ifsc_code'] as String?,
      bankName: json['bank_name'] as String?,
      branchName: json['branch_name'] as String?,
      accountHolderName: json['account_holder_name'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'account_number': accountNumber,
    'ifsc_code': ifscCode,
    'bank_name': bankName,
    'branch_name': branchName,
    'account_holder_name': accountHolderName,
  };
}

class JobPreferences {
  /* ... remains the same ... */
  final List<String>? jobTypes;
  final List<String>? workLocationTypes;
  final List<String>? jobRoles;
  final List<String>? industries;
  final String? minSalaryExpectation;
  final String? maxSalaryExpectation;
  final int? noticePeriodDays;
  final bool? isWillingToRelocate;
  final bool? isActivelyLooking;
  final String? preferredJobLocations;
  final String? currentLocation;
  final String? totalExperienceYears;
  final String? currentMonthlySalary;
  JobPreferences({
    this.jobTypes,
    this.workLocationTypes,
    this.jobRoles,
    this.industries,
    this.minSalaryExpectation,
    this.maxSalaryExpectation,
    this.noticePeriodDays,
    this.isWillingToRelocate,
    this.isActivelyLooking,
    this.preferredJobLocations,
    this.currentLocation,
    this.totalExperienceYears,
    this.currentMonthlySalary,
  });
  factory JobPreferences.fromJson(Map<String, dynamic> json) {
    return JobPreferences(
      jobTypes:
          (json['job_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      workLocationTypes:
          (json['work_location_types'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      jobRoles:
          (json['job_roles'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      industries:
          (json['industries'] as List<dynamic>?)
              ?.map((e) => e as String)
              .toList(),
      minSalaryExpectation: json['min_salary_expectation'] as String?,
      maxSalaryExpectation: json['max_salary_expectation'] as String?,
      noticePeriodDays: json['notice_period_days'] as int?,
      isWillingToRelocate: json['is_willing_to_relocate'] as bool?,
      isActivelyLooking: json['is_actively_looking'] as bool?,
      preferredJobLocations: json['preferred_job_locations'] as String?,
      currentLocation: json['current_location'] as String?,
      totalExperienceYears: json['total_experience_years'] as String?,
      currentMonthlySalary: json['current_monthly_salary'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'job_types': jobTypes,
    'work_location_types': workLocationTypes,
    'job_roles': jobRoles,
    'industries': industries,
    'min_salary_expectation': minSalaryExpectation,
    'max_salary_expectation': maxSalaryExpectation,
    'notice_period_days': noticePeriodDays,
    'is_willing_to_relocate': isWillingToRelocate,
    'is_actively_looking': isActivelyLooking,
    'preferred_job_locations': preferredJobLocations,
    'current_location': currentLocation,
    'total_experience_years': totalExperienceYears,
    'current_monthly_salary': currentMonthlySalary,
  };
}

class Review {
  /* ... remains the same ... */
  final String reviewerName;
  final String? reviewerDesignation;
  final String? reviewerCompany;
  final num rating;
  final String? comments;
  final String? reviewDate;
  Review({
    required this.reviewerName,
    this.reviewerDesignation,
    this.reviewerCompany,
    required this.rating,
    this.comments,
    this.reviewDate,
  });
  factory Review.fromJson(Map<String, dynamic> json) {
    return Review(
      reviewerName: json['reviewer_name'] as String,
      reviewerDesignation: json['reviewer_designation'] as String?,
      reviewerCompany: json['reviewer_company'] as String?,
      rating: json['rating'] as num,
      comments: json['comments'] as String?,
      reviewDate: json['review_date'] as String?,
    );
  }
  Map<String, dynamic> toJson() => {
    'reviewer_name': reviewerName,
    'reviewer_designation': reviewerDesignation,
    'reviewer_company': reviewerCompany,
    'rating': rating,
    'comments': comments,
    'review_date': reviewDate,
  };
}

// --- API Request/Response Models ---
typedef CurrentProfileBlob = Map<String, dynamic>;

class SeekerProfileApiResponse {
  /* Structure remains the same, uses updated fromJson/toJson from nested models */
  final String id;
  final String seekerId;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final PersonalDetails? personalDetails;
  final ContactDetails? contactDetails;
  final List<IdentificationDoc>? identificationDocs;
  final List<BankDetail>? bankDetails;
  final EducationDetails? educationDetails;
  final List<WorkExperience>? workExperiences;
  final List<Certification>? certifications;
  final List<LanguageProficiency>? languageProficiencies;
  final JobPreferences? jobPreferences;
  final List<ITIDetail>? itiDetails;
  final List<Skill>? skills;
  final num? assessmentScore;
  final List<Review>? reviews;
  final List<CurrentProfileBlob>? callMetadataHistory;
  final CurrentProfileBlob? currentProfile;
  SeekerProfileApiResponse({
    required this.id,
    required this.seekerId,
    this.createdAt,
    this.updatedAt,
    this.personalDetails,
    this.contactDetails,
    this.identificationDocs,
    this.bankDetails,
    this.educationDetails,
    this.workExperiences,
    this.certifications,
    this.languageProficiencies,
    this.jobPreferences,
    this.itiDetails,
    this.skills,
    this.assessmentScore,
    this.reviews,
    this.callMetadataHistory,
    this.currentProfile,
  });
  factory SeekerProfileApiResponse.fromJson(Map<String, dynamic> json) {
    List<T>? parseList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final list = json[key] as List<dynamic>?;
      return list
          ?.map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }

    List<Map<String, dynamic>>? parseListOfMaps(String key) {
      final list = json[key] as List<dynamic>?;
      return list?.map((item) => item as Map<String, dynamic>).toList();
    }

    return SeekerProfileApiResponse(
      id: json['id'] as String,
      seekerId: json['seeker_id'] as String,
      createdAt:
          json['created_at'] == null
              ? null
              : DateTime.parse(json['created_at'] as String),
      updatedAt:
          json['updated_at'] == null
              ? null
              : DateTime.parse(json['updated_at'] as String),
      personalDetails:
          json['personal_details'] == null
              ? null
              : PersonalDetails.fromJson(
                json['personal_details'] as Map<String, dynamic>,
              ),
      contactDetails:
          json['contact_details'] == null
              ? null
              : ContactDetails.fromJson(
                json['contact_details'] as Map<String, dynamic>,
              ),
      identificationDocs: parseList(
        'identification_docs',
        IdentificationDoc.fromJson,
      ),
      bankDetails: parseList('bank_details', BankDetail.fromJson),
      educationDetails:
          json['education_details'] == null
              ? null
              : EducationDetails.fromJson(
                json['education_details'] as Map<String, dynamic>,
              ),
      workExperiences: parseList('work_experiences', WorkExperience.fromJson),
      certifications: parseList('certifications', Certification.fromJson),
      languageProficiencies: parseList(
        'language_proficiencies',
        LanguageProficiency.fromJson,
      ),
      jobPreferences:
          json['job_preferences'] == null
              ? null
              : JobPreferences.fromJson(
                json['job_preferences'] as Map<String, dynamic>,
              ),
      itiDetails: parseList('iti_details', ITIDetail.fromJson),
      skills: parseList('skills', Skill.fromJson),
      assessmentScore: json['assessment_score'] as num?,
      reviews: parseList('reviews', Review.fromJson),
      callMetadataHistory: parseListOfMaps('call_metadata_history'),
      currentProfile: json['current_profile'] != null
          ? (json['current_profile'] is Map
              ? json['current_profile'] as Map<String, dynamic>
              : null)
          : null,
    );
  }
  Map<String, dynamic> toJson() => {
    'id': id,
    'seeker_id': seekerId,
    'created_at': createdAt?.toIso8601String(),
    'updated_at': updatedAt?.toIso8601String(),
    'personal_details': personalDetails?.toJson(),
    'contact_details': contactDetails?.toJson(),
    'identification_docs': identificationDocs?.map((e) => e.toJson()).toList(),
    'bank_details': bankDetails?.map((e) => e.toJson()).toList(),
    'education_details': educationDetails?.toJson(),
    'work_experiences': workExperiences?.map((e) => e.toJson()).toList(),
    'certifications': certifications?.map((e) => e.toJson()).toList(),
    'language_proficiencies':
        languageProficiencies?.map((e) => e.toJson()).toList(),
    'job_preferences': jobPreferences?.toJson(),
    'iti_details': itiDetails?.map((e) => e.toJson()).toList(),
    'skills': skills?.map((e) => e.toJson()).toList(),
    'assessment_score': assessmentScore,
    'reviews': reviews?.map((e) => e.toJson()).toList(),
    'call_metadata_history': callMetadataHistory,
    'current_profile': currentProfile,
  };
}

class SeekerProfileApiRequest {
  /* Structure remains the same, uses updated toJson from nested models */
  final PersonalDetails? personalDetails;
  final ContactDetails? contactDetails;
  final List<IdentificationDoc>? identificationDocs;
  final List<BankDetail>? bankDetails;
  final EducationDetails? educationDetails;
  final List<WorkExperience>? workExperiences;
  final List<Certification>? certifications;
  final List<LanguageProficiency>? languageProficiencies;
  final JobPreferences? jobPreferences;
  final List<ITIDetail>? itiDetails;
  final List<Skill>? skills;
  final num? assessmentScore;
  final List<Review>? reviews;
  final List<CurrentProfileBlob>? callMetadataHistory;
  final CurrentProfileBlob? currentProfile;
  SeekerProfileApiRequest({
    this.personalDetails,
    this.contactDetails,
    this.identificationDocs,
    this.bankDetails,
    this.educationDetails,
    this.workExperiences,
    this.certifications,
    this.languageProficiencies,
    this.jobPreferences,
    this.itiDetails,
    this.skills,
    this.assessmentScore,
    this.reviews,
    this.callMetadataHistory,
    this.currentProfile,
  });
  Map<String, dynamic> toJson() => {
    if (personalDetails != null) 'personal_details': personalDetails!.toJson(),
    if (contactDetails != null) 'contact_details': contactDetails!.toJson(),
    if (identificationDocs != null)
      'identification_docs':
          identificationDocs!.map((e) => e.toJson()).toList(),
    if (bankDetails != null)
      'bank_details': bankDetails!.map((e) => e.toJson()).toList(),
    if (educationDetails != null)
      'education_details': educationDetails!.toJson(),
    if (workExperiences != null)
      'work_experiences': workExperiences!.map((e) => e.toJson()).toList(),
    if (certifications != null)
      'certifications': certifications!.map((e) => e.toJson()).toList(),
    if (languageProficiencies != null)
      'language_proficiencies':
          languageProficiencies!.map((e) => e.toJson()).toList(),
    if (jobPreferences != null) 'job_preferences': jobPreferences!.toJson(),
    if (itiDetails != null)
      'iti_details': itiDetails!.map((e) => e.toJson()).toList(),
    if (skills != null) 'skills': skills!.map((e) => e.toJson()).toList(),
    if (assessmentScore != null) 'assessment_score': assessmentScore,
    if (reviews != null) 'reviews': reviews!.map((e) => e.toJson()).toList(),
    if (callMetadataHistory != null)
      'call_metadata_history': callMetadataHistory,
    if (currentProfile != null) 'current_profile': currentProfile,
  };
}

class DocumentUploadRequest {
  /* ... remains the same ... */
  final String? documentType;
  DocumentUploadRequest({this.documentType});
  Map<String, dynamic> toJson() => {
    if (documentType != null) 'document_type': documentType,
  };
}
