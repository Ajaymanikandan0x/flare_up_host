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

abstract class EventState extends Equatable {
  const EventState();
  
  @override
  List<Object?> get props => [];
}

class EventMediaUploadFailure extends EventState {
  final String message;
  const EventMediaUploadFailure(this.message);
  
  @override
  List<Object?> get props => [message];
} 