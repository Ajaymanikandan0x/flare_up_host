import 'package:equatable/equatable.dart';

import '../../domain/entities/category_entity.dart';
import '../../domain/entities/host_event_entite.dart';

abstract class EventState extends Equatable {
  const EventState();

  @override
  List<Object?> get props => [];
}

class EventInitial extends EventState {}

class EventLoading extends EventState {}

class EventSuccess extends EventState {}

class EventError extends EventState {
  final String message;

  const EventError(this.message);

  @override
  List<Object?> get props => [message];
}

class CategoriesLoaded extends EventState {
  final List<CategoryEntity> categories;
  final List<String> eventTypes;

  const CategoriesLoaded({
    required this.categories,
    required this.eventTypes,
  });

  @override
  List<Object?> get props => [categories, eventTypes];
}

class EventMediaUploading extends EventState {}

class EventMediaUploadSuccess extends EventState {
  final String url;

  const EventMediaUploadSuccess(this.url);

  @override
  List<Object?> get props => [url];
}

class HostEventsLoaded extends EventState {
  final List<HostEventEntities> events;

  const HostEventsLoaded(this.events);

  @override
  List<Object?> get props => [events];
} 