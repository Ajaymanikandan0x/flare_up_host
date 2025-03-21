import 'package:flare_up_host/core/utils/cloudinary_service.dart';
import 'package:flare_up_host/features/events/presentation/bloc/event_state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../core/storage/secure_storage_service.dart';
import '../../domain/repositories/event_repository.dart';
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
  })  : _categoriesUseCase = categoriesUseCase,
        super(EventInitial()) {
    on<CreateEventEvent>(_onCreateEvent);
    on<UpdateEventEvent>(_onUpdateEvent);
    on<FetchHostEventsEvent>(_onFetchHostEvents);
    on<UploadEventMediaEvent>(_onUploadEventMedia);
    on<FetchCategoriesEvent>(_onFetchCategories);
    on<SelectVideoEvent>(_onSelectVideo);
    on<SetVideoUploadingEvent>(_onSetVideoUploading);
    on<SelectImageEvent>((event, emit) {
      emit(ImageSelectionState(
        selectedImage: event.image,
        isUploading: false,
      ));
    });
    on<SetImageUploadingEvent>((event, emit) {
      if (state is ImageSelectionState) {
        final currentState = state as ImageSelectionState;
        emit(ImageSelectionState(
          selectedImage: currentState.selectedImage,
          isUploading: event.isUploading,
        ));
      }
    });
    on<UploadEventImageEvent>((event, emit) async {
      try {
        emit(EventImageUploadInProgress());
        final url = await uploadEventMediaUseCase(
          event.image!,
          MediaType.image,
        );
        emit(EventImageUploadSuccess(url!));
      } catch (e) {
        emit(EventImageUploadFailure(e.toString()));
      }
    });
    on<UploadEventVideoEvent>((event, emit) async {
      try {
        emit(EventVideoUploadInProgress());
        final url = await uploadEventMediaUseCase(
          event.video!,
          MediaType.video,
        );
        if (url != null) {
          emit(EventVideoUploadSuccess(url));
        } else {
          emit(const EventVideoUploadFailure('Failed to upload video'));
        }
      } catch (e) {
        emit(EventVideoUploadFailure(e.toString()));
      }
    });
  }

  void _onSelectVideo(SelectVideoEvent event, Emitter<EventBlocState> emit) {
    if (state is VideoSelectionState) {
      final currentState = state as VideoSelectionState;
      emit(VideoSelectionState(
        selectedVideo: event.video,
        isUploading: currentState.isUploading,
      ));
    } else {
      emit(VideoSelectionState(selectedVideo: event.video));
    }
  }

  void _onSetVideoUploading(
      SetVideoUploadingEvent event, Emitter<EventBlocState> emit) {
    if (state is VideoSelectionState) {
      final currentState = state as VideoSelectionState;
      emit(VideoSelectionState(
        selectedVideo: currentState.selectedVideo,
        isUploading: event.isUploading,
      ));
    }
  }

  Future<void> _onCreateEvent(
    CreateEventEvent event,
    Emitter<EventBlocState> emit,
  ) async {
    try {
      emit(EventLoading());

      final hosterId = await storageService.getUserId();
      if (hosterId == null) {
        emit(const EventError('User ID not found'));
        return;
      }

      // Upload video if provided
      String? videoUrl;
      if (event.promoVideo != null) {
        videoUrl = await uploadEventMediaUseCase(
          event.promoVideo!,
          MediaType.video,
        );
      }

      // Create updated event entity with video URL
      final updatedEventEntity = event.eventEntity.copyWith(
        hostId: int.parse(hosterId),
        promoVideo: videoUrl, // Use the uploaded video URL
      );

      Logger.debug('Creating event with video URL: $videoUrl');
      await createEventUseCase(updatedEventEntity);
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
      final uploadType = event.type == MediaType.image
          ? UploadType.eventBanner
          : UploadType.video;

      final url = await uploadEventMediaUseCase(
        event.file,
        event.type,
      );

      if (url != null) {
        if (event.type == MediaType.image) {
          emit(ImageSelectionState(
            selectedImage: event.file,
            isUploading: false,
            url: url,
          ));
        } else {
          emit(VideoSelectionState(
            selectedVideo: event.file,
            isUploading: false,
            uploadedUrl: url,
          ));
        }
        Logger.debug('Media upload success, URL: $url');
      } else {
        emit(const EventMediaUploadFailure('Failed to upload media'));
      }
    } catch (e) {
      Logger.error('Media upload failed:', e);
      emit(EventMediaUploadFailure(e.toString()));
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
