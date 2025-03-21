import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

abstract class EventBlocEvent extends Equatable {
  const EventBlocEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventEvent extends EventBlocEvent {
  final EventEntity eventEntity;
  final File bannerImage;
  final File? promoVideo;

  const CreateEventEvent(this.eventEntity, this.bannerImage, this.promoVideo);

  @override
  List<Object?> get props => [eventEntity, bannerImage, promoVideo];
}

class UpdateEventEvent extends EventBlocEvent {
  final EventEntity eventEntity;
  final int eventId;

  const UpdateEventEvent({
    required this.eventEntity,
    required this.eventId,
  });

  @override
  List<Object?> get props => [eventEntity, eventId];
}

class FetchHostEventsEvent extends EventBlocEvent {
  final String hostId;

  const FetchHostEventsEvent(this.hostId);

  @override
  List<Object?> get props => [hostId];
}

class UploadEventMediaEvent extends EventBlocEvent {
  final File file;
  final MediaType type;

  const UploadEventMediaEvent({
    required this.file,
    required this.type,
  });

  @override
  List<Object?> get props => [file, type];
}

class FetchCategoriesEvent extends EventBlocEvent {}

class SelectVideoEvent extends EventBlocEvent {
  final File? video;

  const SelectVideoEvent(this.video);

  @override
  List<Object?> get props => [video];
}

class SetVideoUploadingEvent extends EventBlocEvent {
  final bool isUploading;

  const SetVideoUploadingEvent(this.isUploading);

  @override
  List<Object?> get props => [isUploading];
}

class UploadEventImageEvent extends EventBlocEvent {
  final File? image;
  UploadEventImageEvent(this.image);
}

class SelectImageEvent extends EventBlocEvent {
  final File? image;
  const SelectImageEvent(this.image);
}

class SetImageUploadingEvent extends EventBlocEvent {
  final bool isUploading;

  const SetImageUploadingEvent(this.isUploading);

  @override
  List<Object?> get props => [isUploading];
}

class UploadEventVideoEvent extends EventBlocEvent {
  final File? video;

  const UploadEventVideoEvent(this.video);

  @override
  List<Object?> get props => [video];
}

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}
