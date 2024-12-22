import 'package:equatable/equatable.dart';

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
    required this.eventTypes,
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