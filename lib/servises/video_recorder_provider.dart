import 'package:camera/camera.dart';
import 'package:coolchat/servises/video_recorder_controller.dart';
import 'package:flutter/material.dart';

class VideoRecorderProvider with ChangeNotifier {
  bool _isRecording = false;
  CameraController? _controller;
  Future<void>? _initializeControllerFuture;
  late VideoRecorderController _videoController;
  late List<CameraDescription> _cameras;

  bool get isRecording => _isRecording;
  CameraController? get controller => _controller;
  Future<void>? get initializeControllerFuture => _initializeControllerFuture;
  VideoRecorderController get videoController => _videoController;
  List<CameraDescription> get cameras => _cameras;

  startRecording() async {
    _isRecording = true;
    _cameras = await availableCameras();
    _controller = CameraController(
      _cameras.last,
      ResolutionPreset.high,
      enableAudio: true,
    );
    await _controller!.initialize();
    _videoController = VideoRecorderController(controller: _controller!);
    videoController.startRecording();
    notifyListeners();
  }

  stopRecording(BuildContext context) async {
    _isRecording = false;
    await videoController.stopRecording(context);
    notifyListeners();
  }
}
