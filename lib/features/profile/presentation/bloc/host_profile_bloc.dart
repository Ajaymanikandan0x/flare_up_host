import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../domain/entities/host_profile_entity.dart';
import '../../domain/usecases/get_user_profile_usecase.dart';
import '../../domain/usecases/update_user_profile_usecase.dart';
import '../../domain/usecases/upload_profile_image_usecase.dart';
import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';

part 'host_profile_event.dart';
part 'host_profile_state.dart';

class HostProfileBloc extends Bloc<HostProfileEvent, HostProfileState> {
  final GetHostProfileUseCase getHostProfile;
  final UpdateHostProfileUseCase updateHostProfile;
  final UploadProfileImageUseCase uploadProfileImage;
  final SecureStorageService storageService;

  HostProfileBloc({
    required this.getHostProfile,
    required this.updateHostProfile,
    required this.uploadProfileImage,
    required this.storageService,
  }) : super(HostProfileInitial()) {
    on<LoadHostProfile>(_onLoadHostProfile);
    on<UpdateHostProfile>(_onUpdateHostProfile);
    on<UploadProfileImage>(_onUploadProfileImage);
    on<UpdateProfileField>(_onUpdateProfileField);
  }

  Future<void> _onLoadHostProfile(
      LoadHostProfile event, Emitter<HostProfileState> emit) async {
    emit(HostProfileLoading());
    try {
      final storedUserId = await storageService.getUserId();
      
      if (storedUserId == null) {
          emit(const HostProfileError('No stored user ID found'));
        return;
      }

      if (storedUserId != event.userId) {
        emit(const HostProfileError('User ID mismatch'));
        return;
      }

      final user = await getHostProfile(event.userId);
      emit(HostProfileLoaded(user));
    } catch (e) {
      emit(HostProfileError('Failed to load user profile: $e'));
    }
  }

  Future<void> _onUpdateHostProfile(
      UpdateHostProfile event, Emitter<HostProfileState> emit) async {
    emit(HostProfileLoading());
    try {
      await updateHostProfile(event.updatedProfile, onlyProfileImage: event.onlyProfileImage);
      
      // Wait for the update to be processed
      await Future.delayed(const Duration(milliseconds: 500));
      
      final updatedUser = await getHostProfile(event.updatedProfile.id);
      emit(HostProfileLoaded(updatedUser));
    } catch (e) {
      Logger.error('Profile update failed:', e);
      emit(HostProfileError('Failed to update user profile: $e'));
    }
  }

  Future<void> _onUploadProfileImage(
      UploadProfileImage event, Emitter<HostProfileState> emit) async {
    if (state is! HostProfileLoaded) {
      emit(const ProfileImageUploadFailure('Invalid state for profile update'));
      return;
    }

    final currentUser = (state as HostProfileLoaded).user;
    emit(ProfileImageUploading());

    try {
      final imageUrl = await uploadProfileImage(event.image);
      
      if (imageUrl == null) {
        emit(const ProfileImageUploadFailure('Failed to upload image'));
        return;
      }

      final updatedUser = HostProfileEntity(
        id: currentUser.id,
        username: currentUser.username,
        fullName: currentUser.fullName,
        email: currentUser.email,
        role: currentUser.role,
        profileImage: imageUrl,
        phoneNumber: currentUser.phoneNumber,
        password: currentUser.password,
      );

      await updateHostProfile(updatedUser, onlyProfileImage: true);
      
      // Fetch updated profile
      final refreshedUser = await getHostProfile(currentUser.id);
      emit(HostProfileLoaded(refreshedUser));
      
    } catch (e) {
      Logger.error('Error in profile image upload:', e);
      emit(ProfileImageUploadFailure(e.toString()));
    }
  }

  Future<void> _onUpdateProfileField(
    UpdateProfileField event,
    Emitter<HostProfileState> emit,
  ) async {
    if (state is HostProfileLoaded) {
      final currentUser = (state as HostProfileLoaded).user;
      
      final updatedUser = HostProfileEntity(
        id: currentUser.id,
        username: event.fieldType == 'UserName' ? event.newValue : currentUser.username,
        fullName: event.fieldType == 'FullName' ? event.newValue : currentUser.fullName,
        email: event.fieldType == 'Email' ? event.newValue : currentUser.email,
        phoneNumber: event.fieldType == 'PhoneNumber' ? event.newValue : currentUser.phoneNumber,
        role: currentUser.role,
        profileImage: null,
        password: currentUser.password,
      );

      emit(HostProfileLoading());
      try {
        Logger.debug('Updating field: ${event.fieldType} with value: ${event.newValue}');
        await updateHostProfile(updatedUser, onlyProfileImage: false);
        
        // Add a small delay before fetching updated profile
        await Future.delayed(const Duration(milliseconds: 500));
        
        final refreshedUser = await getHostProfile(updatedUser.id);
        emit(HostProfileLoaded(refreshedUser));
      } catch (e) {
        Logger.error('Error updating profile field:', e);
        final errorMessage = e.toString().contains('Exception:') 
            ? e.toString().split('Exception:').last.trim()
            : 'Failed to update ${event.fieldType}';
        emit(HostProfileError(errorMessage));
      }
    }
  }
}
