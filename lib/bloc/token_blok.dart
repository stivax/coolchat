import 'package:coolchat/message_provider.dart';
import 'package:coolchat/model/token.dart';
import 'package:coolchat/server/server.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../servises/token_repository.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;
  final server = Server.server;
  TokenBloc({required this.tokenRepository}) : super(TokenEmptyState()) {
    on<TokenLoadEvent>(
      (event, emit) async {
        try {
          final Token token =
              await tokenRepository.getToken(event.email, event.password);
          final MessageProvider messageProvider = MessageProvider(
              'wss://$server/ws/${event.roomName}?token=${token.token["access_token"]}');
          emit(
              TokenLoadedState(token: token, messageProvider: messageProvider));
        } catch (_) {
          emit(TokenErrorState());
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
