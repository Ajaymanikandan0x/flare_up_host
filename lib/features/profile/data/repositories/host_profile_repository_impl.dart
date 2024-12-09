

import '../../domain/entities/host_profile_entity.dart';
import '../../domain/repositories/host_profile_repository.dart';
import '../datasources/host_profile_remote_datasource.dart';
import '../models/host_profile_model.dart';

class HostProfileRepositoryImpl implements HostProfileRepositoryDomain {
  final HostProfileRemoteDataSourceImpl remoteDatasource;

  HostProfileRepositoryImpl(this.remoteDatasource);

  @override
  Future<HostProfileEntity> getHostProfile(String userId) async {
    final model = await remoteDatasource.fetchHostProfile(userId);
    return model.toEntity();
  }

  @override
  Future<void> updateHostProfile(HostProfileEntity userProfile, {bool onlyProfileImage = false}) async {
    final model = HostProfileModel(
      id: int.parse(userProfile.id),
      profileImage: userProfile.profileImage,
      username: userProfile.username,
      email: userProfile.email,
      role: userProfile.role,
      fullName: userProfile.fullName,
      phoneNumber: userProfile.phoneNumber,
    );
    await remoteDatasource.updateHostProfile(model, onlyProfileImage: onlyProfileImage);
  }
}
