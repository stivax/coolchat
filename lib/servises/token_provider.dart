import 'dart:convert';

import 'package:coolchat/model/token.dart';
import 'package:http/http.dart' as http;

import '../account.dart';
import '../server/server.dart';

class TokenProvider {
  Future<Token> loginProcess(String emailUser, String passwordUser) async {
    String email = Uri.encodeComponent(emailUser);
    String password = Uri.encodeComponent(passwordUser);
    String server = Server.server;

    String body = 'username=$email&password=$password';

    try {
      final response = await http.post(
        Uri.https(server, '/login'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
        },
        body: body,
      );

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);

        return Token.tokenfromJson(responseData);
      } else {
        return Token(token: {});
      }
    } catch (error) {
      return Token(token: {});
    }
  }
}
