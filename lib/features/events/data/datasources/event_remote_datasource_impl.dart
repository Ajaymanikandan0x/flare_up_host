import 'dart:io';
import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/base_api_client.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validation.dart';
import '../models/category_model.dart';
import '../models/event_model.dart';
import '../models/host_event_model.dart';
import 'event_remote_datasource.dart';

class EventRemoteDataSourceImpl extends BaseApiClient implements EventRemoteDataSource {
  final CloudinaryService _mediaUploader;

  EventRemoteDataSourceImpl(
    super.networkService,
    super.storageService,
    this._mediaUploader,
  );

  @override
  Future<ApiResponse> createEvent(
    EventModel event, {
    File? bannerImage,
    File? promoVideo,
  }) async {
    try {
      // Validate files first
      if (bannerImage == null) {
        throw AppError(
          userMessage: 'Banner image is required',
          type: ErrorType.validation,
        );
      }
      
      if (!await _validateMediaFiles(bannerImage, promoVideo)) {
        throw AppError(
          userMessage: 'Invalid media files',
          type: ErrorType.validation,
        );
      }

      final eventData = await _prepareEventData(
        event,
        bannerImage: bannerImage,
        promoVideo: promoVideo,
      );
      
      final options = await getRequestOptions();
      
      return await makeRequest(
        request: () => networkService.dio.post(
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.createEvent}',
          data: eventData,
          options: options,
        ),
        successMessage: 'Event created successfully',
        errorMessage: 'Failed to create event',
      );
    } catch (e) {
      Logger.error('Create event error:', e);
      rethrow;
    }
  }

  Future<bool> _validateMediaFiles(File bannerImage, File? promoVideo) async {
    // Validate banner image
    final imageValidation = await FormValidator.validateImage(bannerImage);
    if (imageValidation != null) return false;

    // Validate promo video if provided
    if (promoVideo != null) {
      final videoValidation = await FormValidator.validateVideo(promoVideo);
      if (videoValidation != null) return false;
    }

    return true;
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
      final endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.eventCategory}';
      
      final response = await networkService.dio.get(
        endpoint,
        options: await getRequestOptions(),
      );

      if (response.statusCode != 200) {
        throw AppError(
          userMessage: 'Failed to fetch categories',
          technicalMessage: 'Status: ${response.statusCode}, Data: ${response.data}',
          type: ErrorType.server,
        );
      }

      if (response.data == null || (response.data is List && response.data.isEmpty)) {
        return ApiResponse(
          success: true,
          message: 'No categories available',
          data: [],
        );
      }

      final categories = (response.data as List)
          .map((json) => CategoryModel.fromJson(json))
          .toList();
      
      return ApiResponse(
        success: true,
        message: 'Categories fetched successfully',
        data: categories,
      );
    } catch (e) {
      throw AppError(
        userMessage: 'Failed to fetch categories',
        technicalMessage: e.toString(),
        type: ErrorType.server,
      );
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
