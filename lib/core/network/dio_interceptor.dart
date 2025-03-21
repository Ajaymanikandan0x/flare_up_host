import 'package:dio/dio.dart';
import 'package:flare_up_host/core/error/app_error.dart';

import '../constants/api_constants.dart';
import '../storage/secure_storage_service.dart';

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
            type: ErrorType.authentication);
      } catch (e) {
        await _logout();
        throw AppError(
            userMessage: ErrorMessages.sessionExpired,
            type: ErrorType.authentication);
      }
    }
    return handler.next(response);
  }

  Future<bool> _refreshToken() async {
    final refreshToken = await storageService.getRefreshToken();
    if (refreshToken == null) return false;

    try {
      final response = await dio.post(
        ApiEndpoints.baseUrl + ApiEndpoints.refreshToken,
        data: {'refresh_token': refreshToken},
      );

      if (response.statusCode == 200) {
        final newAccessToken = response.data['access_token'];
        await storageService.saveTokens(
          accessToken: newAccessToken,
          refreshToken: refreshToken,
          userId: await storageService.getUserId() ?? '',
        );
        return true;
      }
    } catch (e) {
      print('Error refreshing token: $e');
    }
    return false;
  }

  Future<void> _logout() async {
    await storageService.clearAll();
    // Redirect to login screen or emit a logout event
  }
}
