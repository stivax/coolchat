import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;

  MessageProvider(this.serverUrl) {
    try {
      channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      print('connect to $serverUrl');
    } catch (e) {
      channel = WebSocketChannel.connect(Uri.parse(serverUrl));
      print('connect with error $e to $serverUrl');
    }
  }

  void sendMessage(String message) {
    print(message);
    channel.sink.add(message);
  }

  Stream<dynamic> get messagesStream => channel.stream;

  void dispose() {
    channel.sink.close();
  }
}
