class MessagePrivatPush {
  String? type;
  int? senderId;
  int? messageId;
  int? time;

  MessagePrivatPush({this.type, this.senderId, this.messageId, this.time});

  MessagePrivatPush.fromJson(Map<String, dynamic> json) {
    type = json['type'];
    senderId = json['sender_id'];
    messageId = json['message_id'];
    time = DateTime.now().millisecondsSinceEpoch;
  }
}
