import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:web_socket_channel/io.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;
  bool _isConnected = false;

  MessageProvider(this.serverUrl) {
    _connect();
  }

  Future<void> _connect() async {
    const maxAttempts = 5;
    const delayBetweenAttempts = Duration(milliseconds: 500);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        channel = WebSocketChannel.connect(Uri.parse(serverUrl));
        await channel.ready;
        _isConnected = true;
        print('Connected to $serverUrl');
        break;
      } catch (e) {
        print('Error during connection: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
          print('Reconnecting... Attempt $attempt');
        } else {
          print('Max attempts reached. Connection failed.');
        }
      }
    }
  }

  void reconnect() {
    if (!_isConnected) {
      print('Reconnecting...');
      _connect();
    }
  }

  void sendMessage(String message) {
    if (_isConnected) {
      print(message);
      channel.sink.add(message);
    } else {
      print('Not connected. Message not sent.');
    }
  }

  Stream<dynamic> get messagesStream => channel.stream;

  bool get isConnected => _isConnected;

  set setIsConnected(bool value) {
    _isConnected = value;
  }

  void dispose() {
    _isConnected = false;
    channel.sink.close();
  }
}
