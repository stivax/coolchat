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
        var error;
        const maxAttempts = 5;
        const delayBetweenAttempts = Duration(milliseconds: 500);
        for (int attempt = 1; attempt <= maxAttempts; attempt++) {
          try {
            late final MessageProvider messageProvider;
            Account account = await readAccountFuture();
            token =
                await tokenRepository.getToken(account.email, account.password);
            messageProvider = MessageProvider(
                'wss://$server/ws/${event.roomName!}?token=${token!.token["access_token"]}');
            await messageProvider.channel.ready;
            MessageProviderContainer.instance
                .addProvider(event.roomName!, messageProvider);
            emit(TokenLoadedState(
                token: token!,
                messageProvider: messageProvider,
                account: account));
            break;
          } catch (e) {
            print('Error $e');
            error = e;
            if (attempt < maxAttempts) {
              await Future.delayed(delayBetweenAttempts);
              print('Reconnecting... Attempt $attempt');
            } else {
              print('Max attempts reached. Connection failed.');
              emit(TokenErrorState(error: error));
            }
          }
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
