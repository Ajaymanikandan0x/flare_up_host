import 'dart:io';
import '../repositories/event_repository.dart';
import '../../../../core/utils/cloudinary_service.dart';

class UploadEventMediaUseCase {
  final EventRepositoryDomain repository;

  UploadEventMediaUseCase(this.repository);

  Future<String?> call(File file, MediaType type) async {
    final uploadType =
        type == MediaType.video ? UploadType.video : UploadType.eventBanner;
    return repository.uploadEventMedia(file, uploadType);
  }
}
