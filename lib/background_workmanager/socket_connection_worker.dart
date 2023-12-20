import 'dart:async';
import 'package:coolchat/account.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:workmanager/workmanager.dart';

void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    try {
      print('Callback dispatched');
      Account account = await readAccountFuture();
      TokenRepository tokenRepository = TokenRepository();
      Token token =
          await tokenRepository.getToken(account.email, account.password);
      const server = Server.server;
      final socket = MessageProvider(
          'wss://$server/notification?token=${token.token["access_token"]}');
      await Future.delayed(const Duration(milliseconds: 500));
      print('Callback dispatched connected ');
      final socketSubscription = socket.messagesStream.listen((message) async {
        print('Received: $message');
      });
      return Future.value(true);
    } catch (e, stackTrace) {
      print('Error in callbackDispatcher: $e');
      print('StackTrace: $stackTrace');
      return Future.value(false);
    }
  });
}
