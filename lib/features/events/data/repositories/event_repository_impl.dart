import 'dart:io';

import '../../../../core/error/app_error.dart';
import '../../../../core/network/api_response.dart';
import '../../../../core/utils/cloudinary_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/entities/category_entity.dart';
import '../../domain/entities/event_entity.dart';
import '../../domain/entities/host_event_entite.dart';
import '../../domain/repositories/event_repository.dart';
import '../datasources/event_remote_datasource.dart';
import '../models/event_model.dart';
import '../models/host_event_model.dart';

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
        hostId: event.hostId
    );
    await _remoteDataSource.createEvent(eventModel);
  }

  @override
  Future<List<HostEventEntities>> getHostEvents(String hostId) async {
    final ApiResponse<List<HostEventModel>> response =
        await _remoteDataSource.getHostEvents(int.parse(hostId));
    return response.data!.map((model) => model.toEntity()).toList();
  }

  @override
  Future<EventEntity> getEventById(String eventId) async {
    try {
        final response = await _remoteDataSource.getEventById(int.parse(eventId));
        if (response.data == null) {
            throw AppError(
                userMessage: 'Event not found',
                type: ErrorType.businessLogic
            );
        }
        return response.data!.toEntity();
    } catch (e) {
        Logger.error('Get event by ID error', e);
        rethrow;
    }
  }

  @override
  Future<void> updateEvent(EventEntity event) async {
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
        hostId: event.hostId
    );
    await _remoteDataSource.updateEvent(event.hostId, eventModel);
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
    return response.data!.map((model) => model.toEntity()).toList();
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
}
