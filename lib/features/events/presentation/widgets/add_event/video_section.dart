import 'dart:io';
import 'package:flare_up_host/core/theme/app_palette.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../../core/utils/file_picker_service.dart';
import '../../../../../core/utils/logger.dart';
import '../../../../../core/utils/responsive_utils.dart';
import '../../../../../core/widgets/video_player.dart';
import '../../../domain/entities/media_entity.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../bloc/event_bloc.dart';
import '../../bloc/event_event.dart';
import '../../bloc/event_state.dart';

class VideoSection extends StatefulWidget {
  final Function(MediaEntity) onVideoSelected;
  final File? existingVideo;
  final Function(String)? onVideoUploaded;

  const VideoSection({
    super.key,
    required this.onVideoSelected,
    this.existingVideo,
    this.onVideoUploaded,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  File? selectedVideo;
  bool isUploading = false;
  bool showUploadProgress = false;
  double uploadProgress = 0.0;

  @override
  void initState() {
    super.initState();
    selectedVideo = widget.existingVideo;
  }

  void _handleVideoSelection(File video) {
    Logger.debug('Starting video upload process...');
    Logger.debug('Video file path: ${video.path}');

    setState(() {
      selectedVideo = video;
      showUploadProgress = true;
      uploadProgress = 0.0;
      isUploading = true;
    });

    context.read<EventBloc>()
      ..add(SelectVideoEvent(video))
      ..add(const SetVideoUploadingEvent(true))
      ..add(UploadEventVideoEvent(video));
  }

  @override
  Widget build(BuildContext context) {
    // Initialize responsive utilities
    Responsive.init(context);

    // Calculate responsive dimensions
    final containerPadding = Responsive.isTablet ? 24.0 : 16.0;
    final borderRadius = Responsive.borderRadius;
    final spacing = Responsive.spacingHeight;
    final iconSize = Responsive.isTablet ? 28.0 : 24.0;
    final fontSize = Responsive.bodyFontSize;
    final headerFontSize = Responsive.subtitleFontSize;
    final placeholderHeight = Responsive.screenHeight * 0.25;

    return BlocListener<EventBloc, EventBlocState>(
      listener: (context, state) {
        if (state is EventVideoUploadSuccess) {
          setState(() {
            isUploading = false;
            showUploadProgress = false;
          });

          widget.onVideoSelected(MediaEntity(
            file: selectedVideo,
            url: state.url,
          ));

          if (widget.onVideoUploaded != null) {
            widget.onVideoUploaded!(state.url);
          }

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Video uploaded successfully!'),
              backgroundColor: Colors.green,
            ),
          );
        } else if (state is EventVideoUploadFailure) {
          setState(() {
            isUploading = false;
            showUploadProgress = false;
          });

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to upload video: ${state.message}'),
              backgroundColor: Colors.red,
            ),
          );
        } else if (state is EventMediaUploadProgress) {
          setState(() {
            uploadProgress = state.progress;
          });
        }
      },
      child: Container(
        padding: EdgeInsets.all(containerPadding),
        decoration: BoxDecoration(
          color: AppPalette.darkBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(color: AppPalette.darkCard),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildHeader(iconSize, headerFontSize),
            SizedBox(height: spacing),
            if (selectedVideo != null)
              _buildVideoPreview(borderRadius)
            else
              _buildVideoPickerPlaceholder(
                  placeholderHeight, fontSize, borderRadius),
            if (showUploadProgress)
              _buildUploadProgress(spacing, fontSize, uploadProgress),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(double iconSize, double fontSize) {
    return Row(
      children: [
        Icon(Icons.videocam_outlined, size: iconSize),
        SizedBox(width: 8),
        Text(
          'Promotional Video',
          style: TextStyle(
            fontSize: fontSize,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          ' (Optional)',
          style: TextStyle(
            fontSize: fontSize - 2,
            color: Colors.grey,
          ),
        ),
        Spacer(),
        if (selectedVideo != null)
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red, size: iconSize),
            onPressed: () {
              setState(() {
                selectedVideo = null;
                showUploadProgress = false;
              });
            },
            tooltip: 'Remove video',
          ),
      ],
    );
  }

  Widget _buildVideoPreview(double borderRadius) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: VideoPlayer(
        videoFile: selectedVideo,
        isFile: true,
        handleUpload: false,
        autoPlay: false,
      ),
    );
  }

  Widget _buildUploadProgress(
      double spacing, double fontSize, double uploadProgress) {
    // Don't show the progress widget if upload is complete
    if (uploadProgress >= 1.0) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: EdgeInsets.all(8),
      margin: EdgeInsets.only(top: 8),
      decoration: BoxDecoration(
        color: AppPalette.darkHint,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              value: uploadProgress,
              valueColor: AlwaysStoppedAnimation<Color>(AppPalette.lightText),
            ),
          ),
          SizedBox(width: spacing / 2),
          Text(
            'Uploading video in background...',
            style: TextStyle(
              fontSize: fontSize,
              color: AppPalette.lightText,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVideoPickerPlaceholder(
      double height, double fontSize, double borderRadius) {
    return InkWell(
      onTap: _pickVideo,
      borderRadius: BorderRadius.circular(borderRadius),
      child: Container(
        height: height,
        width: Responsive.screenWidth * 0.8,
        decoration: BoxDecoration(
          color: AppPalette.darkBackground,
          borderRadius: BorderRadius.circular(borderRadius),
          border: Border.all(
            color: AppPalette.darkCard,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.video_library_outlined,
              size: 48,
              color: AppPalette.darkHint,
            ),
            SizedBox(height: 12),
            Text(
              'Tap to add a promotional video',
              style: TextStyle(
                fontSize: fontSize,
                color: AppPalette.darkHint,
              ),
            ),
            SizedBox(height: 8),
            Container(
              padding: EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 6,
              ),
              decoration: BoxDecoration(
                color: AppPalette.darkHint,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Text(
                'MP4, MOV, AVI • Max 50MB',
                style: TextStyle(
                  fontSize: fontSize - 2,
                  color: AppPalette.lightText,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickVideo() async {
    try {
      final video = await FilePickerService.pickVideo();
      if (video != null) {
        final fileSize = await video.length();
        if (fileSize > 50 * 1024 * 1024) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Video size must be less than 50MB'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        final extension = video.path.split('.').last.toLowerCase();
        if (!['mp4', 'mov', 'avi'].contains(extension)) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Please select MP4, MOV, or AVI video format'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        if (mounted) {
          _handleVideoSelection(video);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error selecting video: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
