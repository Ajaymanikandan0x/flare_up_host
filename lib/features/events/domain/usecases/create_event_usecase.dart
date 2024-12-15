import '../entities/event_entity.dart';
import '../repositories/event_repository.dart';

class CreateEventUseCase {
  final EventRepositoryDomain repository;

  CreateEventUseCase(this.repository);

  Future<void> call(EventEntity event) {
    return repository.createEvent(event);
  }
}
