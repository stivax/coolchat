import 'package:coolchat/model/token.dart';
import 'package:coolchat/servises/token_provider.dart';

class TokenRepository {
  final TokenProvider _tokenProvider = TokenProvider();
  Future<Token> getToken(emailUser, passwordUser) =>
      _tokenProvider.loginProcess(emailUser, passwordUser);
}
