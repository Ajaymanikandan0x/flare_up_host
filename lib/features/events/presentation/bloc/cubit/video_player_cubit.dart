import 'package:flutter/widgets.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

class VideoPlayerState {
  final bool isPlaying;

  final bool isInitialized;

  VideoPlayerState({
    this.isPlaying = true,
    this.isInitialized = false,
  });

  VideoPlayerState copyWith({
    bool? isPlaying,
    bool? isInitialized,
  }) {
    return VideoPlayerState(
      isPlaying: isPlaying ?? this.isPlaying,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

class VideoPlayerCubit extends Cubit<VideoPlayerState> {
  VideoPlayerController? _controller;
  bool _isClosed = false;

  VideoPlayerCubit() : super(VideoPlayerState());

  bool get isClosed => _isClosed;

  void setController(VideoPlayerController controller) {
    _controller = controller;
    // Initialize with current playing state
    emit(state.copyWith(isPlaying: controller.value.isPlaying));
  }

  void clearController() {
    _controller = null;
  }

  void setInitialized(bool initialized) {
    if (!_isClosed) {
      emit(state.copyWith(isInitialized: initialized));
    }
  }

  void togglePlayPause() {
    if (_controller == null) {
      debugPrint("Video controller is null");
      return;
    }

    try {
      if (_controller!.value.isPlaying) {
        _controller!.pause().then((_) {
          if (!_isClosed) {
            emit(state.copyWith(isPlaying: false));
          }
        }).catchError((e) {
          debugPrint("Error pausing video: $e");
        });
      } else {
        _controller!.play().then((_) {
          if (!_isClosed) {
            emit(state.copyWith(isPlaying: true));
          }
        }).catchError((e) {
          debugPrint("Error playing video: $e");
        });
      }
    } catch (e) {
      debugPrint("Error toggling play/pause: $e");
    }
  }

  @override
  Future<void> close() {
    _isClosed = true;
    return super.close();
  }
}
