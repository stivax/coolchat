import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;

  MessageProvider(this.serverUrl) {
    channel = IOWebSocketChannel.connect(serverUrl);
  }

  // Метод для відправлення повідомлення через сокет
  void sendMessage(String message) {
    channel.sink.add(message);
  }

  // Метод для слухання вхідних повідомлень з сокет-сервера
  Stream<dynamic> get messagesStream => channel.stream;

  // Не забудьте закрити з'єднання при завершенні використання
  void dispose() {
    channel.sink.close();
  }
}
