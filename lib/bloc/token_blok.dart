import 'package:coolchat/account.dart';
import 'package:coolchat/message_provider.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../servises/token_repository.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;
  final server = Server.server;
  Token? token;
  TokenBloc({required this.tokenRepository}) : super(TokenEmptyState()) {
    on<TokenLoadEvent>(
      (event, emit) async {
        try {
          print('Begin create Token state');
          Account account = await readAccountFuture();
          print('Read account ${account.email}');
          await Server.checkConnection();
          token =
              await tokenRepository.getToken(account.email, account.password);
          print('token ${token!.token["access_token"]}');
          final MessageProvider messageProvider = MessageProvider(
              'wss://$server/ws/${event.roomName!}?token=${token!.token["access_token"]}');
          print('Create message provider ${messageProvider.serverUrl}');
          await messageProvider.channel.ready;
          MessageProviderContainer.instance
              .addProvider(event.roomName!, messageProvider);
          print('Save message provider to instance');
          emit(TokenLoadedState(
              token: token!,
              messageProvider: messageProvider,
              account: account));
        } catch (e) {
          print('Error $e');
          emit(TokenErrorState(
            error: e.toString(),
          ));
        }
      },
    );
    on<TokenClearEvent>(
      (event, emit) async {
        emit(TokenEmptyState());
      },
    );
  }
}
