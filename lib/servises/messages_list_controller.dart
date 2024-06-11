import 'dart:async';
import 'dart:convert';

import 'package:coolchat/members.dart';
import 'package:coolchat/model/messages.dart';
import 'package:coolchat/model/messages_list.dart';
import 'package:coolchat/servises/account_provider.dart';
import 'package:coolchat/servises/message_block_function_provider.dart';
import 'package:coolchat/servises/messages_list_provider.dart';
import 'package:coolchat/servises/socket_connect.dart';
import 'package:coolchat/servises/socket_connect_container.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class MessagesListController {
  BuildContext context;
  SocketConnect? providerInScreen;
  StreamSubscription? messageSubscription;
  String screenName;
  int screenId;
  AccountProvider accountProvider;
  ListMessages listMessages;
  bool private;

  MessagesListController(
      {required this.context,
      required this.providerInScreen,
      required this.messageSubscription,
      required this.screenName,
      required this.screenId,
      required this.accountProvider,
      required this.private})
      : listMessages = ListMessages();

  Future<void> messageListen() async {
    MessagesListProvider messagesListProvider =
        Provider.of<MessagesListProvider>(context, listen: false);
    MessagesBlockFunctionProvider messagesBlockFunctionProvider =
        Provider.of<MessagesBlockFunctionProvider>(context, listen: false);
    if (providerInScreen == null) {
      providerInScreen = SocketConnectContainer.instance
          .getProvider(private ? screenId.toString() : screenName)!;
      //await messageSubscription?.cancel();
      clearMessages(messagesListProvider, screenName);
      messageSubscription = providerInScreen!.messagesStream.listen(
        (event) async {
          print(event.toString());
          if (event.toString().startsWith('{"created_at"')) {
            formMessage(event.toString(), context, messagesListProvider,
                screenName, screenId, accountProvider);
          } else if (event.toString().startsWith('{"type":"active_users"')) {
            formMembersList(
                event.toString(), screenName, context, messagesListProvider);
          } else if (event.toString().startsWith('{"message":')) {
            clearMessagesWithNotify(messagesListProvider, screenName);
          } else if (event.toString().startsWith('{"type":')) {
            showWriting(screenName, messagesBlockFunctionProvider);
          }
        },
        onDone: () {
          print('onDone');
        },
        onError: (e) {
          print('onError');
        },
      );
    }
  }

  void formMessage(
      String responseBody,
      BuildContext context,
      MessagesListProvider messagesListProvider,
      String screenName,
      int screenId,
      AccountProvider accountProvider) {
    dynamic jsonMessage = jsonDecode(responseBody);
    Messages message = Messages.fromJsonMessage(
        jsonMessage,
        messagesListProvider.messages[screenName]!.previousMemberID,
        context,
        screenName,
        screenId,
        accountProvider.accountProvider.id,
        private);
    messagesListProvider.addPreviousMemberId(screenName, message.ownerId!);
    messagesListProvider.addMessageToList(screenName, message);
    listMessages.listMessages.add(message);
  }

  void clearMessagesWithNotify(
      MessagesListProvider messagesListProvider, String screenName) {
    messagesListProvider.removeMessageFromListWithNotify(screenName);
  }

  void clearMessages(
      MessagesListProvider messagesListProvider, String screenName) {
    messagesListProvider.removeMessageFromList(screenName);
  }

  void formMembersList(String responseBody, String screenName,
      BuildContext context, MessagesListProvider messagesListProvider) {
    dynamic jsonMemberList = jsonDecode(responseBody);
    Set<Member> membersList = Member.fromJsonSet(jsonMemberList, context);
    messagesListProvider.removeMembersFromList(screenName);
    messagesListProvider.addMembersToList(screenName, membersList);
  }

  void showWriting(String screenName,
      MessagesBlockFunctionProvider messagesBlockFunctionProvider) {
    messagesBlockFunctionProvider.showingWriting(screenName);
  }
}
