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
    // Only attempt token refresh if we get a 401 status code
    if (response.statusCode == 401) {
      try {
        final success = await _refreshToken();
        if (success) {
          // Retry the request with the new access token
          final newToken = await storageService.getAccessToken();
          if (newToken != null) {
            response.requestOptions.headers['Authorization'] =
                'Bearer $newToken';
            final cloneReq = await dio.request(
              response.requestOptions.path,
              options: Options(
                method: response.requestOptions.method,
                headers: response.requestOptions.headers,
              ),
              data: response.requestOptions.data,
              queryParameters: response.requestOptions.queryParameters,
            );
            return handler.resolve(cloneReq);
          }
        }
        // If we reach here, token refresh failed
        await _logout();
        throw AppError(
          userMessage: ErrorMessages.sessionExpired,
          type: ErrorType.authentication,
        );
      } catch (e) {
        await _logout();
        throw AppError(
          userMessage: ErrorMessages.sessionExpired,
          type: ErrorType.authentication,
        );
      }
    }
    return handler.next(response);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storageService.getRefreshToken();
    if (refreshToken == null) {
      Logger.debug('No refresh token available');
      return false;
    }

    try {
      final response = await dio.post(
        ApiEndpoints.baseUrl + ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
        options: Options(
          validateStatus: (status) => status! < 500,
        ),
      );

      if (response.statusCode == 200 && response.data != null) {
        final newAccessToken = response.data['access_token'];
        final newRefreshToken = response.data['refresh_token'];

        if (newAccessToken != null) {
          final userId = await storageService.getUserId();
          if (userId != null) {
            await storageService.saveTokens(
              accessToken: newAccessToken,
              refreshToken: newRefreshToken ?? refreshToken,
              userId: userId,
            );
            return true;
          }
        }
        Logger.debug('Token refresh failed: Invalid response data');
        return false;
      }

      Logger.debug('Token refresh failed with status: ${response.statusCode}');
      return false;
    } catch (e) {
      Logger.error('Error refreshing token:', e);
      return false;
    }
  }

  Future<void> _logout() async {
    await storageService.clearAll();
    Navigator.of(NavigationService.navigatorKey.currentContext!)
        .pushNamedAndRemoveUntil(AppRouts.signIn, (route) => false);
  }
}
