import 'dart:async';
import 'dart:io';

class SocketConnect {
  final String serverUrl;
  late WebSocket _socket;
  bool _isConnected = false;

  SocketConnect._(this.serverUrl);

  static Future<SocketConnect> create(String serverUrl) async {
    final socketConnect = SocketConnect._(serverUrl);
    await socketConnect._connect();
    return socketConnect;
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
    final messageForSend = message.trimRight();
    //print(messageForSend);
    if (messageForSend.isNotEmpty) {
      if (_isConnected) {
        //print('Sending message: $messageForSend');
        _socket.add(messageForSend);
      } else {
        //print('Not connected. Message not sent.');
      }
    } else {
      //print('Message empty');
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
