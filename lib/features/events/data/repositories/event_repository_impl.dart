import 'dart:io';

import '../../../../core/error/app_error.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/host_event_entite.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';

class EventRepositoryImpl implements EventRepositoryDomain {
  final EventRemoteDataSource _remoteDataSource;

  EventRepositoryImpl(this._remoteDataSource);

  @override
  Future<void> createEvent(EventEntity event) async {
    final eventModel = EventModel(
        name: event.name,
        description: event.description,
        category: event.category,
        type: event.type,
        isPaymentRequired: event.isPaymentRequired,
        ticketPrice: event.ticketPrice,
        latitude: event.latitude,
        longitude: event.longitude,
        addressLine1: event.addressLine1,
        city: event.city,
        state: event.state,
        country: event.country,
        participantCapacity: event.participantCapacity,
        startDateTime: event.startDateTime,
        endDateTime: event.endDateTime,
        registrationDeadline: event.registrationDeadline,
        bannerImage: event.bannerImage,
        promoVideo: event.promoVideo,
        hostId: event.hostId);
    await _remoteDataSource.createEvent(eventModel);
  }

  @override
  Future<EventEntity> getEventById(String eventId) async {
    try {
      final response = await _remoteDataSource.getEventById(int.parse(eventId));
      if (response.data == null) {
        throw AppError(
            userMessage: 'Event not found', type: ErrorType.businessLogic);
      }
      return response.data!.toEntity();
    } catch (e) {
      Logger.error('Get event by ID error', e);
      rethrow;
    }
  }

  @override
  Future<void> updateEvent(int eventId, EventEntity event,
      {File? bannerImage, File? promoVideo}) async {
    try {
      Logger.debug('🔄 Starting event update in repository');
      Logger.debug('📝 Host ID: ${event.hostId}');
      Logger.debug('📝 Event name: ${event.name}');
      Logger.debug('📝 Event category: ${event.category}');
      Logger.debug(
          '📝 Event dates: ${event.startDateTime} to ${event.endDateTime}');

      final eventModel = EventModel(
          name: event.name,
          description: event.description,
          category: event.category,
          type: event.type,
          isPaymentRequired: event.isPaymentRequired,
          ticketPrice: event.ticketPrice,
          latitude: event.latitude,
          longitude: event.longitude,
          addressLine1: event.addressLine1,
          city: event.city,
          state: event.state,
          country: event.country,
          participantCapacity: event.participantCapacity,
          startDateTime: event.startDateTime,
          endDateTime: event.endDateTime,
          registrationDeadline: event.registrationDeadline,
          bannerImage: event.bannerImage,
          promoVideo: event.promoVideo,
          hostId: event.hostId);

      Logger.debug('🖼️ Banner image file included: ${bannerImage != null}');
      Logger.debug('🎬 Promo video file included: ${promoVideo != null}');

      final response = await _remoteDataSource.updateEvent(eventId, eventModel,
          bannerImage: bannerImage, promoVideo: promoVideo);

      Logger.debug('✅ Remote data source call completed successfully');
      Logger.debug('📊 Response status: ${response.data}');
      Logger.debug('📊 Response message: ${response.message}');
    } catch (e) {
      Logger.error('❌ Error updating event:', e);
      Logger.debug('❌ Error details: ${e.toString()}');
      rethrow;
    }
  }

  @override
  Future<void> deleteEvent(String eventId) async {
    try {
      await _remoteDataSource.deleteEvent(int.parse(eventId));
    } catch (e) {
      Logger.error('Delete event error', e);
      rethrow;
    }
  }

  @override
  Future<List<CategoryEntity>> getCategories() async {
    final response = await _remoteDataSource.getEventCategories();
    return response.data?.map((model) => model.toEntity()).toList() ?? [];
  }

  @override
  Future<String?> uploadEventMedia(File file, UploadType type) async {
    try {
      return await _remoteDataSource.uploadEventMedia(file, type);
    } catch (e) {
      Logger.error('Upload event media error:', e);
      rethrow;
    }
  }

  @override
  Future<List<HostEventEntities>> getHostEvents(String hostId) async {
    try {
      Logger.debug('Getting host events for hostId: $hostId');

      final parsedId = int.tryParse(hostId);
      if (parsedId == null) {
        throw AppError(
          userMessage: 'Invalid host ID format',
          type: ErrorType.validation,
        );
      }

      final response = await _remoteDataSource.getHostEvents(parsedId);

      if (response.data == null) {
        return [];
      }

      final events = response.data!.map((model) => model.toEntity()).toList();

      Logger.debug('Returning ${events.length} events');
      return events;
    } catch (e) {
      Logger.error('Get host events error:', e);
      rethrow;
    }
  }
}
