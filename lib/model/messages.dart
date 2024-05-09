import 'dart:convert';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:coolchat/app_localizations.dart';
import 'package:coolchat/screen/image_view_screen.dart';
import 'package:coolchat/screen/video_player_screen.dart';
import 'package:coolchat/servises/audio_player.dart';
import 'package:coolchat/servises/message_provider.dart';
import 'package:coolchat/model/messages_list.dart';
import 'package:coolchat/servises/change_message_provider.dart';
import 'package:coolchat/servises/file_controller.dart';
import 'package:coolchat/servises/reply_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_linkify/flutter_linkify.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'package:coolchat/avatar.dart';
import 'package:coolchat/servises/message_provider_container.dart';

import '../theme_provider.dart';

// ignore: must_be_immutable
class Messages extends StatelessWidget {
  final String message;
  final int id;
  final DateTime createdAt;
  final String avatar;
  final String userName;
  final String? fileUrl;
  final int? ownerId;
  final bool isPreviousSameMember;
  final int vote;
  final BuildContext contextMessage;
  final String roomName;
  final int accountId;
  final int? idReturn;
  final bool edited;
  const Messages(
      {super.key,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.avatar,
      required this.userName,
      required this.fileUrl,
      required this.ownerId,
      required this.isPreviousSameMember,
      required this.vote,
      required this.contextMessage,
      required this.roomName,
      required this.accountId,
      required this.idReturn,
      required this.edited});

  static Messages fromJsonMessage(dynamic jsonMessage, int previousMemberID,
      BuildContext contextMessage, String roomName, int accountId) {
    bool isSameMember = jsonMessage['receiver_id'] == previousMemberID;
    final timeZone = DateTime.now().timeZoneOffset;

    return Messages(
      message: jsonMessage['message'] ?? '',
      id: jsonMessage['id'],
      createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
      avatar: jsonMessage['avatar'],
      userName: jsonMessage['user_name'],
      fileUrl: jsonMessage['fileUrl'],
      ownerId: jsonMessage['receiver_id'] ?? 0,
      isPreviousSameMember: isSameMember,
      vote: jsonMessage['vote'],
      idReturn: jsonMessage['id_return'],
      contextMessage: contextMessage,
      roomName: roomName,
      accountId: accountId,
      edited: jsonMessage['edited'],
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
        message: jsonMessage['message'] ?? '',
        id: jsonMessage['id'],
        createdAt: DateTime.parse(jsonMessage['created_at']).add(timeZone),
        avatar: jsonMessage['avatar'],
        userName: jsonMessage['user_name'],
        fileUrl: jsonMessage['fileUrl'],
        ownerId: jsonMessage['receiver_id'] ?? 0,
        isPreviousSameMember: isSameMember,
        vote: jsonMessage['vote'],
        idReturn: jsonMessage['id_return'],
        contextMessage: contextMessage,
        roomName: roomName,
        accountId: accountId,
        edited: jsonMessage['edited'],
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

  static Messages? findById(List<Messages> messagesList, int? searchId) {
    if (searchId != null) {
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
          fileUrl: null,
          ownerId: 0,
          isPreviousSameMember: true,
          vote: 0,
          contextMessage: messagesList.first.contextMessage,
          roomName: '',
          accountId: 0,
          idReturn: 0,
          edited: false);
    } else {
      return null;
    }
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
        r'(?:(?:https?|ftp):\/\/)?[^ \t\n\r]+?\.(jpg|jpeg|gif|png|webp)(\?.*)?$',
        caseSensitive: false);

    return imageLinkRegExp.hasMatch(text);
  }

  static String? extractFirstUrl(String text) {
    final RegExp urlRegExp =
        RegExp(r'https?:\/\/[^\s<>"]+', caseSensitive: false);

    final match = urlRegExp.firstMatch(text);

    return match?.group(0);
  }

  static String extractFileName(String url) {
    var uri = Uri.parse(url);
    if (uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.last;
    }
    return '';
  }

  static void showMenuMessageFunction(
      BuildContext contextMessage,
      ThemeProvider themeProvider,
      Offset tapPosition,
      int idMessage,
      String textMessage,
      MessageProvider? provider) async {
    var newTapPosition = Offset(tapPosition.dx,
        tapPosition.dy + MediaQuery.of(contextMessage).viewInsets.bottom);
    FocusScope.of(contextMessage).unfocus();
    await Future.delayed(const Duration(milliseconds: 100));
    showMenu(
      context: contextMessage,
      color: themeProvider.currentTheme.hintColor,
      position: RelativeRect.fromLTRB(
        newTapPosition.dx,
        newTapPosition.dy,
        newTapPosition.dx + 1,
        newTapPosition.dy + 1,
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
            print('delete message id $idMessage');
            provider?.sendMessage(json.encode({
              "delete_message": {"id": idMessage}
            }));
            HapticFeedback.lightImpact();
          },
          child: MediaQuery(
            data: MediaQuery.of(contextMessage)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              AppLocalizations.of(contextMessage).translate('message_delete'),
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
        PopupMenuItem(
          height: 36,
          onTap: () {
            final changer = Provider.of<ChangeMessageProvider>(contextMessage,
                listen: false);
            changer.addListener(() {
              _onChangeMessage(changer, provider);
            });
            changer.addListener(() {
              if (changer.wasChanged) {
                print('!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!');
              }
            });
            changer.beginChangeMessage(textMessage, idMessage);
          },
          child: MediaQuery(
            data: MediaQuery.of(contextMessage)
                .copyWith(textScaler: TextScaler.noScaling),
            child: Text(
              AppLocalizations.of(contextMessage).translate('message_edit'),
              style: TextStyle(
                color: themeProvider.currentTheme.primaryColor,
                fontSize: 16.0,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ),
      ],
      elevation: 8.0,
      shadowColor: themeProvider.currentTheme.cardColor,
    );
  }

  static void _onChangeMessage(
      ChangeMessageProvider changer, MessageProvider? provider) {
    if (changer.newMessage != null) {
      String newMessage = changer.newMessage!;
      int idMessage = changer.idMessage!;
      provider?.sendMessage(json.encode({
        "change_message": {"id": idMessage, "message": newMessage}
      }));
      changer.clearChangeMessage();
    }
    HapticFeedback.lightImpact();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    return accountId == ownerId
        ? MyMessegeReply(
            screenWidth: screenWidth,
            message: message,
            id: id,
            createdAt: formatTime(createdAt.toString()),
            ownerId: ownerId!,
            avatar: avatar,
            userName: userName,
            fileUrl: fileUrl,
            vote: vote,
            isPreviousSameMember: isPreviousSameMember,
            contextMessage: contextMessage,
            roomName: roomName,
            idReturn: idReturn,
            edited: edited)
        : TheirMessegeReply(
            screenWidth: screenWidth,
            message: message,
            id: id,
            createdAt: formatTime(createdAt.toString()),
            ownerId: ownerId!,
            avatar: avatar,
            userName: userName,
            fileUrl: fileUrl,
            vote: vote,
            isPreviousSameMember: isPreviousSameMember,
            contextMessage: contextMessage,
            roomName: roomName,
            idReturn: idReturn,
            edited: edited);
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
  final String? fileUrl;
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;
  final int? idReturn;
  final bool edited;

  const TheirMessegeReply(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      required this.fileUrl,
      required this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage,
      required this.roomName,
      required this.idReturn,
      required this.edited});

  @override
  Widget build(BuildContext context) {
    final listMessages = ListMessages();
    final Messages? replyingMessage =
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
                            isReplying.addMessageToReply(
                                userName, message, id, fileUrl);
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
                                replyingMessage != null
                                    ? MessagePartReply(
                                        listMessages: listMessages,
                                        idReturn: idReturn,
                                        replyingMessage: replyingMessage,
                                        themeProvider: themeProvider,
                                      )
                                    : Container(),
                                fileUrl != null
                                    ? MessagePartFile(
                                        fileUrl: fileUrl!,
                                        themeProvider: themeProvider)
                                    : Container(),
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
                                    : Container(),
                                message.isNotEmpty
                                    ? SelectableLinkify(
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
                                      )
                                    : Container(),
                                const SizedBox(
                                  height: 4,
                                ),
                                edited || vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            edited
                                                ? Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'message_edited'),
                                                    textScaler:
                                                        TextScaler.noScaling,
                                                    style: TextStyle(
                                                      color: themeProvider
                                                          .currentTheme
                                                          .primaryColor
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                      fontFamily: 'Manrope',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  )
                                                : Container(),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            vote != 0
                                                ? Container(
                                                    height: 16,
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          vote.toString(),
                                                          textScaler: TextScaler
                                                              .noScaling,
                                                          style: TextStyle(
                                                            color: themeProvider
                                                                .currentTheme
                                                                .primaryColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Manrope',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          'assets/images/like.png',
                                                          width: 16,
                                                          height: 16,
                                                          color: themeProvider
                                                              .currentTheme
                                                              .shadowColor,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      )
                                    : Container(),
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
  final String? fileUrl;
  final int vote;
  final bool isPreviousSameMember;
  final BuildContext contextMessage;
  final String roomName;
  final int? idReturn;
  final bool edited;

  const MyMessegeReply(
      {super.key,
      required this.screenWidth,
      required this.message,
      required this.id,
      required this.createdAt,
      required this.ownerId,
      required this.avatar,
      required this.userName,
      required this.fileUrl,
      required this.vote,
      required this.isPreviousSameMember,
      required this.contextMessage,
      required this.roomName,
      required this.idReturn,
      required this.edited});

  @override
  Widget build(BuildContext context) {
    final listMessages = ListMessages();
    final Messages? replyingMessage =
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
                          onTapUp: (details) {
                            HapticFeedback.lightImpact();
                            final provider = MessageProviderContainer.instance
                                .getProvider(roomName);
                            Messages.showMenuMessageFunction(
                                contextMessage,
                                themeProvider,
                                details.globalPosition,
                                id,
                                message,
                                provider);
                          },
                          onHorizontalDragEnd: (_) {
                            final isReplying = Provider.of<ReplyProvider>(
                                context,
                                listen: false);
                            isReplying.addMessageToReply(
                                userName, message, id, fileUrl);
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
                                replyingMessage != null
                                    ? MessagePartReply(
                                        listMessages: listMessages,
                                        idReturn: idReturn,
                                        replyingMessage: replyingMessage,
                                        themeProvider: themeProvider,
                                      )
                                    : Container(),
                                fileUrl != null
                                    ? MessagePartFile(
                                        fileUrl: fileUrl!,
                                        themeProvider: themeProvider)
                                    : Container(),
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
                                    : Container(),
                                message.isNotEmpty
                                    ? SelectableLinkify(
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
                                      )
                                    : Container(),
                                const SizedBox(
                                  height: 4,
                                ),
                                edited || vote != 0
                                    ? Container(
                                        height: 16,
                                        alignment: Alignment.centerRight,
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          children: [
                                            edited
                                                ? Text(
                                                    AppLocalizations.of(context)
                                                        .translate(
                                                            'message_edited'),
                                                    textScaler:
                                                        TextScaler.noScaling,
                                                    style: TextStyle(
                                                      color: themeProvider
                                                          .currentTheme
                                                          .primaryColor
                                                          .withOpacity(0.7),
                                                      fontSize: 12,
                                                      fontFamily: 'Manrope',
                                                      fontWeight:
                                                          FontWeight.w400,
                                                    ),
                                                  )
                                                : Container(),
                                            const SizedBox(
                                              width: 8,
                                            ),
                                            vote != 0
                                                ? Container(
                                                    height: 16,
                                                    alignment:
                                                        Alignment.bottomRight,
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .end,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment.end,
                                                      children: [
                                                        Text(
                                                          vote.toString(),
                                                          textScaler: TextScaler
                                                              .noScaling,
                                                          style: TextStyle(
                                                            color: themeProvider
                                                                .currentTheme
                                                                .primaryColor,
                                                            fontSize: 12,
                                                            fontFamily:
                                                                'Manrope',
                                                            fontWeight:
                                                                FontWeight.w400,
                                                          ),
                                                        ),
                                                        Image.asset(
                                                          'assets/images/like.png',
                                                          width: 16,
                                                          height: 16,
                                                          color: themeProvider
                                                              .currentTheme
                                                              .shadowColor,
                                                        )
                                                      ],
                                                    ),
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      )
                                    : Container(),
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

class MessagePartReply extends StatelessWidget {
  final ListMessages listMessages;
  final Messages replyingMessage;
  final ThemeProvider themeProvider;
  final int? idReturn;

  const MessagePartReply(
      {super.key,
      required this.listMessages,
      required this.replyingMessage,
      required this.themeProvider,
      required this.idReturn});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        final position =
            Messages.findPositionById(listMessages.listMessages, idReturn!);
        if (position != null) {
          final isReplying = Provider.of<ReplyProvider>(context, listen: false);
          isReplying.scrollToMessage(position);
        }
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            replyingMessage.userName,
            textScaler: TextScaler.noScaling,
            style: TextStyle(
              color: themeProvider.currentTheme.shadowColor.withOpacity(0.9),
              fontSize: 14,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w400,
              height: 1.30,
            ),
          ),
          replyingMessage.fileUrl != null
              ? Messages.isImageLink(replyingMessage.fileUrl!)
                  ? Padding(
                      padding: const EdgeInsets.only(top: 8, bottom: 8),
                      child: CachedNetworkImage(
                        imageUrl: replyingMessage.fileUrl!,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                          color: themeProvider.currentTheme.shadowColor,
                        )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        height: 40,
                      ),
                    )
                  : Opacity(
                      opacity: 0.7,
                      child: Padding(
                        padding: const EdgeInsets.only(top: 8, bottom: 8),
                        child: Row(
                          children: [
                            Icon(
                              Icons.file_copy,
                              color: themeProvider.currentTheme.shadowColor,
                              size: 24,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                  Messages.extractFileName(
                                      replyingMessage.fileUrl!),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(
                                    color:
                                        themeProvider.currentTheme.primaryColor,
                                    fontSize: 14,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  )),
                            ),
                          ],
                        ),
                      ),
                    )
              : Container(),
          replyingMessage.message.isNotEmpty
              ? Messages.isImageLink(replyingMessage.message)
                  ? Padding(
                      padding: const EdgeInsets.all(1.0),
                      child: CachedNetworkImage(
                        imageUrl:
                            Messages.extractFirstUrl(replyingMessage.message)!,
                        height: 40,
                        placeholder: (context, url) => Center(
                            child: CircularProgressIndicator(
                          color: themeProvider.currentTheme.shadowColor,
                        )),
                        errorWidget: (context, url, error) =>
                            const Icon(Icons.error),
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      replyingMessage.message,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor
                            .withOpacity(0.6),
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                        height: 1.30,
                      ),
                    )
              : Container(),
          Padding(
            padding: const EdgeInsets.only(top: 4, bottom: 4),
            child: Container(
              height: 2,
              color: themeProvider.currentTheme.shadowColor,
            ),
          )
        ],
      ),
    );
  }
}

class MessagePartFile extends StatefulWidget {
  final String fileUrl;
  final ThemeProvider themeProvider;

  const MessagePartFile(
      {super.key, required this.fileUrl, required this.themeProvider});

  @override
  State<MessagePartFile> createState() => _MessagePartFileState();
}

class _MessagePartFileState extends State<MessagePartFile> {
  double progress = 0.00001;
  bool receving = false;
  bool fileInCache = false;

  @override
  void initState() {
    findFileInCache(widget.fileUrl);
    super.initState();
  }

  findFileInCache(String? fileUrl) async {
    if (fileUrl != null) {
      final isFinded = await FileController.doesFileExistInCache(fileUrl);
      setState(() {
        fileInCache = isFinded;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (Messages.isImageLink(widget.fileUrl)) {
      return Padding(
        padding: const EdgeInsets.all(8.0),
        child: InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => ImageViewScreen(
                  fileSend: false,
                  imageUrl: widget.fileUrl,
                ),
              ),
            );
          },
          child: CachedNetworkImage(
            imageUrl: widget.fileUrl,
            placeholder: (context, url) => Center(
                child: CircularProgressIndicator(
              color: widget.themeProvider.currentTheme.shadowColor,
            )),
            errorWidget: (context, url, error) => const Icon(Icons.error),
          ),
        ),
      );
    } else {
      if (!fileInCache) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: GestureDetector(
            onTap: () async {
              final downloader = FileController();
              setState(() {
                receving = true;
              });
              await downloader.downloadFile(widget.fileUrl,
                  onProgress: (int receive, int total) {
                setState(() {
                  progress = receive / 1000000;
                  print(progress);
                });
              });
              setState(() {
                receving = false;
                findFileInCache(widget.fileUrl);
              });
            },
            child: receving
                ? Row(
                    children: [
                      SizedBox(
                        height: 24,
                        width: 24,
                        child: Center(
                          child:
                              Text('${progress.toString().substring(0, 4)}\nMB',
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                  textScaler: TextScaler.noScaling,
                                  style: TextStyle(
                                    color: widget.themeProvider.currentTheme
                                        .primaryColor,
                                    fontSize: 8,
                                    fontFamily: 'Manrope',
                                    fontWeight: FontWeight.w400,
                                  )),
                        ),
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(Messages.extractFileName(widget.fileUrl),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: widget
                                  .themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            )),
                      ),
                    ],
                  )
                : Row(
                    children: [
                      Image.asset('assets/images/icon_download.png',
                          color: widget.themeProvider.currentTheme.shadowColor,
                          height: 24,
                          width: 24),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(Messages.extractFileName(widget.fileUrl),
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            textScaler: TextScaler.noScaling,
                            style: TextStyle(
                              color: widget
                                  .themeProvider.currentTheme.primaryColor,
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w400,
                            )),
                      ),
                    ],
                  ),
          ),
        );
      } else {
        if (FileController.isAacFileName(widget.fileUrl)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: Row(
              children: [
                AudioPlayerWidget(filePath: widget.fileUrl),
                const SizedBox(
                  width: 8,
                ),
                Expanded(
                  child: Text(Messages.extractFileName(widget.fileUrl),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      textScaler: TextScaler.noScaling,
                      style: TextStyle(
                        color: widget.themeProvider.currentTheme.primaryColor,
                        fontSize: 14,
                        fontFamily: 'Manrope',
                        fontWeight: FontWeight.w400,
                      )),
                ),
              ],
            ),
          );
        } else if (FileController.isVideoFileName(widget.fileUrl)) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => VideoPlayerPage(
                      videoPath: widget.fileUrl,
                      fileSend: false,
                    ),
                  ),
                );
              },
              child: Row(
                children: [
                  Icon(
                    Icons.video_camera_back,
                    color: widget.themeProvider.currentTheme.shadowColor,
                  ),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(Messages.extractFileName(widget.fileUrl),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: widget.themeProvider.currentTheme.primaryColor,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                ],
              ),
            ),
          );
        } else {
          return Padding(
            padding: const EdgeInsets.only(bottom: 8.0),
            child: GestureDetector(
              onTap: () {
                FileController.openFileFromCache(widget.fileUrl);
                HapticFeedback.lightImpact();
              },
              child: Row(
                children: [
                  Image.asset('assets/images/icon_open.png',
                      color: widget.themeProvider.currentTheme.shadowColor,
                      height: 24,
                      width: 24),
                  const SizedBox(
                    width: 8,
                  ),
                  Expanded(
                    child: Text(Messages.extractFileName(widget.fileUrl),
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        textScaler: TextScaler.noScaling,
                        style: TextStyle(
                          color: widget.themeProvider.currentTheme.primaryColor,
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w400,
                        )),
                  ),
                ],
              ),
            ),
          );
        }
      }
    }
  }
}
