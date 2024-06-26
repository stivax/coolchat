import 'package:flutter/material.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class ReplyProvider with ChangeNotifier {
  ItemScrollController itemScrollController = ItemScrollController();
  String nameRecevierMessage;
  String textMessageToReply;
  String? fileUrl;
  int? idMessageToReplying;
  bool isReplying;
  ReplyProvider({
    this.nameRecevierMessage = '',
    this.textMessageToReply = '',
    this.isReplying = false,
  });

  void addMessageToReply(
      String nameRecevier, String textMessage, int idMessage, String? file) {
    nameRecevierMessage = nameRecevier;
    textMessageToReply = textMessage;
    fileUrl = file;
    idMessageToReplying = idMessage;
    isReplying = true;
    notifyListeners();
  }

  void afterReplyToMessage() {
    nameRecevierMessage = '';
    textMessageToReply = '';
    fileUrl = null;
    idMessageToReplying = null;
    isReplying = false;
    notifyListeners();
  }

  void scrollToMessage(int id) {
    itemScrollController.scrollTo(
      index: id,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeInOutCubic,
      alignment: 0.0,
    );
    notifyListeners();
  }
}
