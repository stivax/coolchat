import 'package:coolchat/model/token.dart';

class TokenContainer {
  static Token _token = Token(token: {});

  TokenContainer._();

  static final TokenContainer _instance = TokenContainer._();

  static TokenContainer get instance => _instance;

  static void addToken(Token object) {
    _token = object;
  }

  static void removeToken() {
    _token = Token(token: {});
  }

  static Token viewToken() {
    return _token;
  }
}
