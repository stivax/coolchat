import 'package:coolchat/rooms.dart';

class MyTab {
  String? nameTab;
  String? imageTab;
  int? id;
  List<Room>? rooms;

  MyTab({this.nameTab, this.imageTab, this.id, this.rooms});

  MyTab.fromJson(Map<String, dynamic> json) {
    nameTab = json['name_tab'];
    imageTab = json['image_tab'];
    id = json['id'];
    rooms = Room.fromJsonList(json['rooms']);
  }

  static List<MyTab> fromJsonList(Map<String, dynamic> json) {
    return json.entries.map((entry) {
      return MyTab.fromJson(entry.value);
    }).toList();
  }
}
