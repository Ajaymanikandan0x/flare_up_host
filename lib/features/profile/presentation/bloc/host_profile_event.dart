part of 'host_profile_bloc.dart';

sealed class HostProfileEvent extends Equatable {
  const HostProfileEvent();
  @override
  List<Object> get props => [];
}

class LoadHostProfile extends HostProfileEvent {
  final String userId;

  const LoadHostProfile(this.userId);

  @override
  List<Object> get props => [userId];
}

class UpdateHostProfile extends HostProfileEvent {
  final HostProfileEntity updatedProfile;
  final bool onlyProfileImage;

  const UpdateHostProfile(this.updatedProfile, {this.onlyProfileImage = false});

  @override
  List<Object> get props => [updatedProfile, onlyProfileImage];

  @override
  String toString() => 'UpdateUserProfile { updatedProfile: $updatedProfile, onlyProfileImage: $onlyProfileImage }';
}

class UpdateProfileField extends HostProfileEvent {
  final String fieldType;
  final String newValue;

  const UpdateProfileField({
    required this.fieldType,
    required this.newValue,
  });

  @override
  List<Object> get props => [fieldType, newValue];
}

class UploadProfileImage extends HostProfileEvent {
  final File image;

  const UploadProfileImage(this.image);

  @override
  List<Object> get props => [image];
}
