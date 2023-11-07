// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:coolchat/message_provider.dart';

import '../model/token.dart';

abstract class TokenState {}

class TokenEmptyState extends TokenState {}

class TokenLoadingState extends TokenState {}

class TokenLoadedState extends TokenState {
  final Token token;
  final MessageProvider messageProvider;
  TokenLoadedState({
    required this.token,
    required this.messageProvider,
  });
}

class TokenErrorState extends TokenState {}
