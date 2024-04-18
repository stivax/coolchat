import 'package:flutter/material.dart';

class ChangeMessageProvider with ChangeNotifier {
  String? oldMessage;
  String? newMessage;
  int? idMessage;
  bool readyToChangeMessage;
  bool wasChanged;

  ChangeMessageProvider({
    this.oldMessage,
    this.newMessage,
    this.idMessage,
    this.readyToChangeMessage = false,
    this.wasChanged = false,
  });

  void beginChangeMessage(String oldMessageForChange, int id) {
    oldMessage = oldMessageForChange;
    idMessage = id;
    readyToChangeMessage = true;
    notifyListeners();
  }

  void finishChangeMessage(String newMessageAfterChange) {
    newMessage = newMessageAfterChange;
    readyToChangeMessage = false;
    wasChanged = true;
    notifyListeners();
  }

  void finishWithNoChangeMessage() {
    newMessage = oldMessage;
    readyToChangeMessage = false;
    wasChanged = true;
    notifyListeners();
  }

  void clearChangeMessage() {
    oldMessage = null;
    newMessage = null;
    idMessage = null;
    readyToChangeMessage = false;
    wasChanged = false;
  }
}
