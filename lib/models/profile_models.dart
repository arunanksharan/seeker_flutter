// Based on seeker-rn-files/types/profile.ts

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

// Helper function to handle enum from string mapping (case-insensitive)
T? enumFromString<T>(Iterable<T> values, String? value) {
  if (value == null) return null;
  return values.firstWhere(
    (type) =>
        type.toString().split('.').last.toLowerCase() == value.toLowerCase(),
    orElse: () => values.first, // Or return null, or throw error based on need
  );
}

// You might need more robust enum parsing, potentially using extensions or generated code

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

// --- Interfaces -> Classes ---

class Address {
  final String? street;
  final String? city;
  final String? state;
  final String? postalCode; // Renamed from postal_code
  final String? country;
  final bool? isCurrent; // Renamed from is_current

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
  final String? fatherName; // Renamed from father_name
  final String? motherName; // Renamed from mother_name
  final String? gender; // Keep as string for now, or map to Gender enum
  final String? dob; // Keep as string or parse to DateTime
  final String? guardianName; // Renamed from guardian_name
  final String? profilePictureUrl; // Renamed from profile_picture_url

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
  final String? primaryMobile; // Renamed from primary_mobile
  final String? secondaryMobile; // Renamed from secondary_mobile
  final String? email;
  final Address? permanentAddress; // Renamed from permanent_address
  final Address? currentAddress; // Renamed from current_address

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
  final String? instituteName; // Renamed from institute_name
  final String? fieldOfStudy; // Renamed from field_of_study
  final String? startDate; // Renamed from start_date
  final String? endDate; // Renamed from end_date
  final int? yearOfPassing; // Renamed from year_of_passing
  final num?
  gradePercentageCgpa; // Use num for potential double/int. Renamed from grade_percentage_cgpa
  final bool? isCurrent; // Renamed from is_current
  final List<String>? marksheetUrl; // Renamed from marksheet_url
  final List<String>? certificateUrl; // Renamed from certificate_url
  final VerificationStatus?
  verificationStatus; // Renamed from verification_status

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
      verificationStatus: enumFromString(
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
    'verification_status':
        verificationStatus
            ?.toString()
            .split('.')
            .last, // Convert enum back to string
  };
}

class EducationDetails {
  final String?
  highestLevel; // Renamed from highest_level (Consider using EducationLevel enum)
  final List<EducationDetail>?
  educationDetails; // Renamed from education_details

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
  final String? companyName; // Renamed from company_name
  final String? designation;
  final String? startDate; // Renamed from start_date
  final String? endDate; // Renamed from end_date
  final bool? isCurrent; // Renamed from is_current
  final String? description;
  final List<String>? experienceLetterUrl; // Renamed from experience_letter_url
  final List<String>? payslipUrls; // Renamed from payslip_urls

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
  final String? name;
  final String?
  proficiencyLevel; // Consider using ProficiencyLevel enum. Renamed from proficiency_level
  final String? experience; // Or potentially int/double for years?

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
  final String name; // Required field
  final String? issuingOrganization; // Renamed from issuing_organization
  final String? issueDate; // Renamed from issue_date
  final String? expiryDate; // Renamed from expiry_date
  final String? credentialId; // Renamed from credential_id
  final String? credentialUrl; // Renamed from credential_url
  final String? certificateUrl; // Renamed from certificate_url
  final VerificationStatus?
  verificationStatus; // Renamed from verification_status

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
      verificationStatus: enumFromString(
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
    'verification_status': verificationStatus?.toString().split('.').last,
  };
}

class LanguageProficiency {
  final String language; // Required field
  final String? spoken; // Consider ProficiencyLevel enum
  final String? written; // Consider ProficiencyLevel enum
  final String? reading; // Consider ProficiencyLevel enum

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
  final String? instituteName; // Renamed from institute_name
  final String? trade;
  final String? trainingDuration; // Renamed from training_duration
  final int? passingYear; // Renamed from passing_year
  final String? startDate; // Renamed from start_date
  final String? endDate; // Renamed from end_date
  final bool? isCurrent; // Renamed from is_current
  final List<String>? certificateUrls; // Renamed from certificate_urls
  final String? grade;
  final String? rollNumber; // Renamed from roll_number
  final String? certificateNumber; // Renamed from certificate_number
  final VerificationStatus?
  verificationStatus; // Renamed from verification_status

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
      verificationStatus: enumFromString(
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
    'verification_status': verificationStatus?.toString().split('.').last,
  };
}

class IdentificationDoc {
  final String? docType; // Renamed from doc_type
  final String? docNumber; // Renamed from doc_number
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
  final String? accountNumber; // Renamed from account_number
  final String? ifscCode; // Renamed from ifsc_code
  final String? bankName; // Renamed from bank_name
  final String? branchName; // Renamed from branch_name
  final String? accountHolderName; // Renamed from account_holder_name

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
  final List<String>? jobTypes; // Consider JobType enum. Renamed from job_types
  final List<String>?
  workLocationTypes; // Consider WorkLocationType enum. Renamed from work_location_types
  final List<String>? jobRoles; // Renamed from job_roles
  final List<String>? industries;
  final String?
  minSalaryExpectation; // Renamed from min_salary_expectation (Consider num?)
  final String?
  maxSalaryExpectation; // Renamed from max_salary_expectation (Consider num?)
  final int? noticePeriodDays; // Renamed from notice_period_days
  final bool? isWillingToRelocate; // Renamed from is_willing_to_relocate
  final bool? isActivelyLooking; // Renamed from is_actively_looking
  final String?
  preferredJobLocations; // Renamed from preferred_job_locations (List<String>?)
  final String? currentLocation; // Renamed from current_location
  final String?
  totalExperienceYears; // Renamed from total_experience_years (Consider num?)
  final String?
  currentMonthlySalary; // Renamed from current_monthly_salary (Consider num?)

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
      preferredJobLocations:
          json['preferred_job_locations']
              as String?, // Adjust if it's actually List<String>
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
  final String reviewerName; // Renamed from reviewer_name
  final String? reviewerDesignation; // Renamed from reviewer_designation
  final String? reviewerCompany; // Renamed from reviewer_company
  final num rating; // Required field
  final String? comments;
  final String? reviewDate; // Renamed from review_date (Consider DateTime?)

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
// Note: Renamed fields to camelCase

// Generic type for dynamic JSON objects like 'current_profile'
typedef CurrentProfileBlob = Map<String, dynamic>;

// Represents the full profile structure for API responses
class SeekerProfileApiResponse {
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
    // Helper to parse list of objects
    List<T>? parseList<T>(
      String key,
      T Function(Map<String, dynamic>) fromJson,
    ) {
      final list = json[key] as List<dynamic>?;
      return list
          ?.map((item) => fromJson(item as Map<String, dynamic>))
          .toList();
    }

    // Helper to parse list of maps
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
      currentProfile: json['current_profile'] as Map<String, dynamic>?,
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

// Represents the structure for creating or updating a profile via API
// Very similar to the Response, but fields might be optional during update
class SeekerProfileApiRequest {
  // Note: id and seekerId are usually not sent in create/update requests
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

  // No fromJson needed usually for request objects

  Map<String, dynamic> toJson() => {
    // Only include fields that are not null
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

// Represents the request for uploading documents (file handled separately)
class DocumentUploadRequest {
  final String? documentType;
  // final File? file; // File handled in service layer typically

  DocumentUploadRequest({this.documentType});

  Map<String, dynamic> toJson() => {
    if (documentType != null) 'document_type': documentType,
  };
}
