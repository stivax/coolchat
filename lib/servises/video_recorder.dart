import 'package:coolchat/servises/video_recorder_controller.dart';
import 'package:flutter/material.dart';
import 'package:camera/camera.dart';

class VideoRecorder extends StatefulWidget {
  final List<CameraDescription> cameras;
  final CameraController controller;
  final VideoRecorderController videoController;

  const VideoRecorder({
    super.key,
    required this.cameras,
    required this.controller,
    required this.videoController,
  });

  @override
  _VideoRecorderState createState() => _VideoRecorderState();
}

class _VideoRecorderState extends State<VideoRecorder> {
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    widget.controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: 300, child: CameraPreview(widget.controller));
  }
}
