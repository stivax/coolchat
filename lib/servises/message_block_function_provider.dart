import 'package:coolchat/model/message_block_data.dart';
import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessagesBlockFunctionProvider extends ChangeNotifier {
  Map<String, MessagesBlockData> messagesBlockFunction = {};

  void checkAndCreationMessagesListData(String nameScreen) {
    if (!messagesBlockFunction.containsKey(nameScreen)) {
      messagesBlockFunction[nameScreen] = MessagesBlockData();
    }
  }

  void showingWriting(String nameScreen) async {
    checkAndCreationMessagesListData(nameScreen);
    messagesBlockFunction[nameScreen]!.addShowWrite();
    notifyListeners();
    await Future.delayed(const Duration(seconds: 3));
    messagesBlockFunction[nameScreen]!.removeShowWrite();
    notifyListeners();
  }

  Future<void> startShowingArrowDownBlockMessages(String nameScreen) async {
    checkAndCreationMessagesListData(nameScreen);
    await Future.delayed(const Duration(milliseconds: 500));
    messagesBlockFunction[nameScreen]!.showingArrowDown(true);
    notifyListeners();
  }

  Future<void> stopShowingArrowDownBlockMessages(String nameScreen) async {
    checkAndCreationMessagesListData(nameScreen);
    await Future.delayed(const Duration(milliseconds: 500));
    messagesBlockFunction[nameScreen]!.showingArrowDown(false);
    notifyListeners();
  }

  Future<void> addNewMessageInArrowBlockMessages(String nameScreen) async {
    checkAndCreationMessagesListData(nameScreen);
    await Future.delayed(const Duration(milliseconds: 500));
    messagesBlockFunction[nameScreen]!.addNewMessageInArrow();
    notifyListeners();
  }

  void clearNewMessagessInArrowBlockMessages(String nameScreen) {
    checkAndCreationMessagesListData(nameScreen);
    messagesBlockFunction[nameScreen]!.clearNewMessagessInArrow();
    //notifyListeners();
  }

  ItemScrollController getItemScrollController(String nameScreen) {
    checkAndCreationMessagesListData(nameScreen);
    return messagesBlockFunction[nameScreen]!.itemScrollController;
  }
}
