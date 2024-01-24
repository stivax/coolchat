// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coolchat/add_room_popup.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'screen/common_chat.dart';
import 'error_answer.dart';
import 'login_popup.dart';
import 'server/server.dart';
import 'theme_provider.dart';
import 'account.dart';

class Room extends StatelessWidget {
  final String name;
  final int id;
  final String createdAt;
  final ImageProvider image;
  final int countPeopleOnline;
  final int countMessages;
  final bool isFavorite;
  final bool scale;

  const Room({
    super.key,
    required this.name,
    required this.id,
    required this.createdAt,
    required this.image,
    required this.countPeopleOnline,
    required this.countMessages,
    required this.isFavorite,
    required this.scale,
  });

  static List<Room> fromJsonList(
      List<dynamic> jsonList, List<String> favoriteRoomList, bool scale) {
    return jsonList.map((json) {
      return Room(
        name: json["name_room"],
        id: json["id"],
        createdAt: json["created_at"],
        image: CachedNetworkImageProvider(
          json["image_room"],
        ),
        countPeopleOnline: json["count_users"],
        countMessages: json["count_messages"],
        isFavorite: favoriteRoomList.contains(json["name_room"]),
        scale: scale,
      );
    }).toList()
      ..add(Room(
        id: 999,
        name: 'Add room',
        image: const AssetImage('assets/images/add_room_dark.jpg'),
        countPeopleOnline: 0,
        countMessages: 0,
        createdAt: '',
        isFavorite: false,
        scale: scale,
      ));
  }

  static List<String> fromJsonListToListString(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return '${json["images"]}';
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          height: 207,
          width: double.infinity,
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: themeProvider.currentTheme.primaryColorDark,
                blurRadius: 0,
                offset: const Offset(1, 1),
                spreadRadius: 0,
              )
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                flex: 5,
                child: GestureDetector(
                  onTap: () async {
                    const server = Server.server;
                    final account = await readAccountFuture();
                    id == 999
                        ? addRoomDialog(context)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                topicName: name,
                                id: id,
                                server: server,
                                account: account,
                                hasMessage: countMessages > 0,
                              ),
                            ),
                          ).then((value) =>
                            {_accountSettingProvider.refreshScreen()});
                  },
                  child: Container(
                    width: double.infinity,
                    alignment: Alignment.bottomCenter,
                    decoration: ShapeDecoration(
                      image: DecorationImage(
                        image: id != 999
                            ? image
                            : themeProvider.isLightMode
                                ? const AssetImage(
                                    'assets/images/add_room_light.jpg')
                                : const AssetImage(
                                    'assets/images/add_room_dark.jpg'),
                        fit: BoxFit.cover,
                      ),
                      shape: RoundedRectangleBorder(
                        side: BorderSide(
                            width: 0.50,
                            color: themeProvider.currentTheme.shadowColor),
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(10),
                          topRight: Radius.circular(10),
                        ),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        id == 999
                            ? Image(
                                image: themeProvider.isLightMode
                                    ? const AssetImage(
                                        'assets/images/add_light.png')
                                    : const AssetImage(
                                        'assets/images/add_dark.png'),
                                height: scale ? 28 : 14,
                              )
                            : Container(),
                        Container(
                          padding: const EdgeInsets.all(4.0),
                          width: double.infinity,
                          decoration: BoxDecoration(
                              color: const Color(0xFF0F1E28).withOpacity(0.40)),
                          child: Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: id == 999
                                  ? themeProvider.currentTheme.primaryColor
                                  : const Color(0xFFF5FBFF),
                              fontSize: scale ? 14 : 10,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              height: 1.30,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Expanded(
                flex: 1,
                child: Container(
                  padding: scale
                      ? const EdgeInsets.only(
                          right: 8, left: 8, top: 6, bottom: 6)
                      : const EdgeInsets.only(
                          right: 4, left: 4, top: 3, bottom: 3),
                  alignment: Alignment.center,
                  decoration: ShapeDecoration(
                    color: themeProvider.currentTheme.shadowColor,
                    shape: RoundedRectangleBorder(
                      side: BorderSide(
                          width: 0.50,
                          color: themeProvider.currentTheme.shadowColor),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(10),
                        bottomRight: Radius.circular(10),
                      ),
                    ),
                  ),
                  child: id == 999
                      ? Container()
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            FittedBox(
                              fit: BoxFit.contain,
                              child: GestureDetector(
                                onTap: () async {
                                  if (isFavorite) {
                                    await _accountSettingProvider
                                        .removeRoomIntoFavorite(name, context);
                                  } else {
                                    await _accountSettingProvider
                                        .addRoomToFavorite(name, context);
                                  }
                                },
                                child: Icon(
                                  Icons.favorite,
                                  color: isFavorite
                                      ? Colors.pink
                                      : const Color(0xFFF5FBFF),
                                  //size: 16,
                                ),
                              ),
                            ),
                            Container(),
                            FittedBox(
                              fit: BoxFit.contain,
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.mail,
                                    color: Color(0xFFF5FBFF),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    countMessages.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFF5FBFF),
                                      //fontSize: 12,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 6,
                                  ),
                                  const Icon(
                                    Icons.people,
                                    color: Color(0xFFF5FBFF),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    countPeopleOnline.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFF5FBFF),
                                      //fontSize: 12,
                                      fontFamily: 'Manrope',
                                      fontWeight: FontWeight.w400,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

void addRoomDialog(BuildContext context) async {
  Account acc = await readAccountFuture();
  if (acc.userName == '') {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
    acc = await readAccountFuture();
    if (acc.userName != '') {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return const RoomAddDialog();
        },
      );
    }
  } else {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return const RoomAddDialog();
      },
    );
  }
}

Future<String> sendRoom(BuildContext context, String roomName, String roomImage,
    Account acc) async {
  final token = await loginProcess(acc.email, acc.password);
  const server = Server.server;
  final url = Uri.https(server, '/rooms/');

  final jsonBody = {
    "name_room": roomName,
    "image_room": roomImage,
  };
  final response = await http.post(
    url,
    headers: {
      'Authorization': 'Bearer ${token["access_token"]}',
      'Content-Type': 'application/json'
    },
    body: json.encode(jsonBody),
  );

  if (response.statusCode == 201) {
    return '';
  } else {
    final responseData = json.decode(response.body);
    final error = ErrorAnswer.fromJson(responseData);
    return '${error.detail}';
  }
}

Future<http.Response> _getData(String server) async {
  final url = Uri.https(server, '/images/Home');
  return await http.get(url);
}

Future<List<String>> fetchData(String server) async {
  try {
    http.Response response = await _getData(server);
    if (response.statusCode == 200) {
      String responseBody = utf8.decode(response.bodyBytes);
      List<dynamic> jsonList = jsonDecode(responseBody);
      List<String> roomsListString =
          Room.fromJsonListToListString(jsonList).toList();
      return roomsListString;
    } else {
      return [];
    }
    // ignore: empty_catches
  } catch (error) {
    return [];
  }
}

class RoomAvatar extends StatelessWidget {
  ImageProvider image;
  bool isChoise;
  RoomAvatar({Key? key, required this.image, required this.isChoise})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Container(
          decoration: BoxDecoration(
            image: DecorationImage(
              image: image,
              fit: BoxFit.cover,
              opacity: isChoise ? 1 : 0.8,
            ),
            borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(10.0),
                topRight: Radius.circular(10.0)),
            border: isChoise
                ? Border.all(
                    width: 3,
                    color: themeProvider.currentTheme.shadowColor,
                  )
                : Border.all(
                    width: 0,
                  ),
          ),
        );
      },
    );
  }
}
