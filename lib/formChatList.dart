import 'themeProvider.dart';

class FormChatList {
  int chatCount;
  var chatList;

  FormChatList({
    required this.chatCount,
    required this.chatList,
  });
}

class ChatItem {
  int id;
  String name;
  String image;
  int countPeople;
  int countOnline;

  ChatItem({
    required this.id,
    required this.name,
    required this.image,
    required this.countPeople,
    required this.countOnline,
  });
}

List<ChatItem> formChatList() {
  List<ChatItem> list = [];
  list.add(ChatItem(
      id: 0,
      name: 'Tents, awnings, canopies',
      image: 'assets/images/room1.png',
      countPeople: 9,
      countOnline: 3));
  list.add(ChatItem(
      id: 1,
      name: 'Backpacks, clothes, shoes',
      image: 'assets/images/room2.png',
      countPeople: 7,
      countOnline: 2));
  list.add(ChatItem(
      id: 2,
      name: 'Bicycles and all for them',
      image: 'assets/images/room3.png',
      countPeople: 6,
      countOnline: 4));
  list.add(ChatItem(
      id: 3,
      name: 'Everything for fishing',
      image: 'assets/images/room4.png',
      countPeople: 6,
      countOnline: 4));
  list.add(ChatItem(
      id: 4,
      name: 'Tourist furniture and tableware',
      image: 'assets/images/room5.png',
      countPeople: 6,
      countOnline: 4));
  list.add(addItem);

  return list;
}

ChatItem addItem = ChatItem(
    id: 999,
    name: 'Add room',
    image: 'assets/images/add_room_dark.jpg',
    countPeople: 0,
    countOnline: 0);
