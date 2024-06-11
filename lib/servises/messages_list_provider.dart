import 'package:coolchat/members.dart';
import 'package:coolchat/model/messages.dart';
import 'package:coolchat/model/messages_list_data.dart';
import 'package:flutter/material.dart';

class MessagesListProvider extends ChangeNotifier {
  Map<String, MessagesListData> messages = {};

  void checkAndCreationMessagesListData(String nameScreen) {
    if (!messages.containsKey(nameScreen)) {
      messages[nameScreen] = MessagesListData(
          messages: [], members: {}, listName: '', previousMemberID: 0);
    }
  }

  void addPreviousMemberId(String nameScreen, int previousMemberID) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.addPreviousMemberID(previousMemberID);
  }

  void addMessageToList(String nameScreen, Messages message) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.addMessage(message);
    notifyListeners();
  }

  void removeMessageFromList(String nameScreen) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.clearData();
    //notifyListeners();
  }

  void removeMessageFromListWithNotify(String nameScreen) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.clearData();
    notifyListeners();
  }

  void addMembersToList(String nameScreen, Set<Member> members) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.addMembers(members);
    notifyListeners();
  }

  void removeMembersFromList(String nameScreen) {
    checkAndCreationMessagesListData(nameScreen);
    messages[nameScreen]!.clearMembers();
  }
}
