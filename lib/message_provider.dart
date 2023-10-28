import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;

  MessageProvider(this.serverUrl) {
    channel = IOWebSocketChannel.connect(
      serverUrl,
    );
  }

  void sendMessage(String message) {
    channel.sink.add(message);
  }

  Stream<dynamic> get messagesStream => channel.stream;

  void dispose() {
    channel.sink.close();
  }
}
