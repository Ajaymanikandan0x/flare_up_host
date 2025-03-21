import 'dart:io';

import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/host_event_entite.dart';

abstract class EventBlocState extends Equatable {
  const EventBlocState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventBlocState {}

class EventLoading extends EventBlocState {}

class EventSuccess extends EventBlocState {}

class EventError extends EventBlocState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesLoaded extends EventBlocState {
  final List<CategoryEntity> categories;
  final List<String> eventTypes;

  const CategoriesLoaded({
    required this.categories,
    this.eventTypes = const [],
  });

  @override
  List<Object?> get props => [categories, eventTypes];
}

class EventMediaUploading extends EventBlocState {}

class EventMediaUploadSuccess extends EventBlocState {
  final String url;

  const EventMediaUploadSuccess(this.url);

  @override
  List<Object?> get props => [url];
}

class HostEventsLoaded extends EventBlocState {
  final List<HostEventEntities> events;

  const HostEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
}

class EventImageUploadInProgress extends EventBlocState {}

class EventImageUploadSuccess extends EventBlocState {
  final String url;
  const EventImageUploadSuccess(this.url);

  @override
  List<Object> get props => [url];
}

class EventImageUploadFailure extends EventBlocState {
  final String error;
  EventImageUploadFailure(this.error);

  @override
  List<Object?> get props => [error];
}

class EventVideoUploadSuccess extends EventBlocState {
  final String url;
  const EventVideoUploadSuccess(this.url);

  @override
  List<Object> get props => [url];
}

class EventVideoUploadFailure extends EventBlocState {
  final String message;
  const EventVideoUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EventVideoUploadInProgress extends EventBlocState {
  final double? progress;

  const EventVideoUploadInProgress({this.progress});

  @override
  List<Object?> get props => [progress];
}

class VideoSelectionState extends EventBlocState {
  final File? selectedVideo;
  final bool isUploading;
  final String? uploadedUrl;

  const VideoSelectionState({
    this.selectedVideo,
    this.isUploading = false,
    this.uploadedUrl,
  });

  @override
  List<Object?> get props => [selectedVideo, isUploading, uploadedUrl];
}

class EventMediaUploadFailure extends EventBlocState {
  final String message;

  const EventMediaUploadFailure(this.message);

  @override
  List<Object?> get props => [message];
}

class EventMediaUploadProgress extends EventBlocState {
  final double progress;

  const EventMediaUploadProgress(this.progress);
}

class ImageSelectionState extends EventBlocState {
  final File? selectedImage;
  final bool isUploading;
  final String? url;

  const ImageSelectionState({
    this.selectedImage,
    this.isUploading = false,
    this.url,
  });

  @override
  List<Object?> get props => [selectedImage, isUploading, url];
}

class CategorySelected extends EventBlocState {
  final String categoryName;
  final List<String> eventTypes;
  final List<CategoryEntity> categories;
  final String? selectedType;
  final TextEditingController categoryController;
  final TextEditingController typeController;

  const CategorySelected({
    required this.categoryName,
    required this.eventTypes,
    required this.categories,
    this.selectedType,
    required this.categoryController,
    required this.typeController,
  });

  @override
  List<Object?> get props => [
        categoryName,
        eventTypes,
        categories,
        selectedType,
        categoryController,
        typeController
      ];
}

class TypeSelected extends EventBlocState {
  final String typeName;

  const TypeSelected(this.typeName);

  @override
  List<Object?> get props => [typeName];
}

class DateSelectionState extends EventBlocState {
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? registrationDeadline;
  final String dateType;

  const DateSelectionState({
    this.startDate,
    this.endDate,
    this.registrationDeadline,
    required this.dateType,
  });

  @override
  List<Object?> get props =>
      [startDate, endDate, registrationDeadline, dateType];
}

class EventCleanupState extends EventBlocState {
  @override
  List<Object?> get props => [];
}

class EditEventStepState extends EventBlocState {
  final int currentStep;

  const EditEventStepState(this.currentStep);

  @override
  List<Object> get props => [currentStep];
}

class PaymentRequiredState extends EventBlocState {
  final bool isRequired;

  const PaymentRequiredState(this.isRequired);

  @override
  List<Object> get props => [isRequired];
}
