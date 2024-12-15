import 'package:flutter/material.dart';
import 'package:flick_video_player/flick_video_player.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPlayer extends StatefulWidget {
  final String? videoUrl;
  final File? videoFile;
  final bool isFile;

  const VideoPlayer({
    super.key, 
    this.videoUrl,
    this.videoFile,
    this.isFile = false,
  }) : assert(
          (isFile && videoFile != null) || (!isFile && videoUrl != null),
          'Must provide either videoUrl or videoFile based on isFile flag',
        );

  @override
  _VideoPlayerState createState() => _VideoPlayerState();
}

class _VideoPlayerState extends State<VideoPlayer> {
  late FlickManager flickManager;

  @override
  void initState() {
    super.initState();
    VideoPlayerController videoPlayerController = widget.isFile
        ? VideoPlayerController.file(widget.videoFile!)
        : VideoPlayerController.networkUrl(Uri.parse(widget.videoUrl!));

    flickManager = FlickManager(
      videoPlayerController: videoPlayerController,
    );
  }

  @override
  void dispose() {
    flickManager.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FlickVideoPlayer(flickManager: flickManager);
  }
}
