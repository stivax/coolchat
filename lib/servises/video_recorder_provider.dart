import 'package:coolchat/servises/video_recorder_controller.dart';
import 'package:flutter/material.dart';

class VideoRecorderProvider with ChangeNotifier {
  bool _isRecording = false;
  late VideoRecorderController _videoController;

  bool get isRecording => _isRecording;
  VideoRecorderController get videoController => _videoController;

  startRecording() async {
    _videoController = VideoRecorderController();
    await _videoController.init();
    if (_videoController.isInitialize) {
      _videoController.startRecording();
      _isRecording = true;
      notifyListeners();
    }
  }

  stopRecording(BuildContext context) async {
    _isRecording = false;
    await videoController.stopRecording(context);
    notifyListeners();
  }
}
