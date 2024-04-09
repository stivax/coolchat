// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

class SendFileProvider with ChangeNotifier {
  PlatformFile? file;
  XFile? image;
  bool readyToSend;

  SendFileProvider({
    this.file,
    this.image,
    this.readyToSend = false,
  });

  //Account get accountProvider => _accountCurentState;
  //bool get isLoginProvider => _isLogin;

  void addFileToSend(PlatformFile fileToSend) {
    file = fileToSend;
    readyToSend = true;
    notifyListeners();
  }

  void clearFileFromSend() {
    file = null;
    readyToSend = false;
    notifyListeners();
  }
}
