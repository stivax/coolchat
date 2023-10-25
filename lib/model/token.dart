// ignore_for_file: public_member_api_docs, sort_constructors_first
class Token {
  Map<String, String> token;
  Token({
    required this.token,
  });

  factory Token.tokenfromJson(Map<String, dynamic> json) {
    final token = <String, String>{};

    token['access_token'] = json['access_token'];
    token['token_type'] = json['token_type'];

    return Token(token: token);
  }
}
