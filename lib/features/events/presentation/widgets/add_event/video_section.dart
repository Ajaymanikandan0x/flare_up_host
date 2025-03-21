import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../../../core/error/app_error.dart';
import '../../../../../core/utils/file_picker_service.dart';
import '../../../../../core/widgets/video_player.dart';
import '../../../domain/entities/media_entity.dart';
import '../../../domain/repositories/event_repository.dart';
import '../../bloc/event_bloc.dart';
import '../../bloc/event_event.dart';
import '../../bloc/event_state.dart';

class VideoSection extends StatefulWidget {
  final Function(MediaEntity) onVideoSelected;
  final File? existingVideo;

  const VideoSection({
    super.key,
    required this.onVideoSelected,
    this.existingVideo,
  });

  @override
  State<VideoSection> createState() => _VideoSectionState();
}

class _VideoSectionState extends State<VideoSection> {
  File? selectedVideo;

  @override
  void initState() {
    super.initState();
    selectedVideo = widget.existingVideo;
  }

  void validateVideo(File video) {
    final extension = video.path.split('.').last.toLowerCase();
    final validFormats = ['mp4', 'mov', 'avi'];

    if (!validFormats.contains(extension)) {
      throw AppError(
        userMessage: 'Unsupported video format. Please use MP4, MOV, or AVI.',
        type: ErrorType.validation,
      );
    }

    final fileSize = video.lengthSync();
    final maxSize = 100 * 1024 * 1024; // 100MB
    if (fileSize > maxSize) {
      throw AppError(
        userMessage: 'Video file is too large. Maximum size is 100MB.',
        type: ErrorType.validation,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<EventBloc, EventBlocState>(
      listener: (context, state) {
        if (state is EventMediaUploadSuccess) {
          widget.onVideoSelected(MediaEntity(
            file: selectedVideo,
            url: state.url,
          ));
        }
      },
      child: GestureDetector(
        onTap: () async {
          try {
            final video = await FilePickerService.pickFile();
            if (video != null) {
              validateVideo(video);
              setState(() {
                selectedVideo = video;
              });

              // Show loading indicator
              context.read<EventBloc>().add(
                    UploadEventMediaEvent(
                      file: video,
                      type: MediaType.video,
                    ),
                  );
            }
          } catch (e) {
            setState(() {
              selectedVideo = null; // Reset on error
            });
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(e.toString()),
                backgroundColor: Colors.red,
              ),
            );
          }
        },
        child: Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.grey),
          ),
          child: selectedVideo != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: VideoPlayer(
                    videoFile: selectedVideo,
                    isFile: true,
                  ),
                )
              : const Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.video_library, size: 40, color: Colors.grey),
                    SizedBox(height: 8),
                    Text('Add Promo Video'),
                  ],
                ),
        ),
      ),
    );
  }
}
