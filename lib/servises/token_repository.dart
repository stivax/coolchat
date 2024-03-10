import 'dart:async';

import 'package:coolchat/model/token.dart';
import 'package:coolchat/servises/token_container.dart';
import 'package:coolchat/servises/token_provider.dart';

class TokenRepository {
  final TokenProvider _tokenProvider = TokenProvider();

  Future<Token> getToken(emailUser, passwordUser) =>
      _tokenProvider.loginProcess(emailUser, passwordUser);

  void regetToken(emailUser, passwordUser) {
    Timer.periodic(const Duration(minutes: 20), (timer) async {
      final token = await getToken(emailUser, passwordUser);
      TokenContainer.addToken(token);
    });
  }
}
