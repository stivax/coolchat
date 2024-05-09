import 'dart:io';

import 'package:camera/camera.dart';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';

class VideoRecorderController {
  CameraController controller;

  VideoRecorderController({required this.controller});

  void startRecording() {
    controller.startVideoRecording();
  }

  Future<void> stopRecording(BuildContext context) async {
    if (controller.value.isRecordingVideo) {
      final file = await controller.stopVideoRecording();
      final Directory appDirectory = await getApplicationDocumentsDirectory();
      final String videoDirectory = '${appDirectory.path}/Videos';
      await Directory(videoDirectory).create(recursive: true);
      final String filePath = path.join(
          videoDirectory, '${DateTime.now().millisecondsSinceEpoch}.mp4');
      await file.saveTo(filePath);
      final fileProvider =
          Provider.of<SendFileProvider>(context, listen: false);
      fileProvider.addImageToSend(file);
    } else {}
  }
}
