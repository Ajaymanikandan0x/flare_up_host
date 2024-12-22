import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/usecases/create_event_usecase.dart';
import '../../domain/usecases/host_event_usecase.dart';
import '../../domain/usecases/update_event_usecase.dart';
import '../../domain/usecases/upload_event_media_usecase.dart';
import '../../domain/usecases/category_usecase.dart';
import 'event_event.dart';
import 'event_state.dart';
import '../../../../core/utils/logger.dart';


class EventBloc extends Bloc<EventBlocEvent, EventBlocState> {
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
    Emitter<EventBlocState> emit,
  ) async {
    try {
      emit(EventLoading());
      
      Logger.debug('Starting event creation');
      Logger.debug('Event entity: ${event.eventEntity.toDebugString()}');
      Logger.debug('Banner image file: ${event.bannerImage?.path}');
      Logger.debug('Banner image URL: ${event.eventEntity.bannerImage}');
      
      final hosterId = await storageService.getUserId();
      Logger.debug('Retrieved hosterId: $hosterId');
      
      if (hosterId == null) {
        Logger.debug('Host ID not found');
        emit(const EventError('User ID not found'));
        return;
      }
      
      if (event.bannerImage == null && event.eventEntity.bannerImage == null) {
        Logger.debug('No banner image provided');
        emit(const EventError('Banner image is required'));
        return;
      }
      
      await createEventUseCase(event.eventEntity);
      Logger.debug('Event created successfully');
      emit(EventSuccess());
    } catch (e) {
      Logger.error('Event creation failed', e);
      emit(EventError(e.toString()));
    }
  }

  Future<void> _onUpdateEvent(
    UpdateEventEvent event,
    Emitter<EventBlocState> emit,
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
    Emitter<EventBlocState> emit,
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
    Emitter<EventBlocState> emit,
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
    Emitter<EventBlocState> emit,
  ) async {
    try {
      emit(EventLoading());
      final categories = await _categoriesUseCase();
      
      if (categories.isEmpty) {
        emit(const CategoriesLoaded(categories: []));
        return;
      }
      
      emit(CategoriesLoaded(categories: categories));
    } catch (e) {
      emit(EventError(e.toString()));
    }
  }
}
