import 'package:coolchat/members.dart';
import 'package:coolchat/model/messages.dart';

class MessagesListData {
  List<Messages> messages;
  Set<Member> members;
  String listName;
  int previousMemberID;

  MessagesListData({
    required this.messages,
    required this.members,
    required this.listName,
    required this.previousMemberID,
  });

  void addMessage(Messages message) {
    messages.add(message);
  }

  void addPreviousMemberID(int previousMemberID) {
    this.previousMemberID = previousMemberID;
  }

  void clearData() {
    messages.clear();
    listName = '';
    previousMemberID = 0;
  }

  void addMembers(Set<Member> currentMembers) {
    members.clear();
    members.addAll(currentMembers);
  }

  void clearMembers() {
    members.clear();
  }
}
