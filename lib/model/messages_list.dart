import 'package:coolchat/messages.dart';

class ListMessages {
  static final ListMessages _instance = ListMessages._internal();

  List<Messages> listMessages = [];

  factory ListMessages() {
    return _instance;
  }

  ListMessages._internal();

  void addObject(Messages object) {
    listMessages.add(object);
  }

  List<Messages> getObjects() {
    return listMessages;
  }

  void clearObjects() {
    listMessages.clear();
  }
}
