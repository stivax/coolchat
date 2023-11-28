import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;

  MessageProvider(this.serverUrl) {
    print('connect $serverUrl');
    channel = IOWebSocketChannel.connect(serverUrl,
        pingInterval: const Duration(minutes: 1));
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
