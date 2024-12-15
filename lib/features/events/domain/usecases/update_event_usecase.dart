import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class UpdateEventUseCase {
  final EventRepositoryDomain repository;

  UpdateEventUseCase(this.repository);

  Future<void> call(EventEntity event) {
    return repository.updateEvent(event);
  }
}