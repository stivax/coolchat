import 'package:coolchat/model/token.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../servises/token_repository.dart';
import 'token_event.dart';
import 'token_state.dart';

class TokenBloc extends Bloc<TokenEvent, TokenState> {
  final TokenRepository tokenRepository;
  TokenBloc({required this.tokenRepository}) : super(TokenEmptyState()) {
    on<TokenLoadEvent>(
      (event, emit) async {
        try {
          final Token token =
              await tokenRepository.getToken(event.email, event.password);
          emit(TokenLoadedState(token: token));
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
