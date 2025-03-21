import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

import '../constants/constants.dart';
import '../storage/secure_storage_service.dart';
import '../utils/validation.dart';
import '../utils/cloudinary_service.dart';
import '../utils/logger.dart';

class VideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final bool isFile;
  final Function(String)? onUploadComplete;
  final bool autoPlay;
  final bool handleUpload;

  const VideoPlayer({
    super.key,
    this.videoUrl,
    this.videoFile,
    this.isFile = false,
    this.onUploadComplete,
    this.autoPlay = false,
    this.handleUpload = false,
  }) : assert(
          (isFile && videoFile != null) || (!isFile && videoUrl != null),
          'Must provide either videoUrl or videoFile based on isFile flag',
        );

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  FlickManager? flickManager;
  bool hasError = false;
  bool isInitialized = false;
  String? errorMessage;
  bool isUploading = false;
  double? uploadProgress;

  @override
  void initState() {
    super.initState();
    _validateAndInitialize();
  }

  @override
  void dispose() {
    flickManager?.dispose();
    super.dispose();
  }

  Future<void> _validateAndInitialize() async {
    try {
      Logger.debug('Starting video initialization...');
      if (widget.isFile) {
        Logger.debug('Validating video file: ${widget.videoFile!.path}');
        if (!FormValidator.isValidVideoFormat(widget.videoFile!.path)) {
          throw Exception(
              'Unsupported video format. Please use MP4, MOV, or AVI.');
        }

        Logger.debug('Starting video player initialization');
        final videoPlayerController =
            VideoPlayerController.file(widget.videoFile!);

        try {
          await videoPlayerController.initialize();
          Logger.debug('Video controller initialized successfully');
        } catch (e) {
          Logger.error('Failed to initialize video controller:', e);
          throw e;
        }

        if (mounted) {
          setState(() {
            flickManager = FlickManager(
              videoPlayerController: videoPlayerController,
              autoPlay: false,
            );
            isInitialized = true;
          });
          Logger.debug('FlickManager initialized successfully');
        }

        // Only notify completion, don't handle upload
        if (widget.onUploadComplete != null) {
          widget.onUploadComplete!(widget.videoFile!.path);
        }
      } else {
        // Handle network video
        final videoPlayerController = VideoPlayerController.networkUrl(
          Uri.parse(_formatCloudinaryUrl(widget.videoUrl!)),
        );
        await videoPlayerController.initialize();

        if (mounted) {
          setState(() {
            flickManager = FlickManager(
              videoPlayerController: videoPlayerController,
              autoPlay: widget.autoPlay,
            );
            isInitialized = true;
          });
        }
      }
    } catch (e) {
      Logger.error('Video player initialization error:', e);
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = e.toString();
        });
      }
    }
  }

  Future<String?> _uploadToCloudinary() async {
    try {
      final cloudinaryService = CloudinaryService(SecureStorageService());
      return await cloudinaryService.uploadFile(
        widget.videoFile!,
        UploadType.video,
        onProgress: (progress) {
          if (mounted) {
            setState(() => uploadProgress = progress);
          }
        },
      );
    } catch (e) {
      if (mounted) {
        setState(() {
          hasError = true;
          errorMessage = 'Failed to upload video: ${e.toString()}';
        });
      }
      return null;
    }
  }

  String _formatCloudinaryUrl(String url) {
    if (!url.startsWith('http')) {
      final videoId = url.split('/').last;
      final formattedUrl =
          '$cloudinaryVideoUrl/event_promo_videos/$videoId.mp4';
      print('Video og_-------______-____----_ URL: $url');
      print('Formatted video URL: $formattedUrl');
      return formattedUrl;
    }
    return url;
  }

  @override
  Widget build(BuildContext context) {
    if (hasError) {
      Logger.error('Video player error:', errorMessage);
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.error_outline, color: Colors.red, size: 48),
              const SizedBox(height: 16),
              Text(
                errorMessage ?? 'Failed to load video',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ],
          ),
        ),
      );
    }

    if (isUploading) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(
              value: uploadProgress,
            ),
            const SizedBox(height: 16),
            Text(
              'Uploading video... ${(uploadProgress ?? 0 * 100).toStringAsFixed(1)}%',
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    if (!isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return FlickVideoPlayer(
      flickManager: flickManager!,
      flickVideoWithControls: const FlickVideoWithControls(
        controls: FlickPortraitControls(),
      ),
    );
  }
}
