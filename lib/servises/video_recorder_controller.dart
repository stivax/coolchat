import 'dart:io';

import 'package:camera/camera.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

class VideoRecorderController {
  bool isInitialize = false;
  bool isRecording = false;
  late CameraController _controller;
  late List<CameraDescription> _cameras;

  CameraController get controller => _controller;
  List<CameraDescription> get cameras => _cameras;

  Future<void> init() async {
    final hasCameraRequest = await Permission.camera.isGranted;
    final hasStorageRequest = await Permission.storage.isGranted;
    if (!hasCameraRequest || !hasStorageRequest) {
      await Permission.storage.request();
      await Permission.camera.request();
    } else {
      _cameras = await availableCameras();
      _controller = CameraController(
        _cameras.last,
        ResolutionPreset.low,
        enableAudio: true,
      );
      await _controller.initialize();
      isInitialize = true;
    }
  }

  void startRecording() {
    _controller.startVideoRecording();
    isRecording = true;
  }

  Future<void> stopRecording(BuildContext context) async {
    if (_controller.value.isRecordingVideo) {
      final file = await _controller.stopVideoRecording();
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String videoDirectory = '${appDirectory.path}/Videos';
      await Directory(videoDirectory).create(recursive: true);
      final String filePath = path.join(
          videoDirectory, '${DateTime.now().millisecondsSinceEpoch}.mp4');
      await file.saveTo(filePath);
      final fileProvider =
          Provider.of<SendFileProvider>(context, listen: false);
      fileProvider.addImageToSend(file);
      isRecording = false;
    } else {}
  }
}
