// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SendFileProvider with ChangeNotifier {
  File? file;
  String? coment;
  bool readyToSend;
  bool addComent;

  SendFileProvider({
    this.file,
    this.coment,
    this.readyToSend = false,
    this.addComent = false,
  });

  Future<void> addFileToSend(File fileToSend) async {
    file = fileToSend;
    readyToSend = true;
    notifyListeners();
  }

  Future<void> addPlatformFileToSend(PlatformFile fileToSend) async {
    file = await fileFromPlatformFile(fileToSend);
    readyToSend = true;
    notifyListeners();
  }

  void addImageToSend(XFile imageToSend) async {
    file = await fileFromXFile(imageToSend);
    readyToSend = true;
    notifyListeners();
  }

  void addComentToSend(String comentToSend) async {
    coment = comentToSend;
    readyToSend = true;
    notifyListeners();
  }

  void clearFileFromSend() {
    file = null;
    coment = null;
    readyToSend = false;
    notifyListeners();
  }

  void startAddComent() {
    addComent = true;
    notifyListeners();
  }

  void endAddComent() {
    addComent = false;
    notifyListeners();
  }

  static Future<File> fileFromPlatformFile(PlatformFile platformFile) async {
    final tempFile = File(platformFile.path!);
    if (platformFile.bytes != null) {
      await tempFile.writeAsBytes(platformFile.bytes!);
    }
    return tempFile;
  }

  static Future<File> fileFromXFile(XFile xFile) async {
    final tempFile = File(xFile.path);
    final bytes = await xFile.readAsBytes();
    await tempFile.writeAsBytes(bytes);
    return tempFile;
  }
}
