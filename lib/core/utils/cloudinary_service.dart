import 'dart:async';
import 'dart:io';
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../constants/constants.dart';
import '../error/app_error.dart';
import '../error/error_handler.dart';
import '../storage/secure_storage_service.dart';
import '../utils/logger.dart';

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

  Future<String?> uploadFile(
    File file,
    UploadType type, {
    Function(double)? onProgress,
  }) async {
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
        'file': await MultipartFile.fromFile(
          file.path,
          contentType: mimeType,
        ),
        'upload_preset': cloudinaryUploadPreset,
        'folder': _getFolderName(type),
        'resource_type': type == UploadType.video ? 'video' : 'image',
      });

      final response = await _dio.post(
        _cloudinaryUrl,
        data: formData,
        options: Options(
          headers: {'Content-Type': 'multipart/form-data'},
          receiveTimeout: const Duration(minutes: 5),
          sendTimeout: const Duration(minutes: 5),
        ),
        onSendProgress: (sent, total) {
          final progress = sent / total;
          onProgress?.call(progress);
        },
      );

      if (response.statusCode == 200) {
        final publicId = response.data['public_id'] as String?;
        if (publicId != null) {
          final url = _formatUrl(publicId, type);
          print('Generated Cloudinary URL: $url');
          return url;
        }
      }

      throw AppError(
        userMessage: 'Failed to upload file',
        technicalMessage: 'Upload failed with status: ${response.statusCode}',
        type: ErrorType.server,
      );
    } catch (e) {
      Logger.error('Upload error:', e);
      rethrow;
    }
  }

  String _getFolderName(UploadType type) {
    switch (type) {
      case UploadType.profile:
        return 'profiles';
      case UploadType.event:
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
      case 'webp':
        return MediaType('image', extension);
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
      case 'webm':
        return MediaType('video', extension);
      default:
        return null;
    }
  }

  String getFullUrl(String publicId, UploadType type) {
    final baseUrl =
        type == UploadType.video ? cloudinaryVideoUrl : cloudinaryImageUrl;
    final extension = type == UploadType.video ? '.mp4' : '';
    return '$baseUrl/${_getFolderName(type)}/$publicId$extension';
  }

  String _formatUrl(String publicId, UploadType type) {
    // Remove any existing folder prefix to prevent duplication
    final cleanPublicId = publicId.split('/').last;
    return '${_getFolderName(type)}/$cleanPublicId';
  }



}
