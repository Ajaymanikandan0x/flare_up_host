import 'package:dio/dio.dart';
import 'package:flare_up_host/core/error/app_error.dart';
import 'package:flare_up_host/core/utils/logger.dart';
import 'package:flare_up_host/service/navigation_service.dart';
import 'package:flutter/material.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';
import '../routes/routs.dart';

class AuthInterceptor extends Interceptor {
  final SecureStorageService storageService;
  final Dio dio;

  AuthInterceptor(this.storageService, this.dio);

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await storageService.getAccessToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    return handler.next(options);
  }

  @override
  Future<void> onResponse(
    Response response,
    ResponseInterceptorHandler handler,
  ) async {
    if (response.statusCode == 401) {
      try {
        Logger.debug('Attempting to refresh token...');
        final success = await _refreshToken();

        if (success) {
          final newToken = await storageService.getAccessToken();
          if (newToken != null) {
            Logger.debug('Retrying request with new token');
            final cloneReq = await dio.request(
              response.requestOptions.path,
              options: Options(
                method: response.requestOptions.method,
                headers: {
                  ...response.requestOptions.headers,
                  'Authorization': 'Bearer $newToken',
                },
              ),
              data: response.requestOptions.data,
              queryParameters: response.requestOptions.queryParameters,
            );
            return handler.resolve(cloneReq);
          }
        }

        Logger.debug('Token refresh failed, handling session expiration');
        await _handleSessionExpired();
        throw AppError(
          userMessage: ErrorMessages.sessionExpired,
          type: ErrorType.authentication,
        );
      } catch (e) {
        Logger.error('Error during token refresh:', e);
        await _handleSessionExpired();
        return handler.reject(
          DioException(
            requestOptions: response.requestOptions,
            error: AppError(
              userMessage: ErrorMessages.sessionExpired,
              type: ErrorType.authentication,
            ),
          ),
        );
      }
    }
    return handler.next(response);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storageService.getRefreshToken();
    if (refreshToken == null) {
      Logger.debug('No refresh token available');
      await _handleSessionExpired();
      return false;
    }

    try {
      final response = await dio.post(
        ApiEndpoints.baseUrl + ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          validateStatus: (status) => true,
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      Logger.debug('Refresh token response status: ${response.statusCode}');
      Logger.debug('Refresh token response data: ${response.data}');

      if (response.statusCode == 200 && response.data != null) {
        final data = response.data;
        final newAccessToken =
            data['accessToken'] ?? data['access_token'] ?? data['token'];
        final newRefreshToken =
            data['refreshToken'] ?? data['refresh_token'] ?? refreshToken;

        if (newAccessToken != null) {
          final userId = await storageService.getUserId();
          if (userId != null) {
            await storageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken,
              userId: userId,
            );
            Logger.debug('Token refresh successful');
            return true;
          }
        }
      }

      if (response.statusCode != 200) {
        if (response.statusCode == 400 || response.statusCode == 401) {
          Logger.debug(
              'Token refresh failed: ${response.data['error'] ?? 'Invalid token'}');
          await _handleSessionExpired();
        } else {
          Logger.debug(
              'Token refresh failed with status: ${response.statusCode}');
          Logger.debug('Response data: ${response.data}');
        }
      }

      if (response.statusCode == 200) {
        Logger.debug('Got 200 response but failed to process tokens');
      }

      return response.statusCode == 200 &&
          response.data != null &&
          (response.data['accessToken'] != null ||
              response.data['access_token'] != null);
    } catch (e) {
      Logger.error('Error refreshing token:', e);
      await _handleSessionExpired();
      return false;
    }
  }

  Future<void> _handleSessionExpired() async {
    await storageService.clearAll();
    final context = NavigationService.navigatorKey.currentContext;
    if (context != null && context.mounted) {
      Navigator.of(context).pushNamedAndRemoveUntil(
        AppRouts.signIn,
        (route) => false,
      );
    }
  }
}
