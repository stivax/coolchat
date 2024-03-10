import 'dart:convert';

import 'package:coolchat/account.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/messages.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/message_provider_container.dart';
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
          late final MessageProvider messageProvider;
          Account account = await readAccountFromStorage();
          token =
              await tokenRepository.getToken(account.email, account.password);
          messageProvider = await MessageProvider.create(
              'wss://$server/${event.type!}/${event.roomName!}?token=${token!.token["access_token"]}');
          //await messageProvider.channel.ready;
          MessageProviderContainer.instance
              .addProvider(event.roomName!, messageProvider);
          emit(TokenLoadedState(
              token: token!,
              messageProvider: messageProvider,
              account: account));
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
          var url = Uri.https(server, '/$suffix/messages/${event.roomName}');
          return await http.get(url);
        }

        Future<List<Messages>> fetchData() async {
          try {
            http.Response response = await getData();
            if (response.statusCode == 200) {
              String responseBody = utf8.decode(response.bodyBytes);
              List<dynamic> jsonList = jsonDecode(responseBody);
              messages = Messages.fromJsonList(
                      jsonList, event.context, event.roomName!, account.id)
                  .reversed
                  .toList();
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
