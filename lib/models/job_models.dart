// Based on seeker-rn-files/types/job.ts
// For enumFromString if needed, or keep local

// --- Enums ---

enum EmploymentType {
  // Using names that map more directly to Dart conventions
  fullTime, // "Full-time"
  partTime, // "Part-time"
  contract, // "Contract"
  temporary, // "Temporary"
  internship, // "Internship"
  freelance, // "Freelance"
}

// Helper to map enum to API string value (example for EmploymentType)
String employmentTypeToString(EmploymentType type) {
  switch (type) {
    case EmploymentType.fullTime:
      return "Full-time";
    case EmploymentType.partTime:
      return "Part-time";
    case EmploymentType.contract:
      return "Contract";
    case EmploymentType.temporary:
      return "Temporary";
    case EmploymentType.internship:
      return "Internship";
    case EmploymentType.freelance:
      return "Freelance";
  }
}

// Helper to map string from API to enum (example for EmploymentType)
EmploymentType employmentTypeFromString(String? value) {
  switch (value?.toLowerCase()) {
    case "full-time":
      return EmploymentType.fullTime;
    case "part-time":
      return EmploymentType.partTime;
    case "contract":
      return EmploymentType.contract;
    case "temporary":
      return EmploymentType.temporary;
    case "internship":
      return EmploymentType.internship;
    case "freelance":
      return EmploymentType.freelance;
    default:
      return EmploymentType.fullTime; // Default or throw error
  }
}

enum JobStatus {
  active, // "ACTIVE"
  closed, // "CLOSED"
  draft, // "DRAFT"
  expired, // "EXPIRED"
}

// Helper to map enum to API string value
String jobStatusToString(JobStatus status) => status.name.toUpperCase();

// Helper to map string from API to enum
JobStatus jobStatusFromString(String? value) => JobStatus.values.firstWhere(
  (e) => e.name.toUpperCase() == value?.toUpperCase(),
  orElse: () => JobStatus.active, // Default or throw
);

// --- Interfaces -> Classes ---

// Base Job Listing structure
class JobListing {
  final int jobId;
  final String title;
  final String shortDescription;
  final String longDescription;
  final String role;
  final String domain;
  final String location;
  final num salaryLower; // Use num for flexibility (int/double)
  final num salaryUpper;
  final EmploymentType employmentType;
  final List<String> skillsRequired;
  final List<String> qualifications;
  final List<String> responsibilities;
  final List<String> benefits;
  final DateTime? applicationDeadline; // Use DateTime?
  final int providerId;
  final String providerName;
  final String? providerLogo;
  final JobStatus status;
  final DateTime postedAt;
  final DateTime updatedAt;
  final Map<String, dynamic>? onestMetadata; // Keep as Map
  final int applicationCount;

  JobListing({
    required this.jobId,
    required this.title,
    required this.shortDescription,
    required this.longDescription,
    required this.role,
    required this.domain,
    required this.location,
    required this.salaryLower,
    required this.salaryUpper,
    required this.employmentType,
    required this.skillsRequired,
    required this.qualifications,
    required this.responsibilities,
    required this.benefits,
    this.applicationDeadline,
    required this.providerId,
    required this.providerName,
    this.providerLogo,
    required this.status,
    required this.postedAt,
    required this.updatedAt,
    this.onestMetadata,
    required this.applicationCount,
  });

  factory JobListing.fromJson(Map<String, dynamic> json) {
    // Helper function to parse string lists safely
    List<String> _parseStringList(dynamic listData) {
      if (listData is List) {
        return listData.map((e) => e.toString()).toList();
      }
      return [];
    }

    return JobListing(
      jobId: json['job_id'] as int,
      title: json['title'] as String,
      shortDescription: json['short_description'] as String,
      longDescription: json['long_description'] as String,
      role: json['role'] as String,
      domain: json['domain'] as String,
      location: json['location'] as String,
      salaryLower: json['salary_lower'] as num,
      salaryUpper: json['salary_upper'] as num,
      employmentType: employmentTypeFromString(
        json['employment_type'] as String?,
      ),
      skillsRequired: _parseStringList(json['skills_required']),
      qualifications: _parseStringList(json['qualifications']),
      responsibilities: _parseStringList(json['responsibilities']),
      benefits: _parseStringList(json['benefits']),
      applicationDeadline:
          json['application_deadline'] == null
              ? null
              : DateTime.parse(json['application_deadline'] as String),
      providerId: json['provider_id'] as int,
      providerName: json['provider_name'] as String,
      providerLogo: json['provider_logo'] as String?,
      status: jobStatusFromString(json['status'] as String?),
      postedAt: DateTime.parse(json['posted_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      onestMetadata: json['onest_metadata'] as Map<String, dynamic>?,
      applicationCount: json['application_count'] as int,
    );
  }

  Map<String, dynamic> toJson() => {
    'job_id': jobId,
    'title': title,
    'short_description': shortDescription,
    'long_description': longDescription,
    'role': role,
    'domain': domain,
    'location': location,
    'salary_lower': salaryLower,
    'salary_upper': salaryUpper,
    'employment_type': employmentTypeToString(employmentType),
    'skills_required': skillsRequired,
    'qualifications': qualifications,
    'responsibilities': responsibilities,
    'benefits': benefits,
    'application_deadline': applicationDeadline?.toIso8601String(),
    'provider_id': providerId,
    'provider_name': providerName,
    'provider_logo': providerLogo,
    'status': jobStatusToString(status),
    'posted_at': postedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'onest_metadata': onestMetadata,
    'application_count': applicationCount,
  };
}

// Job listing response with user-specific data (inherits from JobListing)
class JobListingResponse extends JobListing {
  final bool applied;
  final bool viewed;

  JobListingResponse({
    required super.jobId,
    required super.title,
    required super.shortDescription,
    required super.longDescription,
    required super.role,
    required super.domain,
    required super.location,
    required super.salaryLower,
    required super.salaryUpper,
    required super.employmentType,
    required super.skillsRequired,
    required super.qualifications,
    required super.responsibilities,
    required super.benefits,
    super.applicationDeadline,
    required super.providerId,
    required super.providerName,
    super.providerLogo,
    required super.status,
    required super.postedAt,
    required super.updatedAt,
    super.onestMetadata,
    required super.applicationCount,
    required this.applied,
    required this.viewed,
  });

  factory JobListingResponse.fromJson(Map<String, dynamic> json) {
    // Parse the base JobListing fields first
    final base = JobListing.fromJson(json);
    return JobListingResponse(
      jobId: base.jobId,
      title: base.title,
      shortDescription: base.shortDescription,
      longDescription: base.longDescription,
      role: base.role,
      domain: base.domain,
      location: base.location,
      salaryLower: base.salaryLower,
      salaryUpper: base.salaryUpper,
      employmentType: base.employmentType,
      skillsRequired: base.skillsRequired,
      qualifications: base.qualifications,
      responsibilities: base.responsibilities,
      benefits: base.benefits,
      applicationDeadline: base.applicationDeadline,
      providerId: base.providerId,
      providerName: base.providerName,
      providerLogo: base.providerLogo,
      status: base.status,
      postedAt: base.postedAt,
      updatedAt: base.updatedAt,
      onestMetadata: base.onestMetadata,
      applicationCount: base.applicationCount,
      // Parse the additional fields
      applied: json['applied'] as bool? ?? false, // Provide default if null
      viewed: json['viewed'] as bool? ?? false, // Provide default if null
    );
  }

  @override
  Map<String, dynamic> toJson() {
    // Get JSON from base class and add specific fields
    final Map<String, dynamic> json = super.toJson();
    json.addAll({'applied': applied, 'viewed': viewed});
    return json;
  }
}

// Detailed job listing with similar jobs (inherits from JobListingResponse)
class JobListingDetailResponse extends JobListingResponse {
  final List<JobListingResponse>? similarJobs; // Renamed from similar_jobs

  JobListingDetailResponse({
    required super.jobId,
    required super.title,
    required super.shortDescription,
    required super.longDescription,
    required super.role,
    required super.domain,
    required super.location,
    required super.salaryLower,
    required super.salaryUpper,
    required super.employmentType,
    required super.skillsRequired,
    required super.qualifications,
    required super.responsibilities,
    required super.benefits,
    super.applicationDeadline,
    required super.providerId,
    required super.providerName,
    super.providerLogo,
    required super.status,
    required super.postedAt,
    required super.updatedAt,
    super.onestMetadata,
    required super.applicationCount,
    required super.applied,
    required super.viewed,
    this.similarJobs,
  });

  factory JobListingDetailResponse.fromJson(Map<String, dynamic> json) {
    // Parse the base JobListingResponse fields first
    final base = JobListingResponse.fromJson(json);
    return JobListingDetailResponse(
      // Pass all base fields
      jobId: base.jobId,
      title: base.title,
      shortDescription: base.shortDescription,
      longDescription: base.longDescription,
      role: base.role,
      domain: base.domain,
      location: base.location,
      salaryLower: base.salaryLower,
      salaryUpper: base.salaryUpper,
      employmentType: base.employmentType,
      skillsRequired: base.skillsRequired,
      qualifications: base.qualifications,
      responsibilities: base.responsibilities,
      benefits: base.benefits,
      applicationDeadline: base.applicationDeadline,
      providerId: base.providerId,
      providerName: base.providerName,
      providerLogo: base.providerLogo,
      status: base.status,
      postedAt: base.postedAt,
      updatedAt: base.updatedAt,
      onestMetadata: base.onestMetadata,
      applicationCount: base.applicationCount,
      applied: base.applied,
      viewed: base.viewed,
      // Parse the additional list
      similarJobs:
          (json['similar_jobs'] as List<dynamic>?)
              ?.map(
                (e) => JobListingResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json.addAll({'similar_jobs': similarJobs?.map((e) => e.toJson()).toList()});
    return json;
  }
}

// Paginated job listing response (used for lists)
class JobListingListResponse {
  final List<JobListingResponse> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  JobListingListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  factory JobListingListResponse.fromJson(Map<String, dynamic> json) {
    return JobListingListResponse(
      items:
          (json['items'] as List<dynamic>)
              .map(
                (e) => JobListingResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      total: json['total'] as int,
      page: json['page'] as int? ?? 1, // Default page to 1 if missing
      size: json['size'] as int? ?? 10, // Default size to 10 if missing
      pages: json['pages'] as int? ?? 0, // Default pages to 0 if missing
    );
  }

  Map<String, dynamic> toJson() => {
    'items': items.map((e) => e.toJson()).toList(),
    'total': total,
    'page': page,
    'size': size,
    'pages': pages,
  };
}

// Job search parameters class (useful for constructing query parameters)
class JobSearchParams {
  final String? title;
  final String? role;
  final String? domain;
  final String? location;
  final EmploymentType? employmentType;
  final num? salaryLower;
  final num? salaryUpper;
  final List<String>? skills;
  final int? page;
  final int? size;
  // Note: sorting handled client-side in RN code, mirror that or adjust based on actual API support
  final String? sortBy; // 'posted_at' | 'salary_lower' | 'salary_upper'
  final String? sortOrder; // 'asc' | 'desc'

  JobSearchParams({
    this.title,
    this.role,
    this.domain,
    this.location,
    this.employmentType,
    this.salaryLower,
    this.salaryUpper,
    this.skills,
    this.page,
    this.size,
    this.sortBy,
    this.sortOrder,
  });

  // Method to convert search params to a map suitable for query parameters
  // Filters out null values
  Map<String, dynamic> toQueryParameters() {
    final Map<String, dynamic> params = {};
    if (title != null) params['title'] = title;
    if (role != null) params['role'] = role;
    if (domain != null) params['domain'] = domain;
    if (location != null) params['location'] = location;
    if (employmentType != null) {
      params['employment_type'] = employmentTypeToString(employmentType!);
    }
    if (salaryLower != null) params['salary_lower'] = salaryLower.toString();
    if (salaryUpper != null) params['salary_upper'] = salaryUpper.toString();
    if (skills != null && skills!.isNotEmpty) {
      params['skills'] = skills!.join(','); // Assuming comma-separated for API
    }
    if (page != null) params['page'] = page.toString();
    if (size != null) params['size'] = size.toString();
    if (sortBy != null) params['sort_by'] = sortBy;
    if (sortOrder != null) params['sort_order'] = sortOrder;

    // Adjust backend mapping if needed (e.g., skip/limit instead of page/size)
    // if (page != null && size != null) {
    //    params['skip'] = ((page! - 1) * size!).toString();
    //    params['limit'] = size!.toString();
    // }
    return params;
  }
}
