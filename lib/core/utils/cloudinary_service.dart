import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/constants.dart';
import '../error/app_error.dart';
import '../error/error_handler.dart';
import '../storage/secure_storage_service.dart';

enum UploadType {
  profile,
  event,
  video,
  eventBanner,
  categoryBanner,
  keyParticipant,
}

class CloudinaryService {
  final Dio _dio;
  final SecureStorageService _storageService;
  static const String _cloudinaryUrl =
      'https://api.cloudinary.com/v1_1/$cloudinaryCloudName/upload';
  static const int _connectionTimeout = 5;
  static const int _uploadTimeout = 90;

  CloudinaryService(this._storageService) : _dio = Dio();

  Future<String?> uploadFile(File file, UploadType type) async {
    try {
      // Validate file
      if (!await file.exists()) {
        throw AppError(
          userMessage: 'File not found',
          technicalMessage: 'File does not exist at path: ${file.path}',
          type: ErrorType.validation,
        );
      }

      final fileSize = await file.length();
      if (fileSize > _getMaxFileSize(type)) {
        throw AppError(
          userMessage: 'File size too large',
          technicalMessage:
              'File size: ${fileSize / (1024 * 1024)}MB exceeds allowed limit',
          type: ErrorType.validation,
        );
      }

      final mimeType = _getMimeType(file);
      if (mimeType == null) {
        throw AppError(
          userMessage: 'Unsupported file type',
          technicalMessage: 'Unknown MIME type for file: ${file.path}',
          type: ErrorType.validation,
        );
      }

      // Check connectivity
      try {
        await InternetAddress.lookup('api.cloudinary.com')
            .timeout(const Duration(seconds: _connectionTimeout));
      } catch (e) {
        throw ErrorHandler.handle(e);
      }

      // Upload file
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path, contentType: mimeType),
        'upload_preset': cloudinaryUploadPreset,
        'folder': _getFolderName(type),
        'resource_type': type == UploadType.video ? 'video' : 'image',
      });

      final response = await _dio.post(
        _cloudinaryUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          validateStatus: (status) => true,
          receiveTimeout: const Duration(minutes: 1),
          sendTimeout: const Duration(minutes: 1),
        ),
        onSendProgress: (sent, total) {
          final progress = (sent / total * 100).toStringAsFixed(2);
          print('Upload progress: $progress%');
        },
      ).timeout(
        const Duration(seconds: _uploadTimeout),
        onTimeout: () => throw AppError(
          userMessage: 'Upload timed out',
          technicalMessage: 'Upload exceeded $_uploadTimeout seconds',
          type: ErrorType.network,
        ),
      );

      if (response.statusCode == 200) {
        final publicId = response.data['public_id'] as String?;
        if (publicId != null) {
          return _formatUrl(publicId, type);
        }
      }

      throw AppError(
        userMessage: 'Failed to upload file',
        technicalMessage: _parseErrorMessage(response.data),
        type: ErrorType.server,
      );
    } catch (e) {
      throw ErrorHandler.handle(e);
    }
  }

  String _getFolderName(UploadType type) {
    switch (type) {
      case UploadType.profile:
        return 'profiles';
      case UploadType.event:
        return 'event_promo_videos';
      case UploadType.video:
        return 'event_promo_videos';
      case UploadType.eventBanner:
        return 'event_banner_images';
      case UploadType.categoryBanner:
        return 'category_banner_images';
      case UploadType.keyParticipant:
        return 'key_participants';
    }
  }

  int _getMaxFileSize(UploadType type) {
    switch (type) {
      case UploadType.video:
        return 50 * 1024 * 1024; // 50MB limit for videos
      default:
        return 10 * 1024 * 1024; // 10MB limit for images
    }
  }

  MediaType? _getMimeType(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return MediaType('image', extension);
      case 'mp4':
      case 'mov':
      case 'avi':
        return MediaType('video', extension);
      default:
        return null;
    }
  }

  String _formatUrl(String publicId, UploadType type) {
    final extension = type == UploadType.video ? '.mp4' : '.jpg';
    return '$cloudinaryBaseUrl$publicId$extension';
  }

  String _parseErrorMessage(dynamic responseData) {
    try {
      if (responseData is Map) {
        if (responseData['error'] is Map) {
          return responseData['error']['message'] ?? 'Unknown error';
        } else if (responseData['error'] is String) {
          return responseData['error'];
        }
      }
      return 'Unknown error format: $responseData';
    } catch (e) {
      return 'Error parsing response: $e';
    }
  }
}
