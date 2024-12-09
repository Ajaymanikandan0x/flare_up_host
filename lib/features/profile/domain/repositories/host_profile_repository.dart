import '../entities/host_profile_entity.dart';

abstract class HostProfileRepositoryDomain {
  Future<HostProfileEntity> getHostProfile(String userId);
  Future<void> updateHostProfile(HostProfileEntity userProfile, {bool onlyProfileImage = false});
} 