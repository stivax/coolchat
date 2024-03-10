import 'dart:convert';

class MessagePrivatPush {
  String sender;
  String message;
  int senderId;
  int messageId;

  MessagePrivatPush(
      {required this.senderId,
      required this.messageId,
      required this.sender,
      required this.message});

  factory MessagePrivatPush.fromJson(Map<String, dynamic> json) {
    return MessagePrivatPush(
      senderId: json['sender_id'] as int,
      messageId: json['message_id'] as int,
      sender: json['sender'] as String,
      message: json['message'] as String,
    );
  }

  static List<MessagePrivatPush> fromJsonList(String jsonString) {
    final data = json.decode(jsonString);
    final List<dynamic> newMessageList = data['new_message'];
    return newMessageList
        .map((dynamic item) =>
            MessagePrivatPush.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  static List<MessagePrivatPush> differenceList(
      List<MessagePrivatPush> firstList, List<MessagePrivatPush> secondList) {
    final Set<String> firstSet =
        firstList.map((message) => _customKey(message)).toSet();

    return secondList.where((item) {
      return !firstSet.contains(_customKey(item));
    }).toList();
  }

  static String _customKey(MessagePrivatPush message) {
    return '${message.senderId}_${message.messageId}_${message.sender}_${message.message}';
  }

  static bool checkSenderIdConsistency(List<MessagePrivatPush> list) {
    if (list.isEmpty || list.length == 1) {
      return true;
    }
    int firstSenderId = list.first.senderId;
    return list.every((item) => item.senderId == firstSenderId);
  }
}
