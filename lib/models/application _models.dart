// Based on seeker-rn-files/types/application.ts
import 'package:seeker_flutter/models/job_models.dart'; // For EmploymentType

// --- Enums ---

enum ApplicationStatus {
  applied, // "Applied"
  shortlisted, // "Shortlisted"
  interviewScheduled, // "Interview Scheduled" - Adjusted name for convention
  interviewed, // "Interviewed"
  offerExtended, // "Offer Extended"
  offerAccepted, // "Offer Accepted"
  rejected, // "Rejected"
  withdrawn, // "Withdrawn"
}

// Helper to map ApplicationStatus enum to API string value
String applicationStatusToString(ApplicationStatus status) {
  switch (status) {
    case ApplicationStatus.applied:
      return "Applied";
    case ApplicationStatus.shortlisted:
      return "Shortlisted";
    case ApplicationStatus.interviewScheduled:
      return "Interview Scheduled";
    case ApplicationStatus.interviewed:
      return "Interviewed";
    case ApplicationStatus.offerExtended:
      return "Offer Extended";
    case ApplicationStatus.offerAccepted:
      return "Offer Accepted";
    case ApplicationStatus.rejected:
      return "Rejected";
    case ApplicationStatus.withdrawn:
      return "Withdrawn";
  }
}

// Helper to map string from API to ApplicationStatus enum
ApplicationStatus applicationStatusFromString(String? value) {
  switch (value) {
    case "Applied":
      return ApplicationStatus.applied;
    case "Shortlisted":
      return ApplicationStatus.shortlisted;
    case "Interview Scheduled":
      return ApplicationStatus.interviewScheduled;
    case "Interviewed":
      return ApplicationStatus.interviewed;
    case "Offer Extended":
      return ApplicationStatus.offerExtended;
    case "Offer Accepted":
      return ApplicationStatus.offerAccepted;
    case "Rejected":
      return ApplicationStatus.rejected;
    case "Withdrawn":
      return ApplicationStatus.withdrawn;
    default:
      return ApplicationStatus.applied; // Default or throw error
  }
}

enum InterviewType {
  phone, // "Phone"
  video, // "Video"
  inPerson, // "In-person" - Adjusted name
  assessment, // "Assessment"
}

// Helper to map InterviewType enum to API string value
String interviewTypeToString(InterviewType type) {
  switch (type) {
    case InterviewType.phone:
      return "Phone";
    case InterviewType.video:
      return "Video";
    case InterviewType.inPerson:
      return "In-person";
    case InterviewType.assessment:
      return "Assessment";
  }
}

// Helper to map string from API to InterviewType enum
InterviewType interviewTypeFromString(String? value) {
  switch (value) {
    case "Phone":
      return InterviewType.phone;
    case "Video":
      return InterviewType.video;
    case "In-person":
      return InterviewType.inPerson;
    case "Assessment":
      return InterviewType.assessment;
    default:
      return InterviewType.video; // Default or throw
  }
}

enum InterviewStatus {
  scheduled, // "Scheduled"
  completed, // "Completed"
  cancelled, // "Cancelled"
  rescheduled, // "Rescheduled"
}

// Helper to map InterviewStatus enum to API string value
String interviewStatusToString(InterviewStatus status) =>
    status.name[0].toUpperCase() +
    status.name.substring(1); // Capitalizes first letter

// Helper to map string from API to InterviewStatus enum
InterviewStatus interviewStatusFromString(String? value) =>
    InterviewStatus.values.firstWhere(
      (e) => (e.name[0].toUpperCase() + e.name.substring(1)) == value,
      orElse: () => InterviewStatus.scheduled, // Default or throw
    );

// --- Interfaces -> Classes ---

class Interview {
  final int interviewId;
  final int applicationId;
  final InterviewType interviewType;
  final DateTime scheduledAt;
  final int durationMinutes;
  final String? location;
  final String? meetingLink;
  final String? contactPerson;
  final String? contactDetails;
  final InterviewStatus status;
  final String? notes;
  final DateTime createdAt;
  final DateTime updatedAt;

  Interview({
    required this.interviewId,
    required this.applicationId,
    required this.interviewType,
    required this.scheduledAt,
    required this.durationMinutes,
    this.location,
    this.meetingLink,
    this.contactPerson,
    this.contactDetails,
    required this.status,
    this.notes,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Interview.fromJson(Map<String, dynamic> json) {
    return Interview(
      interviewId: json['interview_id'] as int,
      applicationId: json['application_id'] as int,
      interviewType: interviewTypeFromString(json['interview_type'] as String?),
      scheduledAt: DateTime.parse(json['scheduled_at'] as String),
      durationMinutes: json['duration_minutes'] as int,
      location: json['location'] as String?,
      meetingLink: json['meeting_link'] as String?,
      contactPerson: json['contact_person'] as String?,
      contactDetails: json['contact_details'] as String?,
      status: interviewStatusFromString(json['status'] as String?),
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  Map<String, dynamic> toJson() => {
    'interview_id': interviewId,
    'application_id': applicationId,
    'interview_type': interviewTypeToString(interviewType),
    'scheduled_at': scheduledAt.toIso8601String(),
    'duration_minutes': durationMinutes,
    'location': location,
    'meeting_link': meetingLink,
    'contact_person': contactPerson,
    'contact_details': contactDetails,
    'status': interviewStatusToString(status),
    'notes': notes,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };
}

class JobApplication {
  final int applicationId;
  final int jobId;
  final int seekerId;
  final ApplicationStatus status;
  final DateTime appliedAt;
  final DateTime updatedAt;
  final String? coverLetter;
  final String? resumeUrl; // Assuming URL, might need clarification if it's ID
  final Map<String, String>? customQuestions;
  final List<Interview>? interviews;
  final String? feedback;
  final String? notes;

  JobApplication({
    required this.applicationId,
    required this.jobId,
    required this.seekerId,
    required this.status,
    required this.appliedAt,
    required this.updatedAt,
    this.coverLetter,
    this.resumeUrl,
    this.customQuestions,
    this.interviews,
    this.feedback,
    this.notes,
  });

  factory JobApplication.fromJson(Map<String, dynamic> json) {
    return JobApplication(
      applicationId: json['application_id'] as int,
      jobId: json['job_id'] as int,
      seekerId: json['seeker_id'] as int,
      status: applicationStatusFromString(json['status'] as String?),
      appliedAt: DateTime.parse(json['applied_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      coverLetter: json['cover_letter'] as String?,
      resumeUrl: json['resume_url'] as String?,
      customQuestions:
          json['custom_questions'] == null
              ? null
              : Map<String, String>.from(json['custom_questions'] as Map),
      interviews:
          (json['interviews'] as List<dynamic>?)
              ?.map((e) => Interview.fromJson(e as Map<String, dynamic>))
              .toList(),
      feedback: json['feedback'] as String?,
      notes: json['notes'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'application_id': applicationId,
    'job_id': jobId,
    'seeker_id': seekerId,
    'status': applicationStatusToString(status),
    'applied_at': appliedAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    'cover_letter': coverLetter,
    'resume_url': resumeUrl,
    'custom_questions': customQuestions,
    'interviews': interviews?.map((e) => e.toJson()).toList(),
    'feedback': feedback,
    'notes': notes,
  };
}

// Request structure for creating a new application
class JobApplicationRequest {
  final int jobId;
  final String? coverLetter;
  final int? resumeId; // Matches TS type
  final Map<String, String>? customQuestions;

  JobApplicationRequest({
    required this.jobId,
    this.coverLetter,
    this.resumeId,
    this.customQuestions,
  });

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {'job_id': jobId};
    if (coverLetter != null) data['cover_letter'] = coverLetter;
    if (resumeId != null) data['resume_id'] = resumeId;
    if (customQuestions != null) data['custom_questions'] = customQuestions;
    return data;
  }
}

// Nested structure for job details within application response
class JobSummary {
  final String title;
  final String providerName;
  final String? providerLogo;
  final String location;
  final EmploymentType employmentType;

  JobSummary({
    required this.title,
    required this.providerName,
    this.providerLogo,
    required this.location,
    required this.employmentType,
  });

  factory JobSummary.fromJson(Map<String, dynamic> json) {
    return JobSummary(
      title: json['title'] as String,
      providerName: json['provider_name'] as String,
      providerLogo: json['provider_logo'] as String?,
      location: json['location'] as String,
      employmentType: employmentTypeFromString(
        json['employment_type'] as String?,
      ),
    );
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'provider_name': providerName,
    'provider_logo': providerLogo,
    'location': location,
    'employment_type': employmentTypeToString(employmentType),
  };
}

// API response when fetching an application, includes job summary
class JobApplicationResponse extends JobApplication {
  final JobSummary job;

  JobApplicationResponse({
    required super.applicationId,
    required super.jobId,
    required super.seekerId,
    required super.status,
    required super.appliedAt,
    required super.updatedAt,
    super.coverLetter,
    super.resumeUrl,
    super.customQuestions,
    super.interviews,
    super.feedback,
    super.notes,
    required this.job,
  });

  factory JobApplicationResponse.fromJson(Map<String, dynamic> json) {
    final base = JobApplication.fromJson(json);
    return JobApplicationResponse(
      applicationId: base.applicationId,
      jobId: base.jobId,
      seekerId: base.seekerId,
      status: base.status,
      appliedAt: base.appliedAt,
      updatedAt: base.updatedAt,
      coverLetter: base.coverLetter,
      resumeUrl: base.resumeUrl,
      customQuestions: base.customQuestions,
      interviews: base.interviews,
      feedback: base.feedback,
      notes: base.notes,
      job: JobSummary.fromJson(json['job'] as Map<String, dynamic>),
    );
  }

  @override
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> json = super.toJson();
    json['job'] = job.toJson();
    return json;
  }
}

// Paginated response for a list of applications
class JobApplicationListResponse {
  final List<JobApplicationResponse> items;
  final int total;
  final int page;
  final int size;
  final int pages;

  JobApplicationListResponse({
    required this.items,
    required this.total,
    required this.page,
    required this.size,
    required this.pages,
  });

  factory JobApplicationListResponse.fromJson(Map<String, dynamic> json) {
    return JobApplicationListResponse(
      items:
          (json['items'] as List<dynamic>)
              .map(
                (e) =>
                    JobApplicationResponse.fromJson(e as Map<String, dynamic>),
              )
              .toList(),
      total: json['total'] as int,
      page: json['page'] as int? ?? 1,
      size: json['size'] as int? ?? 10,
      pages: json['pages'] as int? ?? 0,
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

// Request structure for updating application status
class ApplicationStatusUpdateRequest {
  final ApplicationStatus status;
  final String? notes;

  ApplicationStatusUpdateRequest({required this.status, this.notes});

  Map<String, dynamic> toJson() => {
    'status': applicationStatusToString(status),
    if (notes != null) 'notes': notes,
  };
}

// Filter parameters for fetching applications
class ApplicationFilterParams {
  final ApplicationStatus? status;
  final DateTime? appliedAfter;
  final DateTime? appliedBefore;
  final int? page;
  final int? size;
  final String? sortBy; // 'applied_at' | 'updated_at';
  final String? sortOrder; // 'asc' | 'desc';

  ApplicationFilterParams({
    this.status,
    this.appliedAfter,
    this.appliedBefore,
    this.page,
    this.size,
    this.sortBy,
    this.sortOrder,
  });

  // Method to convert filter params to a map suitable for query parameters
  Map<String, String> toQueryParameters() {
    final Map<String, String> params = {};
    if (status != null) params['status'] = applicationStatusToString(status!);
    if (appliedAfter != null)
      params['applied_after'] = appliedAfter!.toIso8601String();
    if (appliedBefore != null)
      params['applied_before'] = appliedBefore!.toIso8601String();
    if (page != null) params['page'] = page.toString();
    if (size != null) params['size'] = size.toString();
    if (sortBy != null) params['sort_by'] = sortBy!;
    if (sortOrder != null) params['sort_order'] = sortOrder!;
    return params;
  }
}
