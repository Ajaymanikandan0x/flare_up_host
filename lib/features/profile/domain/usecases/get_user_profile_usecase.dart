

import '../entities/host_profile_entity.dart';
import '../repositories/host_profile_repository.dart';

class GetHostProfileUseCase {
  final HostProfileRepositoryDomain repository;

  GetHostProfileUseCase(this.repository);

  Future<HostProfileEntity> call(String userId) {
    return repository.getHostProfile(userId);
  }
}
