import '../model/token.dart';

abstract class TokenState {}

class TokenEmptyState extends TokenState {}

class TokenLoadingState extends TokenState {}

class TokenLoadedState extends TokenState {
  Token token;
  TokenLoadedState({
    required this.token,
  });
}

class TokenErrorState extends TokenState {}
