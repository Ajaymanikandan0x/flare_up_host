import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:video_player/video_player.dart';

import '../../features/events/presentation/bloc/cubit/video_player_cubit.dart';

class CustomVideoWidget extends StatefulWidget {
  final String videoUrl;
  final double? width;
  final double? height;
  final Widget placeholder;
  final bool autoPlay;
  final bool looping;
  final VideoPlayerCubit? videoPlayerCubit;

  const CustomVideoWidget({
    super.key,
    required this.videoUrl,
    this.width,
    this.height,
    required this.placeholder,
    this.autoPlay = true,
    this.looping = true,
    this.videoPlayerCubit,
  });

  @override
  State<CustomVideoWidget> createState() => _CustomVideoWidgetState();
}

class _CustomVideoWidgetState extends State<CustomVideoWidget> {
  VideoPlayerController? _controller;
  VideoPlayerCubit? _externalCubit;
  bool _isInitialized = false;
  bool _hasError = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    _externalCubit = widget.videoPlayerCubit;
    _initializeVideo();
  }

  @override
  void didUpdateWidget(CustomVideoWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _disposeController();
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    if (widget.videoUrl.isEmpty) {
      debugPrint('Video URL is empty');
      return;
    }

    debugPrint('Loading video from URL: ${widget.videoUrl}');

    String videoUrl = widget.videoUrl;

    // Handle Cloudinary URLs
    if (videoUrl.contains('image/upload')) {
      videoUrl = videoUrl.replaceAll('image/upload', 'video/upload');
    }

    // Add file extension if needed
    if (!videoUrl.contains('.')) {
      videoUrl = '$videoUrl.mp4';
    } else {
      final validExtensions = [
        '.mp4',
        '.mov',
        '.avi',
        '.mkv',
        '.webm',
        '.m3u8'
      ];
      bool hasValidExtension =
          validExtensions.any((ext) => videoUrl.toLowerCase().endsWith(ext));
      if (!hasValidExtension) {
        videoUrl = '$videoUrl.mp4';
      }
    }

    try {
      final controller = VideoPlayerController.networkUrl(Uri.parse(videoUrl));
      _controller = controller;

      await controller.initialize();

      if (_isDisposed) return;

      if (widget.autoPlay) {
        await controller.play();
      }

      if (widget.looping) {
        await controller.setLooping(true);
      }

      // Only update the external cubit if provided and not closed
      if (_externalCubit != null && !_externalCubit!.isClosed) {
        _externalCubit!.setController(controller);
        _externalCubit!.setInitialized(true);
      }

      if (!_isDisposed && mounted) {
        setState(() {
          _isInitialized = true;
        });
      }
    } catch (e) {
      debugPrint('Error initializing video: $e');
      if (!_isDisposed && mounted) {
        setState(() {
          _hasError = true;
        });
      }
    }
  }

  void _disposeController() {
    if (_controller != null) {
      _controller!.pause();
      _controller!.dispose();
      _controller = null;
    }
    if (mounted && !_isDisposed) {
      setState(() {
        _isInitialized = false;
        _hasError = false;
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.pause();
      _controller!.dispose();
    }

    // Clear reference in the external cubit if it exists
    if (_externalCubit != null && !_externalCubit!.isClosed) {
      _externalCubit!.clearController();
    }

    _isDisposed = true;
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: _hasError
          ? Center(child: Text('Error loading video'))
          : !_isInitialized || _controller == null
              ? widget.placeholder
              : AspectRatio(
                  aspectRatio: _controller!.value.aspectRatio,
                  child: VideoPlayer(_controller!),
                ),
    );
  }
}
