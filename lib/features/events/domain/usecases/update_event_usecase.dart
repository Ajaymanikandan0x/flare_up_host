import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';
import 'dart:io';

class UpdateEventUseCase {
  final EventRepositoryDomain repository;

  UpdateEventUseCase(this.repository);

  Future<void> call(EventEntity event, {File? bannerImage, File? promoVideo}) {
    // Parse the string ID to int before passing to repository
    final eventId = int.parse(event.id.toString());
    return repository.updateEvent(eventId, event,
        bannerImage: bannerImage, promoVideo: promoVideo);
  }
}
