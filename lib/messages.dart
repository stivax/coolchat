import 'package:coolchat/avatar.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'theme_provider.dart';
import 'account.dart';

// ignore: must_be_immutable
class Messages extends StatelessWidget {
  final String message;
  final int? id;
  final DateTime createdAt;
  final String avatar;
  final String userName;
  final int ownerId;
  final bool isPreviousSameMember;
  final int? vote;
  final BuildContext contextMessage;

  Account _account =
      Account(email: '', userName: '', password: '', avatar: '', id: 0);
  late Future<Account> _accountFuture;

  Messages(
      {super.key,
      required this.message,
      this.id,
      required this.createdAt,
      required this.avatar,
      required this.userName,
      required this.ownerId,
      required this.isPreviousSameMember,
      this.vote,
      required this.contextMessage});

  static List<Messages> fromJsonList(
      List<dynamic> jsonList, BuildContext contextMessage) {
    int previousMemberID = 0;
    final timeZone = DateTime.now().timeZoneOffset;

    return jsonList.map((json) {
      bool isSameMember = json['owner_id'] == previousMemberID;
      previousMemberID = json['owner_id'];

      return Messages(
        message: json['message'],
        id: json['id']!,
        createdAt: DateTime.parse(json['created_at']).add(timeZone),
        avatar: json['avatar'],
        userName: json['user_name'],
        ownerId: json['receiver_id'],
        isPreviousSameMember: isSameMember,
        vote: json['vote']!,
        contextMessage: contextMessage,
      );
    }).toList();
  }

  static Messages fromJsonMessage(
      dynamic jsonMessage, int previousMemberID, BuildContext contextMessage) {
    bool isSameMember = jsonMessage['receiver_id'] == previousMemberID;
    final timeZone = DateTime.now().timeZoneOffset;

    return Messages(
      message: jsonMessage['message'],
      createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
      avatar: jsonMessage['avatar'],
      userName: jsonMessage['user_name'],
      ownerId: jsonMessage['receiver_id'],
      isPreviousSameMember: isSameMember,
      vote: jsonMessage['vote'],
      contextMessage: contextMessage,
    );
  }

  static String formatTime(String created) {
    DateTime dateTime = DateTime.parse(created);
    DateTime now = DateTime.now();
    DateTime yesterday = now.subtract(const Duration(days: 1));

    if (dateTime.year == now.year &&
        dateTime.month == now.month &&
        dateTime.day == now.day) {
      return DateFormat('HH:mm').format(dateTime);
    } else if (dateTime.year == yesterday.year &&
        dateTime.month == yesterday.month &&
        dateTime.day == yesterday.day) {
      return 'yesterday ${DateFormat('HH:mm').format(dateTime)}';
    } else {
      return DateFormat('dd MMM HH:mm').format(dateTime);
    }
  }

  void _readDataFromFile() {
    final data = readAccountFuture();
    _accountFuture = data;
  }

  @override
  Widget build(BuildContext context) {
    if (_account.userName == '') {
      _readDataFromFile();
    }
    var screenWidth = MediaQuery.of(context).size.width;
    return FutureBuilder<Account>(
      future: _accountFuture,
      builder: (context, snapshot) {
        if (snapshot.hasData) {
          _account = snapshot.data!;
          return _account.id == ownerId
              ? MyMessege(
                  screenWidth: screenWidth,
                  message: message,
                  id: id,
                  createdAt: formatTime(createdAt.toString()),
                  ownerId: ownerId,
                  avatar: avatar,
                  userName: userName,
                  vote: vote,
                  isPreviousSameMember: isPreviousSameMember,
                  contextMessage: contextMessage,
                )
              : TheirMessege(
                  screenWidth: screenWidth,
                  message: message,
                  id: id,
                  createdAt: formatTime(createdAt.toString()),
                  ownerId: ownerId,
                  avatar: avatar,
                  userName: userName,
                  vote: vote,
                  isPreviousSameMember: isPreviousSameMember,
                  contextMessage: contextMessage,
                );
        } else {
          return Container();
        }
      },
    );
  }
}

class TheirMessege extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int? id;
  final String createdAt;
  final int ownerId;
  final String avatar;
  final String userName;
  final int? vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;

  const TheirMessege(
      {super.key,
      required this.screenWidth,
      required this.message,
      this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(2),
            width: screenWidth - 52,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.only(right: 3, left: 3),
                    alignment: Alignment.topCenter,
                    width: screenWidth * 0.09,
                    height: 32,
                    child: isPreviousSameMember
                        ? Container()
                        : AvatarMember(
                            avatar: NetworkImage(avatar),
                            name: userName,
                            isOnline: true,
                            memberID: ownerId,
                            contextAvatarMember: contextMessage,
                          ),
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(bottom: 5),
                                alignment: Alignment.centerLeft,
                                child: isPreviousSameMember
                                    ? Container()
                                    : Text(
                                        userName,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          height: 1.30,
                                        ),
                                      ),
                              ),
                            ),
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              alignment: Alignment.centerRight,
                              child: Opacity(
                                opacity: 0.50,
                                child: Text(
                                  createdAt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            color: themeProvider.currentTheme.hintColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topRight: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: themeProvider.currentTheme.cardColor,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: SelectableLinkify(
                            onOpen: (url) async {
                              await launchUrlString(url.url,
                                  mode: LaunchMode.externalApplication);
                            },
                            text: message,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                            options: const LinkifyOptions(
                                removeWww: true, looseUrl: true),
                            contextMenuBuilder: (context, editableTextState) {
                              final List<ContextMenuButtonItem> buttonItems =
                                  editableTextState.contextMenuButtonItems;
                              buttonItems.removeWhere(
                                  (ContextMenuButtonItem buttonItem) {
                                return buttonItem.type ==
                                    ContextMenuButtonType.cut;
                              });
                              return AdaptiveTextSelectionToolbar.buttonItems(
                                anchors: editableTextState.contextMenuAnchors,
                                buttonItems: buttonItems,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: screenWidth * 0.09,
                  ),
                ]),
          ),
        );
      },
    );
  }
}

class MyMessege extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int? id;
  final String createdAt;
  final int ownerId;
  final String avatar;
  final String userName;
  final int? vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;

  const MyMessege(
      {super.key,
      required this.screenWidth,
      required this.message,
      this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: EdgeInsets.all(2),
            width: screenWidth - 52,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: screenWidth * 0.09,
                  ),
                  Expanded(
                    flex: 12,
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: [
                            Container(
                              padding: EdgeInsets.only(bottom: 5),
                              alignment: Alignment.centerLeft,
                              child: Opacity(
                                opacity: 0.50,
                                child: Text(
                                  createdAt,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 12,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                            Expanded(
                              child: isPreviousSameMember
                                  ? Container()
                                  : Container(
                                      padding: EdgeInsets.only(bottom: 5),
                                      alignment: Alignment.centerRight,
                                      child: Text(
                                        userName,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w600,
                                          height: 1.30,
                                        ),
                                      ),
                                    ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.topLeft,
                          padding: const EdgeInsets.all(10.0),
                          decoration: ShapeDecoration(
                            color: themeProvider.currentTheme.hoverColor,
                            shape: const RoundedRectangleBorder(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(20),
                                bottomLeft: Radius.circular(20),
                                bottomRight: Radius.circular(20),
                              ),
                            ),
                            shadows: [
                              BoxShadow(
                                color: themeProvider.currentTheme.cardColor,
                                blurRadius: 8,
                                offset: const Offset(2, 2),
                                spreadRadius: 0,
                              )
                            ],
                          ),
                          child: SelectableLinkify(
                            onOpen: (url) async {
                              await launchUrlString(url.url,
                                  mode: LaunchMode.externalApplication);
                            },
                            text: message,
                            style: TextStyle(
                              color: themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                              height: 1.30,
                            ),
                            options: const LinkifyOptions(
                                removeWww: true, looseUrl: true),
                            contextMenuBuilder: (context, editableTextState) {
                              final List<ContextMenuButtonItem> buttonItems =
                                  editableTextState.contextMenuButtonItems;
                              buttonItems.removeWhere(
                                  (ContextMenuButtonItem buttonItem) {
                                return buttonItem.type ==
                                    ContextMenuButtonType.cut;
                              });
                              return AdaptiveTextSelectionToolbar.buttonItems(
                                anchors: editableTextState.contextMenuAnchors,
                                buttonItems: buttonItems,
                              );
                            },
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: EdgeInsets.only(right: 3, left: 3),
                    alignment: Alignment.topCenter,
                    width: screenWidth * 0.09,
                    height: 32,
                    child: isPreviousSameMember
                        ? Container()
                        : AvatarMember(
                            avatar: NetworkImage(avatar),
                            name: userName,
                            isOnline: true,
                            memberID: ownerId,
                            contextAvatarMember: contextMessage,
                          ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}
