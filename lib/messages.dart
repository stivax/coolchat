import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:coolchat/avatar.dart';
import 'package:coolchat/servises/message_provider_container.dart';

import 'account.dart';
import 'theme_provider.dart';

// ignore: must_be_immutable
class Messages extends StatelessWidget {
  final String message;
  final int? id;
  final DateTime createdAt;
  final String avatar;
  final String userName;
  final int ownerId;
  final bool isPreviousSameMember;
  final int vote;
  final BuildContext contextMessage;
  final String roomName;
  final int accountId;
  Messages(
      {super.key,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.avatar,
      required this.userName,
      required this.ownerId,
      required this.isPreviousSameMember,
      required this.vote,
      required this.contextMessage,
      required this.roomName,
      required this.accountId});

  static Messages fromJsonMessage(dynamic jsonMessage, int previousMemberID,
      BuildContext contextMessage, String roomName, int accountId) {
    bool isSameMember = jsonMessage['receiver_id'] == previousMemberID;
    final timeZone = DateTime.now().timeZoneOffset;

    return Messages(
      message: jsonMessage['message'],
      id: jsonMessage['id'],
      createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
      avatar: jsonMessage['avatar'],
      userName: jsonMessage['user_name'],
      ownerId: jsonMessage['receiver_id'],
      isPreviousSameMember: isSameMember,
      vote: jsonMessage['vote'],
      contextMessage: contextMessage,
      roomName: roomName,
      accountId: accountId,
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

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return accountId == ownerId
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
            roomName: roomName,
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
            roomName: roomName,
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
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;

  const TheirMessege(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      required this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage,
      required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(2),
            width: screenWidth - 52,
            child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: const EdgeInsets.only(right: 3, left: 3),
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
                                padding: const EdgeInsets.only(bottom: 5),
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
                              padding: const EdgeInsets.only(bottom: 5),
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
                        GestureDetector(
                          onDoubleTap: () {
                            MessageProviderContainer.instance
                                .getProvider(roomName)
                                ?.channel
                                .sink
                                .add(json.encode({
                                  "vote": {"message_id": id, "dir": 1}
                                }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.channel.sink.add(json.encode({
                              "vote": {"message_id": id, "dir": -1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          child: Stack(children: [
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
                                  color:
                                      themeProvider.currentTheme.primaryColor,
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                  height: 1.30,
                                ),
                                options: const LinkifyOptions(
                                    removeWww: true, looseUrl: true),
                                contextMenuBuilder:
                                    (context, editableTextState) {
                                  final List<ContextMenuButtonItem>
                                      buttonItems =
                                      editableTextState.contextMenuButtonItems;
                                  buttonItems.removeWhere(
                                      (ContextMenuButtonItem buttonItem) {
                                    return buttonItem.type ==
                                        ContextMenuButtonType.cut;
                                  });
                                  return AdaptiveTextSelectionToolbar
                                      .buttonItems(
                                    anchors:
                                        editableTextState.contextMenuAnchors,
                                    buttonItems: buttonItems,
                                  );
                                },
                              ),
                            ),
                            vote != 0
                                ? Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: SizedBox(
                                      height: 10,
                                      width: 20,
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.favorite,
                                            size: 12,
                                            color: Colors.pink,
                                          ),
                                          Text(
                                            vote.toString(),
                                            style: TextStyle(
                                              color: themeProvider
                                                  .currentTheme.primaryColor,
                                              fontSize: 9,
                                              fontFamily: 'Manrope',
                                              fontWeight: FontWeight.w400,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
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
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;

  const MyMessege(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      required this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage,
      required this.roomName});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: Container(
            padding: const EdgeInsets.all(2),
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
                              padding: const EdgeInsets.only(bottom: 5),
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
                                      padding: const EdgeInsets.only(bottom: 5),
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
                        GestureDetector(
                          onDoubleTap: () {
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.channel.sink.add(json.encode({
                              "vote": {"message_id": id, "dir": 1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.channel.sink.add(json.encode({
                              "vote": {"message_id": id, "dir": -1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          child: Stack(children: [
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
                                  color:
                                      themeProvider.currentTheme.primaryColor,
                                  fontSize: 14,
                                  fontFamily: 'Manrope',
                                  fontWeight: FontWeight.w400,
                                  height: 1.30,
                                ),
                                options: const LinkifyOptions(
                                    removeWww: true, looseUrl: true),
                                contextMenuBuilder:
                                    (context, editableTextState) {
                                  final List<ContextMenuButtonItem>
                                      buttonItems =
                                      editableTextState.contextMenuButtonItems;
                                  buttonItems.removeWhere(
                                      (ContextMenuButtonItem buttonItem) {
                                    return buttonItem.type ==
                                        ContextMenuButtonType.cut;
                                  });
                                  return AdaptiveTextSelectionToolbar
                                      .buttonItems(
                                    anchors:
                                        editableTextState.contextMenuAnchors,
                                    buttonItems: buttonItems,
                                  );
                                },
                              ),
                            ),
                            vote != 0
                                ? Positioned(
                                    bottom: 10,
                                    right: 10,
                                    child: Row(
                                      children: [
                                        const Icon(
                                          Icons.favorite,
                                          size: 12,
                                          color: Colors.pink,
                                        ),
                                        Text(
                                          vote.toString(),
                                          style: TextStyle(
                                            color: themeProvider
                                                .currentTheme.primaryColor,
                                            fontSize: 9,
                                            fontFamily: 'Manrope',
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  )
                                : const SizedBox(),
                          ]),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.only(right: 3, left: 3),
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
