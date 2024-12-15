import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/base_api_client.dart';
import '../../../../core/network/network_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/host_event_model.dart';
import 'event_remote_datasource.dart';

class EventRemoteDataSourceImpl extends BaseApiClient implements EventRemoteDataSource {
  final CloudinaryService _mediaUploader;

  EventRemoteDataSourceImpl(
    NetworkService networkService,
    SecureStorageService storageService,
    this._mediaUploader,
  ) : super(networkService, storageService);

  @override
  Future<ApiResponse> createEvent(EventModel event, {File? bannerImage, File? promoVideo}) async {
    try {
      final eventData = await _prepareEventData(event, bannerImage: bannerImage, promoVideo: promoVideo);
      
      return await makeRequest(
        request: () => networkService.dio.post(
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.createEvent}',
          data: eventData,
        ),
        successMessage: 'Event created successfully',
        errorMessage: 'Failed to create event',
      );
    } catch (e) {
      Logger.error('Create event error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<HostEventModel>>> getHostEvents(int hostId) async {
    try {
      final endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.hosterEvent.replaceAll('hoster_id', hostId.toString())}';

      return await makeRequest<List<HostEventModel>>(
        request: () => networkService.dio.get(endpoint),
        successMessage: 'Events fetched successfully',
        errorMessage: 'Failed to fetch events',
        transform: (data) => (data['events'] as List)
            .map((json) => HostEventModel.fromJson(json))
            .toList(),
      );
    } catch (e) {
      Logger.error('Get host events error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<EventModel>> getEventById(int eventId) async {
    try {
      final endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.singleEvent.replaceAll('event_id', eventId.toString())}';

      return await makeRequest<EventModel>(
        request: () => networkService.dio.get(endpoint),
        successMessage: 'Event fetched successfully',
        errorMessage: 'Failed to fetch event details',
        transform: (data) => EventModel.fromJson(data['event'] ?? data),
      );
    } catch (e) {
      Logger.error('Get event by ID error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse> updateEvent(int eventId, EventModel event, {File? bannerImage, File? promoVideo}) async {
    try {
      final eventData = await _prepareEventData(event, bannerImage: bannerImage, promoVideo: promoVideo);
      final endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.editEvent.replaceAll('event_id', eventId.toString())}';

      return await makeRequest(
        request: () => networkService.dio.put(endpoint, data: eventData),
        successMessage: 'Event updated successfully',
        errorMessage: 'Failed to update event',
      );
    } catch (e) {
      Logger.error('Update event error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse> eventStatus(int eventId) async {
    try {
      final endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.eventStatus.replaceAll('event_id', eventId.toString())}';

      return await makeRequest(
        request: () => networkService.dio.post(endpoint),
        successMessage: 'Event status updated successfully',
        errorMessage: 'Failed to update event status',
      );
    } catch (e) {
      Logger.error('Update event status error:', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(int eventId) async {
    try {
      final endpoint = '${ApiEndpoints.eventBaseUrl}/events/$eventId';

      await makeRequest(
        request: () => networkService.dio.delete(endpoint),
        successMessage: 'Event deleted successfully',
        errorMessage: 'Failed to delete event',
      );
    } catch (e) {
      Logger.error('Delete event error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<CategoryModel>>> getEventCategories() async {
    try {
      const endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.eventCategory}';

      return await makeRequest<List<CategoryModel>>(
        request: () => networkService.dio.get(endpoint),
        successMessage: 'Categories fetched successfully',
        errorMessage: 'Failed to fetch categories',
        transform: (data) {
          if (data is! List) {
            throw AppError(
              userMessage: 'Server returned invalid data format',
              type: ErrorType.server,
            );
          }
          return data.map((json) => CategoryModel.fromJson(json)).toList();
        },
      );
    } catch (e) {
      Logger.error('Get categories error:', e);
      rethrow;
    }
  }

  @override
  Future<String?> uploadEventMedia(File file, UploadType type) async {
    try {
      return await _mediaUploader.uploadFile(file, type);
    } catch (e) {
      Logger.error('Upload media error:', e);
      rethrow;
    }
  }

  // Private helper methods
  Future<Map<String, dynamic>> _prepareEventData(
    EventModel event, {
    File? bannerImage,
    File? promoVideo,
  }) async {
    final eventData = event.toJson();

    if (bannerImage != null) {
      eventData['banner_image'] = await _mediaUploader.uploadFile(
        bannerImage,
        UploadType.eventBanner,
      );
    }

    if (promoVideo != null) {
      eventData['promo_video'] = await _mediaUploader.uploadFile(
        promoVideo,
        UploadType.video,
      );
    }

    return eventData;
  }
}
