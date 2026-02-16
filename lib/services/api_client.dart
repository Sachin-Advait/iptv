// data/source/remote/api_client.dart
import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:oman_tv/common/constants/app_errors.dart';
import 'package:oman_tv/common/utils/get_it.dart';
import 'package:oman_tv/common/widgets/flutter_toast.dart';
import 'package:oman_tv/configs/theme/app_colors.dart';
import 'package:oman_tv/services/connectivity_service.dart';
import 'package:retry/retry.dart';

class NoInternetException implements Exception {
  final String message;
  NoInternetException([this.message = 'No internet connection']);

  @override
  String toString() => message;
}

class ApiClient {
  final Dio _dio;
  final ConnectivityService _connectivityService = getIt
      .get<ConnectivityService>();

  // Retry configuration for production kiosk app
  final RetryOptions _retryOptions = const RetryOptions(
    maxAttempts: 5,
    delayFactor: Duration(seconds: 2),
    randomizationFactor: 0.25,
    maxDelay: Duration(seconds: 15),
  );

  ApiClient({required Dio dio}) : _dio = dio;

  /// GET with retry mechanism
  Future<Response?> getApi(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    bool enableRetry = true,
  }) async {
    return _executeWithRetry(
      () => _dio.get(path, queryParameters: queryParameters, options: options),
      enableRetry: enableRetry,
    );
  }

  /// POST with retry mechanism
  Future<Response?> postApi(
    String path, {
    dynamic body,
    bool enableRetry = true,
  }) async {
    return _executeWithRetry(
      () => _dio.post(path, data: body),
      enableRetry: enableRetry,
    );
  }

  /// POST with retry mechanism
  Future<Response?> putApi(
    String path, {
    dynamic body,
    bool enableRetry = true,
  }) async {
    return _executeWithRetry(
      () => _dio.put(path, data: body),
      enableRetry: enableRetry,
    );
  }

  /// Core retry execution wrapper
  Future<Response?> _executeWithRetry(
    Future<Response> Function() request, {
    required bool enableRetry,
  }) async {
    // Check internet before attempting
    if (!await _connectivityService.checkConnection()) {
      flutterToast(message: AppErrors.noInternetDetails);
      throw NoInternetException();
    }

    if (!enableRetry) {
      try {
        return await request();
      } on DioException catch (e) {
        _handleError(e);
        rethrow;
      }
    }

    try {
      return await _retryOptions.retry(
        () async {
          // Recheck connectivity before each retry
          if (!await _connectivityService.checkConnection()) {
            throw NoInternetException();
          }
          return await request();
        },
        retryIf: (e) => _shouldRetry(e),
        onRetry: (e) => debugPrint('🔄 Retrying API call due to: $e'),
      );
    } on NoInternetException catch (_) {
      flutterToast(message: AppErrors.noInternetDetails);
      rethrow;
    } on DioException catch (e) {
      _handleError(e);
      rethrow;
    } catch (e) {
      debugPrint('❌ Unexpected error: $e');
      flutterToast(message: AppErrors.unknownErrorDetails);
      rethrow;
    }
  }

  /// Determine if the error is retryable
  bool _shouldRetry(Exception e) {
    if (e is NoInternetException) return false;

    if (e is DioException) {
      // Retry on network errors and timeouts
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.sendTimeout ||
          e.type == DioExceptionType.receiveTimeout ||
          e.type == DioExceptionType.connectionError) {
        return true;
      }

      // Retry on specific HTTP status codes
      if (e.response?.statusCode != null) {
        final statusCode = e.response!.statusCode!;
        // Retry on server errors (500-599) or rate limiting (429)
        if (statusCode >= 500 || statusCode == 429) {
          return true;
        }
      }

      // Retry on socket exceptions
      if (e.error is SocketException) {
        return true;
      }
    }

    return false;
  }

  /// Handle and display error messages
  void _handleError(DioException e) {
    debugPrint('❌ API ERROR ===> ${e.type}: ${e.message}');

    switch (e.type) {
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionTimeout:
        flutterToast(message: AppErrors.serverTimeoutErrorDetails);
        break;

      case DioExceptionType.connectionError:
        if (e.error is SocketException) {
          flutterToast(message: AppErrors.noInternetDetails);
        } else {
          flutterToast(message: AppErrors.serverErrorDetails);
        }
        break;

      case DioExceptionType.badResponse:
        _handleBadResponse(e);
        break;

      case DioExceptionType.cancel:
        // Request was cancelled, no toast needed
        break;

      default:
        flutterToast(message: AppErrors.unknownErrorDetails);
        break;
    }
  }

  void _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;

    if (statusCode == 400) {
      final errorData = e.response!.data;
      final errorMessage = errorData is Map<String, dynamic>
          ? (errorData['message'] ?? e.response!.statusMessage ?? 'Bad Request')
          : e.response!.statusMessage ?? 'Bad Request';
      flutterToast(message: errorMessage, color: AppColors.red);
    } else if (statusCode == 401) {
      flutterToast(
        message: 'Unauthorized. Please check credentials.',
        color: AppColors.red,
      );
    } else if (statusCode == 403) {
      flutterToast(message: 'Access forbidden.', color: AppColors.red);
    } else if (statusCode == 404) {
      // Silent handling for 404, or show custom message if needed
      debugPrint('Resource not found: ${e.requestOptions.path}');
    } else if (statusCode == 429) {
      flutterToast(
        message: 'Too many requests. Please wait.',
        color: AppColors.red,
      );
    } else if (statusCode != null && statusCode >= 500) {
      flutterToast(message: AppErrors.serverErrorDetails, color: AppColors.red);
    } else {
      flutterToast(
        message: AppErrors.unknownErrorDetails,
        color: AppColors.red,
      );
    }
  }
}
