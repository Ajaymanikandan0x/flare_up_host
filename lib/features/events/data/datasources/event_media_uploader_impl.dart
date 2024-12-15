import 'dart:io';

import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
    
class EventMediaUploaderImpl implements CloudinaryService {
  final CloudinaryService _cloudinaryService;

  EventMediaUploaderImpl(this._cloudinaryService);

  @override
  Future<String?> uploadFile(File file, UploadType type) async {
    try {
      return await _cloudinaryService.uploadFile(file, type);
    } catch (e) {
      Logger.error('Media upload error:', e);
      rethrow;
    }
  }
  
  @override
  Future<String?> uploadVideo(File videoFile) {
    return _cloudinaryService.uploadVideo(videoFile);
  }
} 