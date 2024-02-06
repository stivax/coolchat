import 'dart:convert';

import 'package:coolchat/servises/message_provider_container.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'theme_provider.dart';

// ignore: must_be_immutable
class MessagesPrivat extends StatelessWidget {
  final String message;
  final int recipientId;
  final DateTime createdAt;
  final String avatar;
  final String userName;
  final int senderId;
  final int id;
  final bool isPreviousSameMember;
  final int vote;
  final bool isRead;

  const MessagesPrivat({
    super.key,
    required this.message,
    required this.recipientId,
    required this.createdAt,
    required this.avatar,
    required this.userName,
    required this.senderId,
    required this.id,
    required this.isPreviousSameMember,
    required this.isRead,
    required this.vote,
  });

  static MessagesPrivat fromJsonMessage(
      dynamic jsonMessage, int previousMemberID, int recipientId) {
    bool isSameMember = jsonMessage['sender_id'] == previousMemberID;
    final timeZone = DateTime.now().timeZoneOffset;

    return MessagesPrivat(
      message: jsonMessage['messages'],
      createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
      recipientId: recipientId,
      avatar: jsonMessage['avatar'],
      userName: jsonMessage['user_name'],
      senderId: jsonMessage['sender_id'],
      id: jsonMessage['id'],
      isPreviousSameMember: isSameMember,
      vote: jsonMessage['vote'],
      isRead: jsonMessage['is_read'],
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
    var screenWidth = MediaQuery.of(context).size.width;
    return recipientId != senderId
        ? MyMessege(
            screenWidth: screenWidth,
            message: message,
            recipientId: recipientId,
            createdAt: formatTime(createdAt.toString()),
            senderId: senderId,
            id: id,
            avatar: avatar,
            userName: userName,
            vote: vote,
            isPreviousSameMember: isPreviousSameMember,
            isRead: isRead,
          )
        : TheirMessege(
            screenWidth: screenWidth,
            message: message,
            recipientId: recipientId,
            createdAt: formatTime(createdAt.toString()),
            senderId: senderId,
            id: id,
            avatar: avatar,
            userName: userName,
            vote: vote,
            isPreviousSameMember: isPreviousSameMember,
            isRead: isRead,
          );
  }
}

class TheirMessege extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int recipientId;
  final String createdAt;
  final String avatar;
  final String userName;
  final int senderId;
  final int id;
  final int vote;
  final bool isPreviousSameMember;
  final bool isRead;

  const TheirMessege(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.recipientId,
      required this.createdAt,
      required this.avatar,
      required this.userName,
      required this.senderId,
      required this.id,
      required this.vote,
      required this.isPreviousSameMember,
      required this.isRead});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Padding(
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
                          : Stack(
                              alignment: Alignment.topCenter,
                              fit: StackFit.expand,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Positioned(
                                  top: 2,
                                  right: 2,
                                  left: 2,
                                  bottom: 0,
                                  child: Container(
                                    width: 24,
                                    height: 32,
                                    decoration: ShapeDecoration(
                                      color: themeProvider
                                          .currentTheme.primaryColorDark,
                                      shape: RoundedRectangleBorder(
                                        side: BorderSide(
                                            width: 0.50,
                                            color: themeProvider
                                                .currentTheme.shadowColor),
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                      shadows: const [
                                        BoxShadow(
                                          color: Color(0x4C024A7A),
                                          blurRadius: 8,
                                          offset: Offset(2, 2),
                                          spreadRadius: 0,
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                Positioned(
                                  top: 1,
                                  right: 1,
                                  left: 1,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: 24,
                                    height: 32,
                                    child: Image(
                                      image: NetworkImage(avatar),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
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
                                          textScaler: TextScaler.noScaling,
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
                                    textScaler: TextScaler.noScaling,
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      color: themeProvider
                                          .currentTheme.primaryColor,
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
                                  .getProvider(recipientId.toString())
                                  ?.sendMessage(json.encode({
                                    "vote": {"message_id": id, "dir": 1}
                                  }));
                              HapticFeedback.lightImpact();
                            },
                            onHorizontalDragEnd: (_) {
                              final provider = MessageProviderContainer.instance
                                  .getProvider(recipientId.toString());
                              provider?.sendMessage(json.encode({
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
                                      color:
                                          themeProvider.currentTheme.cardColor,
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
                                        buttonItems = editableTextState
                                            .contextMenuButtonItems;
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
                                      child: Container(
                                        height: 16,
                                        width: 32,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              vote.toString(),
                                              textScaler: TextScaler.noScaling,
                                              style: TextStyle(
                                                color: themeProvider
                                                    .currentTheme.primaryColor,
                                                fontSize: 12,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/like.png',
                                              width: 16,
                                              height: 16,
                                              color: themeProvider
                                                  .currentTheme.shadowColor,
                                            )
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
          ),
        );
      },
    );
  }
}

class MyMessege extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int recipientId;
  final String createdAt;
  final String avatar;
  final String userName;
  final int senderId;
  final int id;
  final int vote;
  final bool isPreviousSameMember;
  final bool isRead;

  const MyMessege({
    super.key,
    required this.screenWidth,
    required this.message,
    required this.recipientId,
    required this.createdAt,
    required this.avatar,
    required this.userName,
    required this.senderId,
    required this.id,
    required this.vote,
    required this.isPreviousSameMember,
    required this.isRead,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return MediaQuery(
          data:
              MediaQuery.of(context).copyWith(textScaler: TextScaler.noScaling),
          child: Padding(
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
                                      color: themeProvider
                                          .currentTheme.primaryColor,
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
                          GestureDetector(
                            onDoubleTap: () {
                              MessageProviderContainer.instance
                                  .getProvider(recipientId.toString())
                                  ?.sendMessage(json.encode({
                                    "vote": {"message_id": id, "dir": 1}
                                  }));
                              HapticFeedback.lightImpact();
                            },
                            onHorizontalDragEnd: (_) {
                              final provider = MessageProviderContainer.instance
                                  .getProvider(recipientId.toString());
                              provider?.sendMessage(json.encode({
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
                                      color:
                                          themeProvider.currentTheme.cardColor,
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
                                        buttonItems = editableTextState
                                            .contextMenuButtonItems;
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
                                      child: Container(
                                        height: 16,
                                        width: 32,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.end,
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            Text(
                                              vote.toString(),
                                              textScaler: TextScaler.noScaling,
                                              style: TextStyle(
                                                color: themeProvider
                                                    .currentTheme.primaryColor,
                                                fontSize: 12,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                              ),
                                            ),
                                            Image.asset(
                                              'assets/images/like.png',
                                              width: 16,
                                              height: 16,
                                              color: themeProvider
                                                  .currentTheme.shadowColor,
                                            )
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
                      padding: EdgeInsets.only(right: 3, left: 3),
                      alignment: Alignment.topCenter,
                      width: screenWidth * 0.09,
                      height: 32,
                      child: isPreviousSameMember
                          ? Container()
                          : Stack(
                              alignment: Alignment.topCenter,
                              fit: StackFit.expand,
                              clipBehavior: Clip.hardEdge,
                              children: [
                                Positioned(
                                    top: 2,
                                    right: 2,
                                    left: 2,
                                    bottom: 0,
                                    child: Container(
                                      width: 24,
                                      height: 32,
                                      decoration: ShapeDecoration(
                                        color: themeProvider
                                            .currentTheme.primaryColorDark,
                                        shape: RoundedRectangleBorder(
                                          side: BorderSide(
                                              width: 0.50,
                                              color: themeProvider
                                                  .currentTheme.shadowColor),
                                          borderRadius:
                                              BorderRadius.circular(6),
                                        ),
                                        shadows: [
                                          BoxShadow(
                                            color: themeProvider
                                                .currentTheme.cardColor,
                                            blurRadius: 8,
                                            offset: Offset(2, 2),
                                            spreadRadius: 0,
                                          )
                                        ],
                                      ),
                                    )),
                                Positioned(
                                  top: 1,
                                  right: 1,
                                  left: 1,
                                  bottom: 0,
                                  child: SizedBox(
                                    width: 24,
                                    height: 32,
                                    child: Image(
                                      image: NetworkImage(avatar),
                                      fit: BoxFit.fitHeight,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                    ),
                  ]),
            ),
          ),
        );
      },
    );
  }
}
