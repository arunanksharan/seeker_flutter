// lib/services/api_client.dart
import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // For providers
import 'package:seeker_flutter/core/config.dart';
import 'package:seeker_flutter/models/auth_models.dart'; // For AuthResponse parsing
import 'package:seeker_flutter/services/token_service.dart';
import 'package:seeker_flutter/utils/logger.dart';

// Provider for the TokenService
final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());

// Provider for the main Dio instance used by the app
final dioProvider = Provider<Dio>((ref) {
  final tokenService = ref.watch(tokenServiceProvider);
  return ApiClient(tokenService).dio; // Provide the configured Dio instance
});

// Specific Dio instance for refresh token calls (avoids interceptor loop)
final dioRefreshProvider = Provider<Dio>((ref) {
  final options = BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
    receiveTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );
  return Dio(options);
});

class ApiClient {
  final TokenService _tokenService;
  late final Dio dio; // Main instance with interceptors
  bool _isRefreshing = false; // Flag to prevent multiple refresh attempts
  final List<RequestOptions> _retryQueue = []; // Queue for failed requests

  ApiClient(this._tokenService) {
    final options = BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    dio = Dio(options);

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onResponse: _onResponse,
        onError: _onError,
      ),
    );
  }

  // --- Request Interceptor ---
  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    logger.d('--> ${options.method.toUpperCase()} ${options.path}');
    logger.d('Headers: ${options.headers}');
    if (options.data != null) {
      logger.d('Data: ${options.data}');
    }
    if (options.queryParameters.isNotEmpty) {
      logger.d('Query Params: ${options.queryParameters}');
    }

    // Paths that don't need the backend access token automatically attached
    final noAuthPaths = [
      '/api/v1/auth/refresh',
      '/api/v1/auth/exchange-firebase-token', // Firebase token is added manually
      '/api/v1/auth/request-otp', // Assuming OTP doesn't need auth
      '/api/v1/auth/verify-otp', // Assuming OTP doesn't need auth
      '/api/v1/auth/signup', // Assuming signup doesn't need auth
      // Add other public paths if necessary
    ];

    if (!noAuthPaths.any((path) => options.path.contains(path))) {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        logger.d('Authorization header added.');
      } else {
        logger.w(
          'No access token found for authorized request to ${options.path}',
        );
      }
    } else {
      logger.d('Skipping token attachment for public path: ${options.path}');
      // Special check for firebase token exchange - log if header exists
      if (options.path.contains('/exchange-firebase-token') &&
          options.headers.containsKey('Authorization')) {
        logger.i('Firebase ID token found in header for exchange request.');
      }
    }

    return handler.next(options); // Continue the request
  }

  // --- Response Interceptor ---
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    logger.d(
      '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}',
    );
    // logger.d('Response Data: ${response.data}'); // Be careful logging sensitive data
    return handler.next(response); // Continue with the response
  }

  // --- Error Interceptor ---
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logger.e(
      '<-- ${err.response?.statusCode} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.path}',
    );
    logger.e(
      'Dio Error: ${err.message}',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    if (err.response?.data != null) {
      logger.e('Error Data: ${err.response?.data}');
    }

    final response = err.response;
    final requestOptions = err.requestOptions;

    // Only attempt refresh for 401 Unauthorized errors and not for auth endpoints themselves
    final isAuthEndpoint = requestOptions.path.contains('/api/v1/auth/');
    if (response?.statusCode == 401 && !isAuthEndpoint) {
      logger.w(
        'Received 401 Unauthorized for ${requestOptions.path}. Attempting token refresh.',
      );

      if (!_isRefreshing) {
        // Check if refresh is already in progress
        _isRefreshing = true;
        try {
          final newTokens = await _refreshToken();
          if (newTokens != null) {
            logger.i(
              'Token refresh successful. Retrying original request and queued requests.',
            );
            // Update header for the failed request before retrying
            requestOptions.headers['Authorization'] =
                'Bearer ${newTokens.accessToken}';
            _isRefreshing =
                false; // Release lock before retrying/processing queue

            // Retry the original request
            try {
              final retryResponse = await dio.request(
                requestOptions.path,
                options: Options(
                  // Use Options to pass headers, method etc.
                  method: requestOptions.method,
                  headers: requestOptions.headers,
                  data: requestOptions.data,
                  queryParameters: requestOptions.queryParameters,
                ),
              );
              logger.i('Original request successful after retry.');
              _processRetryQueue(
                newTokens.accessToken,
              ); // Process queued requests
              return handler.resolve(
                retryResponse,
              ); // Resolve with the new response
            } catch (retryError) {
              logger.e(
                'Original request failed even after token refresh.',
                error: retryError,
              );
              _clearRetryQueue(); // Clear queue if retry fails
              // Fall through to reject the original error if retry fails
            }
          } else {
            // Refresh token failed (e.g., expired/invalid refresh token)
            logger.e('Token refresh failed. Clearing tokens and queue.');
            await _tokenService.clearTokens();
            _isRefreshing = false;
            _clearRetryQueue(); // Clear queue as we can't retry
            // TODO: Trigger global logout state via Riverpod provider
            return handler.reject(err); // Reject the original error
          }
        } catch (refreshException) {
          logger.e(
            'Exception during token refresh process.',
            error: refreshException,
          );
          _isRefreshing = false;
          _clearRetryQueue(); // Clear queue on exception
          // TODO: Possibly clear tokens here too depending on the error
          return handler.reject(err); // Reject the original error
        } finally {
          _isRefreshing = false; // Ensure lock is always released
        }
      } else {
        // Refresh already in progress, queue this request
        logger.i(
          'Token refresh in progress. Queuing request for ${requestOptions.path}',
        );
        _retryQueue.add(requestOptions);
        // Don't resolve or reject yet, wait for refresh to complete
        // Dio requires handler.next, handler.resolve, or handler.reject to be called.
        // How to pause? This part is tricky with Dio interceptors directly.
        // A common pattern involves a separate queue mechanism or potentially
        // using dio's `httpClientAdapter` for more control, but that's complex.
        // A simpler approach for now might be to just reject subsequent 401s while refreshing.
        logger.w(
          'Rejecting subsequent 401 for ${requestOptions.path} while refresh is in progress.',
        );
        return handler.reject(
          err,
        ); // Reject immediately if refresh already running
      }
    }

    return handler.next(err); // Forward other errors
  }

  // --- Token Refresh Logic ---
  Future<AuthResponse?> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) {
      logger.w('No refresh token available.');
      return null;
    }

    try {
      // Use a separate Dio instance for the refresh call to avoid interceptors loop
      // We need to create this instance or get it via a separate provider.
      // For simplicity here, let's assume we create it ad-hoc or use a pre-defined one.
      final refreshDio = Dio(
        BaseOptions(baseUrl: AppConfig.apiUrl),
      ); // Basic instance

      logger.i('Calling refresh token endpoint: /api/v1/auth/refresh');
      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {
          'token': refreshToken,
        }, // Corresponds to RefreshTokenRequest in RN
      );

      if (response.statusCode == 200) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        await _tokenService.saveTokens(
          authResponse.accessToken,
          authResponse.refreshToken,
        );
        logger.i('New tokens obtained and saved.');
        return authResponse;
      } else {
        logger.e(
          'Refresh token endpoint returned status ${response.statusCode}',
        );
        return null;
      }
    } on DioException catch (e) {
      logger.e('DioException during token refresh', error: e);
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 400 ||
          e.response?.statusCode == 500) {
        // Or specific code from backend for invalid refresh token
        logger.e('Refresh token invalid or expired. Clearing tokens.');
        await _tokenService.clearTokens();
        // TODO: Trigger global logout state
      }
      return null;
    } catch (e) {
      logger.e('Unexpected error during token refresh', error: e);
      return null;
    }
  }

  // --- Retry Queue Logic (Simplified) ---
  // A more robust implementation might use Completers or Streams
  void _processRetryQueue(String newAccessToken) async {
    logger.d('Processing ${_retryQueue.length} queued requests...');
    while (_retryQueue.isNotEmpty) {
      final requestOptions = _retryQueue.removeAt(0);
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        logger.d('Retrying queued request for ${requestOptions.path}');
        // Retry the request - Note: This doesn't return the response to the original caller easily here.
        // This simplified queue just attempts the retry. A full implementation is complex.
        await dio.request(
          requestOptions.path,
          options: Options(
            method: requestOptions.method,
            headers: requestOptions.headers,
            data: requestOptions.data,
            queryParameters: requestOptions.queryParameters,
          ),
        );
      } catch (e) {
        logger.e(
          'Failed to retry queued request for ${requestOptions.path}',
          error: e,
        );
      }
    }
  }

  void _clearRetryQueue() {
    logger.w('Clearing retry queue.');
    _retryQueue.clear();
  }
}

// --- Example: Using the Dio Provider ---
// final someServiceProvider = Provider((ref) {
//   final dio = ref.watch(dioProvider);
//   return SomeService(dio);
// });

// class SomeService {
//   final Dio _dio;
//   SomeService(this._dio);

//   Future<void> fetchData() async {
//     try {
//       final response = await _dio.get('/some/endpoint');
//       // ... process response ...
//     } catch (e) {
//       // Handle error
//     }
//   }
// }
