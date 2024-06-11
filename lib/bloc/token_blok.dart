import 'dart:convert';

import 'package:coolchat/account.dart';
import 'package:coolchat/servises/socket_connect.dart';
import 'package:coolchat/model/messages.dart';
import 'package:coolchat/model/messages_list.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/socket_connect_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;

import '../servises/token_repository.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;
  final server = Server.server;
  final suffix = Server.suffix;
  Token? token;
  TokenBloc({required this.tokenRepository}) : super(TokenLoadingState()) {
    on<TokenLoadEvent>(
      (event, emit) async {
        var error;
        try {
          late final SocketConnect socketConnect;
          Account account = await readAccountFromStorage();
          token =
              await tokenRepository.getToken(account.email, account.password);
          socketConnect = await SocketConnect.create(
              'wss://$server/${event.type!}/${event.screenName!}?token=${token!.token["access_token"]}');
          SocketConnectContainer.instance
              .addProvider(event.screenName!, socketConnect);
          emit(TokenLoadedState(
              token: token!, socketConnect: socketConnect, account: account));
        } catch (e) {
          error = e;
          emit(TokenErrorState(error: error));
        }
      },
    );
    on<TokenLoadFromGetEvent>(
      (event, emit) async {
        List<Messages> messages = [];
        List<Messages> messagesLoaded = [];
        Account account = await readAccountFromStorage();
        Future<http.Response> getData() async {
          var url = Uri.https(server, '/$suffix/messages/${event.screenName}');
          return await http.get(url);
        }

        Future<List<Messages>> fetchData() async {
          try {
            http.Response response = await getData();
            if (response.statusCode == 200) {
              String responseBody = utf8.decode(response.bodyBytes);
              List<dynamic> jsonList = jsonDecode(responseBody);
              messages = Messages.fromJsonList(jsonList, event.context,
                      event.screenName!, event.screenId!, account.id, false)
                  .reversed
                  .toList();
              final ListMessages listMessages = ListMessages();
              listMessages.listMessages = messages;
            }
          } catch (error) {}
          return messages;
        }

        messagesLoaded = await fetchData();
        emit(TokenEmptyState(
          messagesList: messagesLoaded,
        ));
      },
    );
    on<TokenClearEvent>(
      (event, emit) {
        emit(TokenLoadingState());
      },
    );
  }
}
