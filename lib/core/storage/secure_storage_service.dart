import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SecureStorageService {
  final FlutterSecureStorage _storage;

  SecureStorageService({FlutterSecureStorage? storage})
      : _storage = storage ?? const FlutterSecureStorage();

  static const String _accessTokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';
  static const String _userIdKey = 'user_id';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
    required String userId,
  }) async {
    await _storage.write(key: _accessTokenKey, value: accessToken);
    await _storage.write(key: _refreshTokenKey, value: refreshToken);
    await _storage.write(key: _userIdKey, value: userId);
  }

  Future<String?> getAccessToken() async {
    return await _storage.read(key: _accessTokenKey);
  }

  Future<String?> getRefreshToken() async {
    return await _storage.read(key: _refreshTokenKey);
  }

  Future<String?> getUserId() async {
    return await _storage.read(key: _userIdKey);
  }

  Future<void> clearAll() async {
    await _storage.deleteAll();
  }

  Future<String?> getCloudinaryApiKey() async {
    return dotenv.env['CLOUDINARY_API_KEY'];
  }

  Future<String?> getCloudinaryApiSecret() async {
    return dotenv.env['CLOUDINARY_API_SECRET'];
  }

  Future<void> saveCloudinaryCredentials({
    required String apiKey,
    required String apiSecret,
  }) async {
    await _storage.write(key: 'cloudinary_api_key', value: apiKey);
    await _storage.write(key: 'cloudinary_api_secret', value: apiSecret);
  }
}
