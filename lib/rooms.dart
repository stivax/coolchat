// ignore_for_file: use_build_context_synchronously

import 'dart:convert';

import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/popap/add_room_popup.dart';
import 'package:coolchat/servises/account_setting_provider.dart';
import 'package:coolchat/servises/tab_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';

import 'screen/common_chat.dart';
import 'error_answer.dart';
import 'popap/login_popup.dart';
import 'server/server.dart';
import 'theme_provider.dart';
import 'account.dart';

class Room extends StatefulWidget {
  final String name;
  final int id;
  final String createdAt;
  final ImageProvider image;
  final int countPeopleOnline;
  final int countMessages;
  final bool isFavorite;

  const Room({
    super.key,
    required this.name,
    required this.id,
    required this.createdAt,
    required this.image,
    required this.countPeopleOnline,
    required this.countMessages,
    required this.isFavorite,
  });

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
        isFavorite: false, //favoriteRoomList.contains(json["name_room"]),
      );
    }).toList();
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
  bool scale = true;
  late AccountSettingProvider _accountSettingProvider;

  @override
  void initState() {
    super.initState();
    _accountSettingProvider =
        Provider.of<AccountSettingProvider>(context, listen: false);
    _accountSettingProvider.addListener(_onSwitchScale);
    scale = _accountSettingProvider.accountSettingProvider.scale;
  }

  @override
  void dispose() {
    _accountSettingProvider.removeListener(_onSwitchScale);
    super.dispose();
  }

  void _onSwitchScale() {
    setState(() {
      scale = _accountSettingProvider.accountSettingProvider.scale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return GestureDetector(
          onLongPressStart: (details) {
            showMenuRoomFunction(
                context, themeProvider, details.globalPosition, widget.id);
          },
          child: Container(
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
                      final account = await readAccountFromStorage();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatScreen(
                            topicName: widget.name,
                            id: widget.id,
                            server: server,
                            account: account,
                            hasMessage: widget.countMessages > 0,
                          ),
                        ),
                      ).then(
                          (value) => {_accountSettingProvider.refreshScreen()});
                    },
                    child: Container(
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: widget.image,
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
                      child: Container(
                        padding: const EdgeInsets.all(4.0),
                        width: double.infinity,
                        decoration: BoxDecoration(
                            color: const Color(0xFF0F1E28).withOpacity(0.40)),
                        child: Text(
                          widget.name,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: const Color(0xFFF5FBFF),
                            fontSize: scale ? 14 : 10,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w600,
                            height: 1.30,
                          ),
                        ),
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
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        FittedBox(
                          fit: BoxFit.contain,
                          child: GestureDetector(
                            onTap: () async {
                              if (widget.isFavorite) {
                                await _accountSettingProvider
                                    .removeRoomIntoFavorite(
                                        widget.name, context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: themeProvider
                                        .currentTheme.cardColor
                                        .withOpacity(0.9),
                                    content: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler: TextScaler.noScaling),
                                      child: Center(
                                        child: Text(
                                          'You deleted room "${widget.name}" from favorite',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFF5FBFF),
                                            fontSize: 14,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              } else {
                                await _accountSettingProvider.addRoomToFavorite(
                                    widget.name, context);
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    backgroundColor: themeProvider
                                        .currentTheme.cardColor
                                        .withOpacity(0.9),
                                    content: MediaQuery(
                                      data: MediaQuery.of(context).copyWith(
                                          textScaler: TextScaler.noScaling),
                                      child: Center(
                                        child: Text(
                                          'You added room "${widget.name}" to favorite',
                                          textAlign: TextAlign.center,
                                          style: const TextStyle(
                                            color: Color(0xFFF5FBFF),
                                            fontSize: 14,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ),
                                    ),
                                    duration: const Duration(seconds: 2),
                                  ),
                                );
                              }
                            },
                            child: Icon(
                              Icons.favorite,
                              color: widget.isFavorite
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
                                widget.countMessages.toString(),
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
                                widget.countPeopleOnline.toString(),
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
          ),
        );
      },
    );
  }

  Future<void> showMenuRoomFunction(BuildContext contextRoom,
      ThemeProvider themeProvider, Offset tapPosition, int idRoom) async {
    showMenu(
      context: contextRoom,
      color: themeProvider.currentTheme.hintColor,
      position: RelativeRect.fromLTRB(
        tapPosition.dx,
        tapPosition.dy,
        tapPosition.dx + 1,
        tapPosition.dy + 1,
      ),
      shape: RoundedRectangleBorder(
        side:
            BorderSide(width: 1, color: themeProvider.currentTheme.shadowColor),
        borderRadius: const BorderRadius.only(
          topRight: Radius.circular(14),
          bottomLeft: Radius.circular(14),
          bottomRight: Radius.circular(14),
        ),
      ),
      items: [
        PopupMenuItem(
          height: 36,
          onTap: () {
            print('');
            HapticFeedback.lightImpact();
          },
          child: MediaQuery(
              data: MediaQuery.of(contextRoom)
                  .copyWith(textScaler: TextScaler.noScaling),
              child: SubmenuTabs(
                  label: 'Move to tab',
                  roomId: idRoom,
                  themeProvider: themeProvider)),
        ),
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }
}

class SubmenuTabs extends StatefulWidget {
  final String label;
  final int roomId;
  final ThemeProvider themeProvider;

  const SubmenuTabs({
    super.key,
    required this.label,
    required this.roomId,
    required this.themeProvider,
  });

  @override
  _SubmenuTabsState createState() => _SubmenuTabsState();
}

class _SubmenuTabsState extends State<SubmenuTabs> {
  final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () async {
        final allTabsRoom = await TabViewController.fetchAllTab();
        final RenderBox renderBox =
            _menuKey.currentContext!.findRenderObject() as RenderBox;
        final Offset position = renderBox.localToGlobal(Offset.zero);
        showMenu(
          context: context,
          color: widget.themeProvider.currentTheme.hintColor,
          position: RelativeRect.fromLTRB(
              position.dx, position.dy, position.dx, position.dy),
          shape: RoundedRectangleBorder(
            side: BorderSide(
                width: 1, color: widget.themeProvider.currentTheme.shadowColor),
            borderRadius: const BorderRadius.only(
              topRight: Radius.circular(14),
              bottomLeft: Radius.circular(14),
              bottomRight: Radius.circular(14),
            ),
          ),
          items: TabViewController.tabToPopupMenuItem(
              widget.themeProvider, context, allTabsRoom, widget.roomId),
        );
      },
      child: Row(
        key: _menuKey,
        children: <Widget>[
          Text(
            widget.label,
            style: TextStyle(
              color: widget.themeProvider.currentTheme.primaryColor,
              fontSize: 16.0,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
            ),
          ),
          Icon(
            Icons.arrow_right,
            color: widget.themeProvider.currentTheme.primaryColor,
          ),
        ],
      ),
    );
  }
}

void addRoomDialog(BuildContext context) async {
  Account acc = await readAccountFromStorage();
  if (acc.userName == '') {
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return LoginDialog();
      },
    );
    acc = await readAccountFromStorage();
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
  const suffix = Server.suffix;
  final url = Uri.https(server, '/$suffix/rooms/');

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
  const suffix = Server.suffix;
  final url = Uri.https(server, '/$suffix/images/Home');
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
