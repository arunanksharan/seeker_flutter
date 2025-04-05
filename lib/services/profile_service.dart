// lib/services/profile_service.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/models/profile_models.dart'; // Your profile models
import 'package:seeker/services/api_client.dart'; // For dioProvider
import 'package:seeker/utils/logger.dart'; // Your logger
import 'package:seeker/core/errors/exceptions.dart'; // Import custom exceptions

// Riverpod provider for the ProfileService
final profileServiceProvider = Provider<ProfileService>((ref) {
  final dio = ref.watch(dioProvider); // Get the configured Dio instance
  return ProfileService(dio);
});

class ProfileService {
  final Dio _dio;

  ProfileService(this._dio);

  // --- Core Profile Operations ---

  /// Get seeker profile for the authenticated user
  /// Returns null if profile not found (404/204) or on specific config errors.
  /// Throws custom exceptions for other errors (Network, Server, etc.).
  Future<SeekerProfileApiResponse?> getProfile() async {
    const String endpoint = '/api/v1/profile';
    logger.i('Getting seeker profile from $endpoint');
    try {
      final response = await _dio.get<Map<String, dynamic>>(endpoint);

      // Handle cases where backend might return 200/204 with no body
      if (response.data == null || response.data!.isEmpty) {
        // This case might indicate "no profile exists" depending on API design
        // Consistent with 404/204 handling below, return null.
        logger.i(
          'Profile endpoint returned successful status but no data. Assuming profile does not exist.',
        );
        return null;
      }

      logger.d('Profile retrieved successfully.');
      return SeekerProfileApiResponse.fromJson(response.data!);
    } on DioException catch (e, stackTrace) {
      logger.e(
        'DioException getting profile',
        error: e,
        stackTrace: stackTrace,
      );
      // Handle 404 Not Found or 204 No Content gracefully by returning null
      if (e.response?.statusCode == 404 || e.response?.statusCode == 204) {
        logger.i('Profile not found (404/204), user needs to create one.');
        return null; // Return null indicating profile doesn't exist yet
      }
      // Throw specific custom exceptions for other Dio errors
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'Network error fetching profile: ${e.message}',
          stackTrace,
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final message = e.response!.data?['detail']?.toString() ?? e.message;
        if (statusCode != null && statusCode >= 500) {
          throw BackendServerException(
            'Server error fetching profile ($statusCode): $message',
            stackTrace,
          );
        } else {
          throw UnexpectedErrorException(
            'Failed to fetch profile ($statusCode): $message',
            stackTrace,
          );
        }
      } else {
        throw NetworkException(
          'Network error fetching profile: ${e.message}',
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      // Catch non-Dio errors during parsing etc.
      logger.e(
        'Unexpected error getting profile',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnexpectedErrorException(
        'An unexpected error occurred while fetching the profile: $e',
        stackTrace,
      );
    }
  }

  /// Create or update seeker profile.
  /// Throws custom exceptions on failure.
  Future<SeekerProfileApiResponse> updateProfile({
    required SeekerProfileApiRequest profileData,
    required bool isUpdate, // Determine if it's POST (create) or PUT (update)
  }) async {
    final method = isUpdate ? 'PUT' : 'POST';
    const String endpoint = '/api/v1/profile';
    logger.i('${method}ting seeker profile at $endpoint');
    // Avoid logging potentially large/sensitive profile data in production
    // logger.d('Profile data: ${profileData.toJson()}');

    try {
      final response = await _dio.request<Map<String, dynamic>>(
        endpoint,
        data: profileData.toJson(),
        options: Options(method: method),
      );

      if (response.data != null && response.data!.isNotEmpty) {
        logger.i('Profile ${isUpdate ? 'updated' : 'created'} successfully.');
        return SeekerProfileApiResponse.fromJson(response.data!);
      } else {
        // This case indicates an unexpected successful response with no data
        logger.e(
          'API returned status ${response.statusCode} but no profile data after $method.',
        );
        throw const UnexpectedErrorException(
          'Profile save/update succeeded but no data was returned.',
        );
      }
    } on DioException catch (e, stackTrace) {
      logger.e(
        'DioException ${isUpdate ? 'updating' : 'creating'} profile',
        error: e,
        stackTrace: stackTrace,
      );
      // Throw specific custom exceptions based on DioError
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        throw NetworkException(
          'Network error saving profile: ${e.message}',
          stackTrace,
        );
      } else if (e.response != null) {
        final statusCode = e.response!.statusCode;
        final responseData = e.response!.data;
        final detail =
            responseData is Map
                ? responseData['detail']
                : responseData.toString();
        final message = detail ?? e.message ?? 'Unknown server error';

        if (isUpdate && statusCode == 404) {
          // PUT returned 404
          throw AccountNotFoundException(
            'Cannot update profile: $message',
            stackTrace,
          ); // Or a more specific UpdateFailedException
        } else if (!isUpdate && statusCode == 400) {
          // POST returned 400
          // Could be "Profile already exists" or validation error from backend
          throw BadRequestException(
            'Failed to create profile: $message',
            stackTrace,
          );
        } else if (statusCode == 400) {
          // PUT returned 400 (likely validation)
          throw BadRequestException(
            'Failed to update profile (validation error?): $message',
            stackTrace,
          );
        } else if (statusCode != null && statusCode >= 500) {
          throw BackendServerException(
            'Server error saving profile ($statusCode): $message',
            stackTrace,
          );
        } else {
          throw UnexpectedErrorException(
            'Failed to save profile ($statusCode): $message',
            stackTrace,
          );
        }
      } else {
        throw NetworkException(
          'Network error sending profile data: ${e.message}',
          stackTrace,
        );
      }
    } catch (e, stackTrace) {
      // Catch non-Dio errors during toJson or parsing etc.
      logger.e(
        'Unexpected error ${isUpdate ? 'updating' : 'creating'} profile',
        error: e,
        stackTrace: stackTrace,
      );
      throw UnexpectedErrorException(
        'An unexpected error occurred while saving the profile: $e',
        stackTrace,
      );
    }
  }

  // --- REMOVED METHODS ---
  // Removed getProfileById
  // Removed getProfileCompletionPercentage
  // Removed uploadProfilePicture
  // Removed uploadDocument
  // Removed addEducation, updateEducation, deleteEducation
  // Removed addWorkExperience, updateWorkExperience, deleteWorkExperience
  // Removed addSkill, updateSkill, deleteSkill
  // Removed updateJobPreferences (as updateProfile handles the whole profile)
}
