import 'dart:io';

import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';

class EventMediaUploaderImpl implements CloudinaryService {
  final CloudinaryService _cloudinaryService;

  EventMediaUploaderImpl(this._cloudinaryService);

  @override
  Future<String?> uploadFile(
    File file,
    UploadType type, {
    Function(double)? onProgress,
  }) async {
    try {
      return await _cloudinaryService.uploadFile(file, type, onProgress: onProgress);
    } catch (e) {
      Logger.error('Media upload error:', e);
      rethrow;
    }
  }

  @override
  String getFullUrl(String publicId, UploadType type) {
    return _cloudinaryService.getFullUrl(publicId, type);
  }
}
