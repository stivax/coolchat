import 'package:shared_preferences/shared_preferences.dart';

class FavoriteList {
  static Future<List<String>> readFavoriteRoomList() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> roomList = [];
    if (prefs.containsKey('favoriteRoomList')) {
      roomList = prefs.getStringList('favoriteRoomList')!;
    }
    return roomList;
  }

  static void addRoomToFavorite(String roomName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('favoriteRoomList')) {
      List<String> roomList = prefs.getStringList('favoriteRoomList')!;
      roomList.add(roomName);
      prefs.setStringList('favoriteRoomList', roomList);
    } else {
      List<String> roomList = [];
      roomList.add(roomName);
      prefs.setStringList('favoriteRoomList', roomList);
    }
  }

  static void removeRoomIntoFavorite(String roomName) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('favoriteRoomList')) {
      List<String> roomList = prefs.getStringList('favoriteRoomList')!;
      roomList.remove(roomName);
      prefs.setStringList('favoriteRoomList', roomList);
    } else {
      List<String> roomList = [];
      prefs.setStringList('favoriteRoomList', roomList);
    }
  }
}
