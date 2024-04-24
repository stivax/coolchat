import 'package:http/http.dart' as http;

class Server {
  static const String server = 'cool-chat.club';
  static const String suffix = 'api';

  static Future<bool> checkConnection() async {
    var response = await http.get(Uri.https(server));
    if (response.statusCode != 200) {
      response = await http.get(Uri.https(server));
    }
    if (response.statusCode != 200) {
      response = await http.get(Uri.https(server));
    }
    return response.statusCode == 200;
  }
}
