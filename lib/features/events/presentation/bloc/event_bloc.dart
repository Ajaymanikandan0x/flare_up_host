import 'package:flare_up_host/features/events/presentation/bloc/event_event.dart';
import 'package:flare_up_host/features/events/presentation/bloc/event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../../../core/utils/logger.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../../domain/usecases/host_event_usecase.dart';
import '../../domain/usecases/update_event_usecase.dart';
import '../../domain/usecases/upload_event_media_usecase.dart';
import '../../domain/usecases/category_usecase.dart';

class EventBloc extends Bloc<EventEvent, EventState> {
  final CreateEventUseCase createEventUseCase;
  final UpdateEventUseCase updateEventUseCase;
  final GetHostEventsUseCase getHostEventsUseCase;
  final UploadEventMediaUseCase uploadEventMediaUseCase;
  final SecureStorageService storageService;
  final CategoriesUseCase _categoriesUseCase;

  EventBloc({
    required this.createEventUseCase,
    required this.updateEventUseCase,
    required this.getHostEventsUseCase,
    required this.uploadEventMediaUseCase,
    required this.storageService,
    required CategoriesUseCase categoriesUseCase,
  }) : _categoriesUseCase = categoriesUseCase,
       super(EventInitial()) {
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<FetchHostEventsEvent>(_onFetchHostEvents);
    on<UploadEventMediaEvent>(_onUploadEventMedia);
    on<FetchCategoriesEvent>(_onFetchCategories);
  }

  Future<void> _onCreateEvent(
    CreateEventEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      await createEventUseCase(event.eventEntity);
      emit(EventSuccess());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      await updateEventUseCase(event.eventEntity);
      emit(EventSuccess());
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onFetchHostEvents(
    FetchHostEventsEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      final events = await getHostEventsUseCase(event.hostId);
      emit(HostEventsLoaded(events));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUploadEventMedia(
    UploadEventMediaEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventMediaUploading());
      final url = await uploadEventMediaUseCase(event.file, event.type);
      if (url != null) {
        emit(EventMediaUploadSuccess(url));
      } else {
        emit(const EventError('Failed to upload media'));
      }
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onFetchCategories(
    FetchCategoriesEvent event,
    Emitter<EventState> emit,
  ) async {
    try {
      emit(EventLoading());
      final categories = await _categoriesUseCase();
      
      final eventTypes = categories.isEmpty 
          ? <String>[] 
          : categories
              .expand((category) => category.eventTypes)
              .map((type) => type.name)
              .toSet()
              .toList();
      
      emit(CategoriesLoaded(
        categories: categories,
        eventTypes: eventTypes,
      ));
    } catch (e) {
      Logger.error('Error loading categories:', e);
      emit(EventError(e.toString()));
    }
  }
}
