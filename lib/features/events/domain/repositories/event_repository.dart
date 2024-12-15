import 'dart:io';

import '../../../../core/utils/cloudinary_service.dart';
import '../entities/category_entity.dart';
import '../entities/event_entity.dart';
import '../entities/host_event_entite.dart';

abstract class EventRepositoryDomain {
  Future<void> createEvent(EventEntity event);
  Future<List<HostEventEntities>> getHostEvents(String hostId);
  Future<EventEntity> getEventById(String eventId);
  Future<void> updateEvent(EventEntity event);
  Future<void> deleteEvent(String eventId);
  Future<List<CategoryEntity>> getCategories();
  Future<String?> uploadEventMedia(File file, UploadType type);
}

enum MediaType { image, video }
