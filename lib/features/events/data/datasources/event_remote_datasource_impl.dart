import 'dart:io';

import 'package:dio/dio.dart';
import 'package:flare_up_host/features/events/data/models/event_model.dart';

import '../../../../core/constants/api_constants.dart';
import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/network/network_service.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
import '../models/category_model.dart';
import '../models/host_event_model.dart';
import 'event_remote_datasource.dart';

class EventRemoteDataSourceImpl implements EventRemoteDataSource {
  final NetworkService _networkService;
  final SecureStorageService _storageService;
  final Dio _dio;
  final CloudinaryService _mediaUploader;

  EventRemoteDataSourceImpl(
    this._networkService,
    this._storageService,
    this._mediaUploader,
  ) : _dio = _networkService.dio {
    _dio.options.headers['Content-Type'] = 'application/json';
  }

  Future<Options> _getRequestOptions() async {
    final token = await _storageService.getAccessToken();
    return Options(
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Bearer $token',
      },
      validateStatus: (status) => status! < 500,
      responseType: ResponseType.json,
    );
  }

  @override
  Future<ApiResponse> createEvent(EventModel event,
      {File? bannerImage, File? promoVideo}) async {
    try {
      await _storageService.getAccessToken();
      final eventData = event.toJson();

      if (bannerImage != null) {
        eventData['banner_image'] = await _mediaUploader.uploadFile(
            bannerImage, UploadType.eventBanner);
      }

      if (promoVideo != null) {
        eventData['promo_video'] =
            await _mediaUploader.uploadFile(promoVideo, UploadType.video);
      }

      return await _makeRequest(
        request: () => _dio.post(
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

  // Helper method to standardize request handling
  Future<ApiResponse<T>> _makeRequest<T>({
    required Future<Response> Function() request,
    required String successMessage,
    required String errorMessage,
    T Function(dynamic)? transform,
  }) async {
    try {
      final response = await request();
      Logger.debug('Response status code: ${response.statusCode}');
      Logger.debug('Response data type: ${response.data.runtimeType}');
      Logger.debug('Response data: ${response.data}');

      if (response.statusCode == 200 || response.statusCode == 201) {
        try {
          final data = transform != null ? transform(response.data) : response.data;
          final message = response.data is Map ? 
              response.data['message'] ?? successMessage : 
              successMessage;
              
          return ApiResponse<T>(
            success: true,
            message: message,
            data: data,
          );
        } catch (e) {
          Logger.error('Transform error:', e);
          throw AppError(
            userMessage: 'Error processing server response',
            technicalMessage: e.toString(),
            type: ErrorType.server,
          );
        }
      }

      throw AppError(
        userMessage: errorMessage,
        technicalMessage: 'Status: ${response.statusCode}, Data: ${response.data}',
        type: ErrorType.server,
      );
    } on DioException catch (e) {
      Logger.error('API request error:', e);
      Logger.error('Response data:', e.response?.data);
      throw AppError(
        userMessage: 'Failed to connect to server',
        technicalMessage: e.toString(),
        type: ErrorType.network,
      );
    } catch (e) {
      Logger.error('API request error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<HostEventModel>>> getHostEvents(int hostId) async {
    try {
      await _storageService.getAccessToken();
      final endpoint =
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.hosterEvent.replaceAll('hoster_id', hostId.toString())}';

      return await _makeRequest<List<HostEventModel>>(
        request: () => _dio.get(endpoint),
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
  Future<ApiResponse> eventStatus(int eventId) async {
    try {
      await _storageService.getAccessToken();
      final endpoint =
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.eventStatus.replaceAll('event_id', eventId.toString())}';

      return await _makeRequest(
        request: () => _dio.post(endpoint),
        successMessage: 'Event status updated successfully',
        errorMessage: 'Failed to update event status',
      );
    } catch (e) {
      Logger.error('Update event status error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<EventModel>> getEventById(int hostId) async {
    try {
      await _storageService.getAccessToken();
      final endpoint =
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.hosterEvent.replaceAll('hoster_id', hostId.toString())}';

      return await _makeRequest<EventModel>(
        request: () => _dio.get(endpoint),
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
  Future<ApiResponse> updateEvent(int eventId, EventModel event,
      {File? bannerImage, File? promoVideo}) async {
    try {
      await _storageService.getAccessToken();
      final eventData = event.toJson();
      final endpoint =
          '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.editEvent.replaceAll('event_id', eventId.toString())}';

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

      return await _makeRequest(
        request: () => _dio.put(endpoint, data: eventData),
        successMessage: 'Event updated successfully',
        errorMessage: 'Failed to update event',
      );
    } catch (e) {
      Logger.error('Update event error:', e);
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(int eventId) async {
    try {
      await _storageService.getAccessToken();
      final endpoint = '${ApiEndpoints.eventBaseUrl}/events/$eventId';

      await _makeRequest(
        request: () => _dio.delete(endpoint),
        successMessage: 'Event deleted successfully',
        errorMessage: 'Failed to delete event',
      );
    } catch (e) {
      Logger.error('Delete event error:', e);
      rethrow;
    }
  }

  @override
  Future<String?> uploadEventMedia(File file, UploadType type) async {
    try {
      await _storageService.getAccessToken();
      final formData = FormData.fromMap({
        'file': await MultipartFile.fromFile(file.path),
        'type': type.toString(),
      });

      final response = await _dio.post('${ApiEndpoints.eventBaseUrl}/upload',
          data: formData);

      if (response.statusCode == 200) {
        return response.data['url'];
      } else {
        throw AppError(
          userMessage: 'Failed to upload media',
          technicalMessage:
              'Status: ${response.statusCode}, Data: ${response.data}',
          type: ErrorType.server,
        );
      }
    } catch (e) {
      Logger.error('Upload media error:', e);
      rethrow;
    }
  }

  @override
  Future<ApiResponse<List<CategoryModel>>> getEventCategories() async {
    try {
      const endpoint = '${ApiEndpoints.eventBaseUrl}${ApiEndpoints.eventCategory}';
      Logger.debug('Fetching categories from: $endpoint');
      
      final options = await _getRequestOptions();
      
      return await _makeRequest<List<CategoryModel>>(
        request: () => _dio.get(
          endpoint,
          options: options,
        ),
        successMessage: 'Categories fetched successfully',
        errorMessage: 'Failed to fetch categories',
        transform: (data) {
          if (data is! List) {
            Logger.error('Invalid response format:', data);
            throw AppError(
              userMessage: 'Server returned invalid data format',
              technicalMessage: 'Expected List, got ${data.runtimeType}',
              type: ErrorType.server,
            );
          }
          
          // Handle empty list case
          if (data.isEmpty) {
            Logger.debug('Server returned empty categories list');
            return <CategoryModel>[];
          }
          
          try {
            return data.map((json) {
              Logger.debug('Processing category JSON: $json');
              return CategoryModel.fromJson(json);
            }).toList();
          } catch (e, stackTrace) {
            Logger.error('Error parsing category:', e);
            Logger.error('Category parse stack trace:', stackTrace);
            throw AppError(
              userMessage: 'Error processing category data',
              technicalMessage: 'Parse error: $e',
              type: ErrorType.server,
            );
          }
        },
      );
    } catch (e) {
      Logger.error('Get categories error:', e);
      rethrow;
    }
  }
}
