
import '../entities/host_profile_entity.dart';
import '../repositories/host_profile_repository.dart';

class UpdateHostProfileUseCase {
  final HostProfileRepositoryDomain repository;

  UpdateHostProfileUseCase(this.repository);

  Future<void> call(HostProfileEntity userProfile, {bool onlyProfileImage = false}) {
    return repository.updateHostProfile(userProfile, onlyProfileImage: onlyProfileImage);
  }
}
