import 'dart:io';
import 'package:coolchat/servises/send_file_provider.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:flutter_sound/flutter_sound.dart';
import 'package:provider/provider.dart';

class VoiceRecorder {
  FlutterSoundRecorder? _recorder;
  bool _isRecorderInitialized = false;
  bool get isRecording => _recorder?.isRecording ?? false;
  bool get isRecorderInitialized => _isRecorderInitialized;

  Future<void> init() async {
    _recorder = FlutterSoundRecorder();
    final status = await Permission.microphone.isGranted;
    if (!status) {
      await Permission.microphone.request();
    } else {
      await _recorder!.openRecorder();
      _isRecorderInitialized = true;
    }
  }

  Future<String?> startRecording() async {
    if (!_isRecorderInitialized) throw Exception('Recorder not initialized');

    final dir = await getTemporaryDirectory();
    final filePath =
        '${dir.path}/voice_${DateTime.now().millisecondsSinceEpoch}.aac';

    await _recorder!.startRecorder(
      toFile: filePath,
      codec: Codec.aacADTS,
    );
    return filePath;
  }

  Future<void> stopRecording(BuildContext context, String filePath) async {
    if (!_isRecorderInitialized) throw Exception('Recorder not initialized');
    await _recorder!.stopRecorder();
    final fileProvider = Provider.of<SendFileProvider>(context, listen: false);
    File fileToSend = File(filePath);
    fileProvider.addFileToSend(fileToSend);
  }

  Future<void> dispose() async {
    if (_recorder != null) {
      await _recorder!.closeRecorder();
      _recorder = null;
      _isRecorderInitialized = false;
    }
  }
}
