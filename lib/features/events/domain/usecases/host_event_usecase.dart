import '../entities/host_event_entite.dart';
import '../repositories/event_repository.dart';

class GetHostEventsUseCase {
  final EventRepositoryDomain repository;

  GetHostEventsUseCase(this.repository);

  Future<List<HostEventEntities>> call(String hostId) {
    return repository.getHostEvents(hostId);
  }
}