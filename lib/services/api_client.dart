// lib/services/api_client.dart
import 'dart:async'; // For Completer/Future needed if improving queue

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:seeker/core/config.dart';
import 'package:seeker/models/auth_models.dart';
import 'package:seeker/services/token_service.dart';
import 'package:seeker/utils/logger.dart';
// Import auth state provider to trigger logout
import 'package:seeker/features/auth/application/auth_state.dart';

// Provider for the TokenService (can stay the same)
final tokenServiceProvider = Provider<TokenService>((ref) => TokenService());

// Provider for the main Dio instance (now depends on ApiClient directly)
// The ApiClient itself will be provided separately if needed,
// but often only the configured Dio instance is needed by other services.
final dioProvider = Provider<Dio>((ref) {
  // Provide Ref to ApiClient constructor for accessing other providers internally
  return ApiClient(ref).dio;
});

// Provider for the separate Dio instance for refresh token calls
final dioRefreshProvider = Provider<Dio>((ref) {
  logger.d("Creating dioRefreshProvider instance"); // Log instance creation
  final options = BaseOptions(
    baseUrl: AppConfig.apiUrl,
    connectTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
    receiveTimeout: Duration(milliseconds: AppConfig.apiTimeoutMs),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );
  return Dio(options);
});

// --- ApiClient Class ---
class ApiClient {
  final Ref _ref; // Use Ref for reading providers internally
  late final Dio dio;
  // Access TokenService via Ref
  TokenService get _tokenService => _ref.read(tokenServiceProvider);

  // --- Refresh Token Lock and Queue ---
  // Volatile flag to prevent multiple concurrent refresh attempts.
  // A more robust solution might use a Mutex or Completer if high concurrency is expected.
  bool _isRefreshing = false;
  // Simplified queue: stores options of requests that failed with 401 while refreshing.
  // Note: This implementation retries requests but doesn't easily return the
  //       retry result back to the original caller. Full queuing solutions are complex.
  final List<RequestOptions> _retryQueue = [];
  // --- ---------------------------- ---

  ApiClient(this._ref) {
    // Constructor now takes Ref
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
    // Basic logging... (remains the same)
    logger.d('--> ${options.method.toUpperCase()} ${options.path}');

    final noAuthPaths = [
      /* ... (paths remain the same) ... */
      '/api/v1/auth/refresh',
      '/api/v1/auth/exchange-firebase-token',
      '/api/v1/auth/request-otp',
      '/api/v1/auth/verify-otp',
      '/api/v1/auth/signup',
    ];

    // Add Authorization header if required
    if (!noAuthPaths.any((path) => options.path.contains(path))) {
      final accessToken = await _tokenService.getAccessToken();
      if (accessToken != null) {
        options.headers['Authorization'] = 'Bearer $accessToken';
        logger.d('Authorization header added for ${options.path}.');
      } else {
        logger.w(
          'No access token found for authorized request to ${options.path}',
        );
        // Optional: Depending on app requirements, you might want to reject the request here
        // if an access token is strictly required but missing.
        // handler.reject(DioException(requestOptions: options, message: "Access token missing"));
        // return;
      }
    } else {
      logger.d('Skipping token attachment for public path: ${options.path}');
    }

    return handler.next(options);
  }

  // --- Response Interceptor ---
  void _onResponse(Response response, ResponseInterceptorHandler handler) {
    // Basic logging... (remains the same)
    logger.d(
      '<-- ${response.statusCode} ${response.requestOptions.method.toUpperCase()} ${response.requestOptions.path}',
    );
    return handler.next(response);
  }

  // --- Error Interceptor (Refined) ---
  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    logger.e(
      '<-- ERROR ${err.response?.statusCode} ${err.requestOptions.method.toUpperCase()} ${err.requestOptions.path}',
    );
    logger.e(
      'Dio Error: ${err.message}',
      error: err.error,
      stackTrace: err.stackTrace,
    );
    if (err.response?.data != null)
      logger.e('Error Data: ${err.response?.data}');

    final response = err.response;
    final requestOptions = err.requestOptions;

    // Attempt refresh only for 401 Unauthorized errors on non-auth endpoints
    final isAuthEndpoint = requestOptions.path.contains('/api/v1/auth/');
    if (response?.statusCode == 401 && !isAuthEndpoint) {
      logger.w(
        'Received 401 Unauthorized for ${requestOptions.path}. Handling token refresh.',
      );

      // --- Locking Mechanism ---
      if (!_isRefreshing) {
        // Acquire lock: Only one refresh attempt at a time
        _isRefreshing = true;
        logger.d('Acquired token refresh lock.');

        try {
          final newTokens = await _refreshToken(); // Attempt refresh

          if (newTokens != null) {
            // --- Refresh Successful ---
            logger.i(
              'Token refresh successful. Retrying original request and processing queue.',
            );
            final newAccessToken = newTokens.accessToken;
            // Update header for the original failed request
            requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';

            // Release lock *before* retrying and processing queue
            _isRefreshing = false;
            logger.d('Released token refresh lock (Success).');

            // Retry the original request that failed with 401
            try {
              logger.d('Retrying original request: ${requestOptions.path}');
              // Use dio.fetch which accepts RequestOptions directly for a cleaner retry
              final retryResponse = await dio.fetch(requestOptions);
              logger.i('Original request successful after retry.');
              // Process any queued requests *after* successfully retrying the original
              _processRetryQueue(newAccessToken);
              return handler.resolve(
                retryResponse,
              ); // Resolve the original error with the new response
            } on DioException catch (retryError) {
              // Catch error during retry
              logger.e(
                'Original request failed AFTER token refresh and retry.',
                error: retryError,
              );
              _clearRetryQueue(); // Clear queue as retry failed
              // Reject with the retry error, as it's more relevant now than the original 401
              return handler.reject(retryError);
            }
          } else {
            // --- Refresh Failed (e.g., invalid refresh token) ---
            logger.e(
              'Token refresh failed. Clearing tokens & queue, triggering logout.',
            );
            await _tokenService.clearTokens();
            _clearRetryQueue();
            // TODO: Trigger global logout state via Riverpod provider - IMPLEMENTED
            _ref.read(authStateProvider.notifier).logout(); // Trigger logout
            _isRefreshing = false; // Release lock
            logger.d('Released token refresh lock (Refresh Failed).');
            return handler.reject(err); // Reject the original 401 error
          }
        } catch (refreshException, stackTrace) {
          // Catch unexpected errors during _refreshToken() itself
          logger.e(
            'Exception during _refreshToken call.',
            error: refreshException,
            stackTrace: stackTrace,
          );
          _isRefreshing = false; // Release lock
          _clearRetryQueue();
          // TODO: Possibly clear tokens here too depending on the error - IMPLEMENTED (in _refreshToken)
          logger.d('Released token refresh lock (Exception).');
          return handler.reject(err); // Reject the original 401 error
        }
        // 'finally' block is less needed now as lock release is handled in each branch
      } else {
        // --- Refresh In Progress - Queue Request ---
        // Lock is already held by another request doing the refresh
        logger.i(
          'Token refresh already in progress. Queuing request for ${requestOptions.path}',
        );
        // Add the failed request to the queue to be retried later IF refresh succeeds
        _retryQueue.add(requestOptions);
        // We cannot pause the interceptor here easily. Rejecting the error tells the caller
        // that this specific request failed, but doesn't prevent the ongoing refresh
        // or the potential success/failure notification from that process.
        // The original caller might need its own retry logic if this specific rejection occurs.
        return handler.reject(err);
        // --- End Queue Request ---
      }
      // --- End Locking Mechanism ---
    }

    // If not a 401 error or if it's an auth endpoint, forward the error
    return handler.next(err);
  }

  // --- Token Refresh Logic (Refined) ---
  Future<AuthResponse?> _refreshToken() async {
    final refreshToken = await _tokenService.getRefreshToken();
    if (refreshToken == null) {
      logger.w('No refresh token available for refresh attempt.');
      return null; // Can't refresh without a token
    }

    try {
      // Use the dedicated Dio instance for refreshing (no interceptors)
      final refreshDio = _ref.read(dioRefreshProvider);

      logger.i('Calling refresh token endpoint: /api/v1/auth/refresh');
      final response = await refreshDio.post(
        '/api/v1/auth/refresh',
        data: {'token': refreshToken},
      );

      // Check for successful status code (e.g., 200 OK)
      if (response.statusCode == 200 && response.data is Map<String, dynamic>) {
        final authResponse = AuthResponse.fromJson(
          response.data as Map<String, dynamic>,
        );
        // Optional: Validate received tokens are not empty
        if (authResponse.accessToken.isNotEmpty &&
            authResponse.refreshToken.isNotEmpty) {
          await _tokenService.saveTokens(
            authResponse.accessToken,
            authResponse.refreshToken,
          );
          logger.i('Token refresh successful: New tokens obtained and saved.');
          return authResponse;
        } else {
          logger.e(
            'Refresh token endpoint returned success status but invalid token data.',
          );
          // Treat as failure, potentially clear tokens as response is unexpected
          await _tokenService.clearTokens();
          // TODO: Trigger global logout state via Riverpod provider - IMPLEMENTED
          _ref.read(authStateProvider.notifier).logout();
          return null;
        }
      } else {
        // Log unexpected success status code
        logger.e(
          'Refresh token endpoint returned unexpected status: ${response.statusCode} or invalid data format.',
        );
        // Treat as failure, potentially clear tokens
        await _tokenService.clearTokens();
        // TODO: Trigger global logout state via Riverpod provider - IMPLEMENTED
        _ref.read(authStateProvider.notifier).logout();
        return null;
      }
    } on DioException catch (e, stackTrace) {
      // Catch Dio errors specifically during refresh
      logger.e(
        'DioException during token refresh API call',
        error: e,
        stackTrace: stackTrace,
      );
      // If refresh token itself is rejected (401/403 usually), clear tokens & logout
      if (e.response?.statusCode == 401 ||
          e.response?.statusCode == 403 ||
          e.response?.statusCode == 400) {
        logger.e(
          'Refresh token seems invalid or expired (Status: ${e.response?.statusCode}). Clearing tokens and triggering logout.',
        );
        await _tokenService.clearTokens();
        // TODO: Trigger global logout state via Riverpod provider - IMPLEMENTED
        _ref.read(authStateProvider.notifier).logout();
      }
      // For other Dio errors (network, server error on refresh endpoint), just return null, maybe retry later?
      return null; // Indicate refresh failed
    } catch (e, stackTrace) {
      // Catch non-Dio errors
      logger.e(
        'Unexpected error during token refresh logic',
        error: e,
        stackTrace: stackTrace,
      );
      return null; // Indicate refresh failed
    }
  }

  // --- Retry Queue Logic (Refined Comments) ---
  // This simplified queue attempts retries but doesn't easily return results/errors
  // back to the original callers of the queued requests. Callers might timeout or fail.
  // A robust solution often uses Completers mapped to request IDs.
  void _processRetryQueue(String newAccessToken) async {
    logger.d('Processing ${_retryQueue.length} queued requests...');
    final queue = List<RequestOptions>.from(_retryQueue); // Copy queue
    _retryQueue.clear(); // Clear original immediately

    for (final requestOptions in queue) {
      requestOptions.headers['Authorization'] = 'Bearer $newAccessToken';
      try {
        logger.d('Retrying queued request for ${requestOptions.path}');
        // Use fetch to retry with potentially modified options
        await dio.fetch(requestOptions);
        logger.i(
          'Queued request successful after retry: ${requestOptions.path}',
        );
      } catch (e) {
        logger.e(
          'Failed to retry queued request for ${requestOptions.path}',
          error: e,
        );
        // Errors for queued requests are logged but not propagated back to original caller easily.
      }
    }
    logger.d('Finished processing retry queue.');
  }

  void _clearRetryQueue() {
    if (_retryQueue.isNotEmpty) {
      logger.w('Clearing ${_retryQueue.length} requests from retry queue.');
      _retryQueue.clear();
    }
  }
}

// --- Example Usage (remains the same) ---
// final someServiceProvider = Provider((ref) {
//   final dio = ref.watch(dioProvider);
//   return SomeService(dio);
// });
