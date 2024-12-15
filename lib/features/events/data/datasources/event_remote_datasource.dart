import 'dart:io';

import '../../../../core/network/api_response.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/host_event_model.dart';

abstract class EventRemoteDataSource {
  Future<ApiResponse> createEvent(EventModel event, {File? bannerImage, File? promoVideo});
  Future<ApiResponse<List<HostEventModel>>> getHostEvents(int hostId);
  Future<ApiResponse<EventModel>> getEventById(int eventId);
  Future<ApiResponse> updateEvent(int eventId, EventModel event, {File? bannerImage, File? promoVideo});
  Future<ApiResponse> eventStatus(int eventId);
  Future<ApiResponse<List<CategoryModel>>> getEventCategories();
  Future<void> deleteEvent(int eventId);
  Future<String?> uploadEventMedia(File file, UploadType type);
} 