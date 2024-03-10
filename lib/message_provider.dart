import 'dart:async';
import 'dart:io';

class MessageProvider {
  final String serverUrl;
  late WebSocket _socket;
  bool _isConnected = false;

  MessageProvider._(this.serverUrl);

  static Future<MessageProvider> create(String serverUrl) async {
    final messageProvider = MessageProvider._(serverUrl);
    await messageProvider._connect();
    return messageProvider;
  }

  Future<void> _connect() async {
    const maxAttempts = 1;
    const delayBetweenAttempts = Duration(milliseconds: 5000);

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        _socket = await WebSocket.connect(serverUrl);
        _isConnected = true;
        print('Connected to $serverUrl');
        _socket.pingInterval =
            const Duration(seconds: 10); // Keep the connection alive
        break;
      } catch (e) {
        print('Error during connection: $e');
        if (attempt < maxAttempts) {
          await Future.delayed(delayBetweenAttempts);
          print('Reconnecting... Attempt $attempt');
        } else {
          print('Max attempts reached. Connection failed.');
          break;
        }
      }
    }
  }

  Future<void> reconnect() async {
    if (!_isConnected) {
      print('Reconnecting...');
      await _connect();
    }
  }

  void sendMessage(String message) {
    if (_isConnected) {
      print('Sending message: $message');
      _socket.add(message);
    } else {
      print('Not connected. Message not sent.');
    }
  }

  Stream<dynamic> get messagesStream => _socket.asBroadcastStream();

  bool get isConnected => _isConnected;

  set isConnected(bool value) {
    _isConnected = value;
  }

  void dispose() {
    _isConnected = false;
    _socket.close();
  }
}


/*import 'package:web_socket_channel/web_socket_channel.dart';

class MessageProvider {
  final String serverUrl;
  late WebSocketChannel channel;
  bool _isConnected = false;

  MessageProvider._(this.serverUrl);

  static Future<MessageProvider> create(String serverUrl) async {
    final messageProvider = MessageProvider._(serverUrl);
    await messageProvider._connect();
    return messageProvider;
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

  Future<void> reconnect() async {
    if (!_isConnected) {
      print('Reconnecting...');
      await _connect();
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
}*/
