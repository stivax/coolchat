import 'dart:convert';

import 'package:coolchat/model/messages_list.dart';
import 'package:coolchat/servises/reply_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:coolchat/avatar.dart';
import 'package:coolchat/servises/message_provider_container.dart';

import 'theme_provider.dart';

// ignore: must_be_immutable
class Messages extends StatelessWidget {
  final String message;
  final int id;
  final DateTime createdAt;
  final String avatar;
  final String userName;
  final int? ownerId;
  final bool isPreviousSameMember;
  final int vote;
  final BuildContext contextMessage;
  final String roomName;
  final int accountId;
  final int? idReturn;
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
      required this.accountId,
      required this.idReturn});

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
      ownerId: jsonMessage['receiver_id'] ?? 0,
      isPreviousSameMember: isSameMember,
      vote: jsonMessage['vote'],
      idReturn: jsonMessage['id_return'],
      contextMessage: contextMessage,
      roomName: roomName,
      accountId: accountId,
    );
  }

  static bool fromJsonVote(dynamic jsonVote) {
    return jsonVote;
  }

  static List<Messages> fromJsonList(dynamic jsonList,
      BuildContext contextMessage, String roomName, int accountId) {
    int previousMemberID = 0;
    final timeZone = DateTime.now().timeZoneOffset;
    List<Messages> messages = [];
    jsonList.map((jsonMessage) {
      bool isSameMember = jsonMessage['receiver_id'] == previousMemberID;
      previousMemberID = jsonMessage['receiver_id'];
      //print(jsonMessage);

      messages.add(Messages(
        message: jsonMessage['message'],
        id: jsonMessage['id'],
        createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
        avatar: jsonMessage['avatar'],
        userName: jsonMessage['user_name'],
        ownerId: jsonMessage['receiver_id'] ?? 0,
        isPreviousSameMember: isSameMember,
        vote: jsonMessage['vote'],
        idReturn: jsonMessage['id_return'],
        contextMessage: contextMessage,
        roomName: roomName,
        accountId: accountId,
      ));
    }).toList();
    return messages;
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

  static Messages findById(List<Messages> messagesList, int searchId) {
    for (Messages message in messagesList) {
      if (message.id == searchId) {
        return message;
      }
    }
    return Messages(
        message: "MESSAGE DELETED",
        id: 0,
        createdAt: DateTime.now(),
        avatar: '',
        userName: 'Secret user',
        ownerId: 0,
        isPreviousSameMember: true,
        vote: 0,
        contextMessage: messagesList.first.contextMessage,
        roomName: '',
        accountId: 0,
        idReturn: 0);
  }

  static int? findPositionById(List<Messages> messagesList, int searchId) {
    int position = 0;
    for (Messages message in messagesList.reversed) {
      if (message.id == searchId) {
        return position;
      }
      position++;
    }
    return null;
  }

  static bool isImageLink(String text) {
    final RegExp imageLinkRegExp = RegExp(
        r'(http(s?):)([/|.|\w|\s|-])*\.(?:jpg|jpeg|gif|png|webp)',
        caseSensitive: false);

    return imageLinkRegExp.hasMatch(text);
  }

  static String? extractFirstUrl(String text) {
    final RegExp urlRegExp =
        RegExp(r'https?:\/\/[^\s<>"]+', caseSensitive: false);

    final match = urlRegExp.firstMatch(text);

    return match?.group(0);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    if (idReturn == null) {
      return accountId == ownerId
          ? MyMessege(
              screenWidth: screenWidth,
              message: message,
              id: id,
              createdAt: formatTime(createdAt.toString()),
              ownerId: ownerId!,
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
              ownerId: ownerId!,
              avatar: avatar,
              userName: userName,
              vote: vote,
              isPreviousSameMember: isPreviousSameMember,
              contextMessage: contextMessage,
              roomName: roomName,
            );
    } else {
      return accountId == ownerId
          ? MyMessegeReply(
              screenWidth: screenWidth,
              message: message,
              id: id,
              createdAt: formatTime(createdAt.toString()),
              ownerId: ownerId!,
              avatar: avatar,
              userName: userName,
              vote: vote,
              isPreviousSameMember: isPreviousSameMember,
              contextMessage: contextMessage,
              roomName: roomName,
              idReturn: idReturn!,
            )
          : TheirMessegeReply(
              screenWidth: screenWidth,
              message: message,
              id: id,
              createdAt: formatTime(createdAt.toString()),
              ownerId: ownerId!,
              avatar: avatar,
              userName: userName,
              vote: vote,
              isPreviousSameMember: isPreviousSameMember,
              contextMessage: contextMessage,
              roomName: roomName,
              idReturn: idReturn!,
            );
    }
  }
}

class TheirMessege extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int id;
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
                            big: false,
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
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.sendMessage(json.encode({
                              "vote": {"message_id": id, "dir": 1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final isReplying = Provider.of<ReplyProvider>(
                                context,
                                listen: false);
                            isReplying.addMessageToReply(userName, message, id);
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Messages.isImageLink(message)
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(
                                            Messages.extractFirstUrl(message)!,
                                            //width: screenWidth * 0.3,
                                            //height: screenWidth * 0.3,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : SelectableLinkify(
                                        onOpen: (url) async {
                                          await launchUrlString(url.url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        },
                                        text: message,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
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
                                              (ContextMenuButtonItem
                                                  buttonItem) {
                                            return buttonItem.type ==
                                                ContextMenuButtonType.cut;
                                          });
                                          return AdaptiveTextSelectionToolbar
                                              .buttonItems(
                                            anchors: editableTextState
                                                .contextMenuAnchors,
                                            buttonItems: buttonItems,
                                          );
                                        },
                                      ),
                                vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.bottomRight,
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
                                      )
                                    : const SizedBox(),
                              ],
                            ),
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
  final int id;
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
                                  textScaler: TextScaler.noScaling,
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
                          ],
                        ),
                        GestureDetector(
                          onDoubleTap: () {
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.sendMessage(json.encode({
                              "vote": {"message_id": id, "dir": 1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final isReplying = Provider.of<ReplyProvider>(
                                context,
                                listen: false);
                            isReplying.addMessageToReply(userName, message, id);
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Messages.isImageLink(message)
                                    ? Center(
                                        child: Padding(
                                          padding: const EdgeInsets.all(8.0),
                                          child: Image.network(
                                            Messages.extractFirstUrl(message)!,
                                            //width: screenWidth * 0.3,
                                            //height: screenWidth * 0.3,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                    : SelectableLinkify(
                                        onOpen: (url) async {
                                          await launchUrlString(url.url,
                                              mode: LaunchMode
                                                  .externalApplication);
                                        },
                                        text: message,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.primaryColor,
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
                                              (ContextMenuButtonItem
                                                  buttonItem) {
                                            return buttonItem.type ==
                                                ContextMenuButtonType.cut;
                                          });
                                          return AdaptiveTextSelectionToolbar
                                              .buttonItems(
                                            anchors: editableTextState
                                                .contextMenuAnchors,
                                            buttonItems: buttonItems,
                                          );
                                        },
                                      ),
                                vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.bottomRight,
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
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
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
                            big: false,
                          ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}

class TheirMessegeReply extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int id;
  final String createdAt;
  final int ownerId;
  final String avatar;
  final String userName;
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;
  final int idReturn;

  const TheirMessegeReply(
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
      required this.roomName,
      required this.idReturn});

  @override
  Widget build(BuildContext context) {
    final listMessages = ListMessages();
    final replyingMessage =
        Messages.findById(listMessages.listMessages, idReturn);
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
                            big: false,
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
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.sendMessage(json.encode({
                              "vote": {"message_id": id, "dir": 1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final isReplying = Provider.of<ReplyProvider>(
                                context,
                                listen: false);
                            isReplying.addMessageToReply(userName, message, id);
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final position = Messages.findPositionById(
                                        listMessages.listMessages, idReturn);
                                    if (position != null) {
                                      final isReplying =
                                          Provider.of<ReplyProvider>(context,
                                              listen: false);
                                      isReplying.scrollToMessage(position);
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        replyingMessage.userName,
                                        textScaler: TextScaler.noScaling,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.shadowColor
                                              .withOpacity(0.9),
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w400,
                                          height: 1.30,
                                        ),
                                      ),
                                      Messages.isImageLink(
                                              replyingMessage.message)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Image.network(
                                                Messages.extractFirstUrl(
                                                    replyingMessage.message)!,
                                                //width: screenWidth * 0.3,
                                                height: 32,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Text(
                                              replyingMessage.message,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textScaler: TextScaler.noScaling,
                                              style: TextStyle(
                                                color: themeProvider
                                                    .currentTheme.primaryColor
                                                    .withOpacity(0.6),
                                                fontSize: 14,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                                height: 1.30,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 4),
                                  child: Container(
                                    height: 2,
                                    color:
                                        themeProvider.currentTheme.shadowColor,
                                  ),
                                ),
                                SelectableLinkify(
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
                                vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.bottomRight,
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
                                      )
                                    : const SizedBox(),
                              ],
                            ),
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

class MyMessegeReply extends StatelessWidget {
  final double screenWidth;
  final String message;
  final int id;
  final String createdAt;
  final int ownerId;
  final String avatar;
  final String userName;
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;
  final int idReturn;

  const MyMessegeReply(
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
      required this.roomName,
      required this.idReturn});

  @override
  Widget build(BuildContext context) {
    final listMessages = ListMessages();
    final replyingMessage =
        Messages.findById(listMessages.listMessages, idReturn);
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
                                  textScaler: TextScaler.noScaling,
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
                          ],
                        ),
                        GestureDetector(
                          onDoubleTap: () {
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            provider?.sendMessage(json.encode({
                              "vote": {"message_id": id, "dir": 1}
                            }));
                            HapticFeedback.lightImpact();
                          },
                          onHorizontalDragEnd: (_) {
                            final isReplying = Provider.of<ReplyProvider>(
                                context,
                                listen: false);
                            isReplying.addMessageToReply(userName, message, id);
                            HapticFeedback.lightImpact();
                          },
                          child: Container(
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
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                GestureDetector(
                                  onTap: () {
                                    final position = Messages.findPositionById(
                                        listMessages.listMessages, idReturn);
                                    if (position != null) {
                                      final isReplying =
                                          Provider.of<ReplyProvider>(context,
                                              listen: false);
                                      isReplying.scrollToMessage(position);
                                    }
                                  },
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        replyingMessage.userName,
                                        textScaler: TextScaler.noScaling,
                                        style: TextStyle(
                                          color: themeProvider
                                              .currentTheme.shadowColor
                                              .withOpacity(0.9),
                                          fontSize: 14,
                                          fontFamily: 'Manrope',
                                          fontWeight: FontWeight.w400,
                                          height: 1.30,
                                        ),
                                      ),
                                      Messages.isImageLink(
                                              replyingMessage.message)
                                          ? Padding(
                                              padding:
                                                  const EdgeInsets.all(1.0),
                                              child: Image.network(
                                                Messages.extractFirstUrl(
                                                    replyingMessage.message)!,
                                                //width: screenWidth * 0.3,
                                                height: 40,
                                                fit: BoxFit.cover,
                                              ),
                                            )
                                          : Text(
                                              replyingMessage.message,
                                              maxLines: 3,
                                              overflow: TextOverflow.ellipsis,
                                              textScaler: TextScaler.noScaling,
                                              style: TextStyle(
                                                color: themeProvider
                                                    .currentTheme.primaryColor
                                                    .withOpacity(0.6),
                                                fontSize: 14,
                                                fontFamily: 'Manrope',
                                                fontWeight: FontWeight.w400,
                                                height: 1.30,
                                              ),
                                            ),
                                    ],
                                  ),
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.only(top: 4, bottom: 4),
                                  child: Container(
                                    height: 2,
                                    color:
                                        themeProvider.currentTheme.shadowColor,
                                  ),
                                ),
                                SelectableLinkify(
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
                                vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.bottomRight,
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
                                      )
                                    : const SizedBox(),
                              ],
                            ),
                          ),
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
                            big: false,
                          ),
                  ),
                ]),
          ),
        );
      },
    );
  }
}
