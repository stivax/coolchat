// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:coolchat/account.dart';
import 'package:coolchat/servises/message_provider.dart';
import 'package:coolchat/model/messages.dart';

import '../model/token.dart';

abstract class TokenState {}

class TokenEmptyState extends TokenState {
  final List<Messages> messagesList;
  TokenEmptyState({
    required this.messagesList,
  });
}

class TokenLoadingState extends TokenState {}

class TokenLoadedState extends TokenState {
  final Token token;
  final MessageProvider messageProvider;
  final Account account;
  TokenLoadedState({
    required this.token,
    required this.messageProvider,
    required this.account,
  });
}

class TokenErrorState extends TokenState {
  final String error;
  TokenErrorState({
    required this.error,
  });
}
