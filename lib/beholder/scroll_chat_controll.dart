import 'package:beholder_flutter/beholder_flutter.dart';

class ScrollChatControll extends ViewModel {
  late var showArrow = state(false);
  late var countNewMessages = state(0);

  void showingArrow() {
    showArrow.value = !showArrow.value;
  }

  void addNewMessage() {
    countNewMessages.value++;
  }

  void clearNewMessagess() {
    countNewMessages.value = 0;
  }
}
