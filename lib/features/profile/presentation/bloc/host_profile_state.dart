part of 'host_profile_bloc.dart';

sealed class HostProfileState extends Equatable {
  const HostProfileState();

  @override
  List<Object> get props => [];
}

final class HostProfileInitial extends HostProfileState {}

final class HostProfileLoading extends HostProfileState {}

final class HostProfileLoaded extends HostProfileState {
  final HostProfileEntity user;

  const HostProfileLoaded(this.user);

  @override
  List<Object> get props => [user];
}

final class HostProfileError extends HostProfileState {
  final String message;

  const HostProfileError(this.message);

  @override
  List<Object> get props => [message];
}

class ProfileImageUploading extends HostProfileState {}

class ProfileImageUploadSuccess extends HostProfileState {
  final String imageUrl;

  const ProfileImageUploadSuccess(this.imageUrl);

  @override
  List<Object> get props => [imageUrl];
}

class ProfileImageUploadFailure extends HostProfileState {
  final String error;

  const ProfileImageUploadFailure(this.error);

  @override
  List<Object> get props => [error];
}
