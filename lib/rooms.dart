// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coolchat/add_room_popup.dart';
import 'package:coolchat/server_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'screen/common_chat.dart';
import 'error_answer.dart';
import 'login_popup.dart';
import 'main.dart';
import 'message_provider.dart';
import 'server/server.dart';
import 'theme_provider.dart';
import 'account.dart';

class Room extends StatefulWidget {
  String name;
  int id;
  String createdAt;
  ImageProvider image;
  int countPeopleOnline;
  int countMessages;
  bool isFavorite;

  Room(
      {required this.name,
      required this.id,
      required this.createdAt,
      required this.image,
      required this.countPeopleOnline,
      required this.countMessages,
      required this.isFavorite});

  static List<Room> fromJsonList(List<dynamic> jsonList) {
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
        isFavorite: false,
      );
    }).toList()
      ..add(Room(
        id: 999,
        name: 'Add room',
        image: AssetImage('assets/images/add_room_dark.jpg'),
        countPeopleOnline: 0,
        countMessages: 0,
        createdAt: '',
        isFavorite: false,
      ));
  }

  static List<String> fromJsonListToListString(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return '${json["images"]}';
    }).toList();
  }

  @override
  State<Room> createState() => _RoomState();
}

class _RoomState extends State<Room> {
  @override
  Widget build(BuildContext context) {
    bool isFavorite = widget.isFavorite;
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
                offset: Offset(1, 1),
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
                    widget.id == 999
                        ? addRoomDialog(context)
                        : Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                topicName: widget.name,
                                id: widget.id,
                                server: server,
                                account: account,
                              ),
                            ),
                          );
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    child: Container(
                      //padding: EdgeInsets.all(8.0),
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: widget.id != 999
                              ? widget.image
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
                          widget.id == 999
                              ? Image(
                                  image: themeProvider.isLightMode
                                      ? const AssetImage(
                                          'assets/images/add_light.png')
                                      : const AssetImage(
                                          'assets/images/add_dark.png'),
                                )
                              : Container(),
                          Container(
                            padding: const EdgeInsets.all(8.0),
                            width: 200,
                            decoration: BoxDecoration(
                                color:
                                    const Color(0xFF0F1E28).withOpacity(0.40)),
                            child: Text(
                              widget.name,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: widget.id == 999
                                    ? themeProvider.currentTheme.primaryColor
                                    : const Color(0xFFF5FBFF),
                                fontSize: 14,
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
              ),
              Expanded(
                flex: 1,
                child: Padding(
                  padding: const EdgeInsets.only(left: 0, right: 0),
                  child: Container(
                    alignment: Alignment.bottomCenter,
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
                    child: Center(
                      child: Container(
                        padding: const EdgeInsets.only(left: 8, right: 8),
                        height: 16,
                        child: Row(
                          verticalDirection: VerticalDirection.down,
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            GestureDetector(
                              onTap: () {
                                widget.isFavorite = !isFavorite;
                                setState(() {
                                  isFavorite = isFavorite ? false : true;
                                });
                              },
                              child: Icon(
                                Icons.favorite,
                                color: isFavorite
                                    ? Colors.pink
                                    : const Color(0xFFF5FBFF),
                                size: 16,
                              ),
                            ),
                            Expanded(
                              child: Container(width: double.infinity),
                            ),
                            Container(
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Container(
                                    width: 16,
                                    height: 16,
                                    clipBehavior: Clip.antiAlias,
                                    decoration: BoxDecoration(),
                                    child:
                                        Image.asset('assets/images/people.png'),
                                  ),
                                  const SizedBox(width: 2),
                                  Text(
                                    widget.countPeopleOnline.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
                                      color: Color(0xFFF5FBFF),
                                      fontSize: 12,
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
  final acc = await readAccountFuture();
  if (acc.userName == '') {
    // ignore: use_build_context_synchronously
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoomAddDialog();
      },
    );
  } else {
    // ignore: use_build_context_synchronously
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return RoomAddDialog();
      },
    );
  }
}

Future<String> sendRoom(BuildContext context, String roomName, String roomImage,
    Account acc) async {
  final token = await loginProcess(context, acc.email, acc.password);
  final server = ServerProvider.of(context).server;
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
            ),
            borderRadius: BorderRadius.circular(20.0),
            border: Border.all(
              width: 3,
              color: !isChoise
                  ? themeProvider.currentTheme.primaryColorDark
                  : themeProvider.currentTheme.shadowColor,
            ),
            boxShadow: const [
              BoxShadow(
                color: Color(0x4C024A7A),
                blurRadius: 3,
                offset: Offset(2, 2),
                spreadRadius: 1,
              )
            ],
          ),
        );
      },
    );
  }
}
