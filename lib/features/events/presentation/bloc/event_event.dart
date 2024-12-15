import 'package:equatable/equatable.dart';
import 'dart:io';

import '../../domain/entities/event_entity.dart';
import '../../domain/repositories/event_repository.dart';

abstract class EventEvent extends Equatable {
  const EventEvent();

  @override
  List<Object?> get props => [];
}

class CreateEventEvent extends EventEvent {
  final EventEntity eventEntity;

  const CreateEventEvent(this.eventEntity);

  @override
  List<Object?> get props => [eventEntity];
}

class UpdateEventEvent extends EventEvent {
  final EventEntity eventEntity;
  final int eventId;

  const UpdateEventEvent({
    required this.eventEntity,
    required this.eventId,
  });

  @override
  List<Object?> get props => [eventEntity, eventId];
}

class FetchHostEventsEvent extends EventEvent {
  final String hostId;

  const FetchHostEventsEvent(this.hostId);

  @override
  List<Object?> get props => [hostId];
}

class UploadEventMediaEvent extends EventEvent {
  final File file;
  final MediaType type;

  const UploadEventMediaEvent(this.file, this.type);

  @override
  List<Object?> get props => [file, type];
}

class FetchCategoriesEvent extends EventEvent {} 