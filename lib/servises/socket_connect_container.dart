import 'package:coolchat/servises/socket_connect.dart';

class SocketConnectContainer {
  static SocketConnectContainer? _instance;
  final Map<String, SocketConnect> _providerMap = {};

  SocketConnectContainer._();

  static SocketConnectContainer get instance {
    _instance ??= SocketConnectContainer._();
    return _instance!;
  }

  void addProvider(String key, SocketConnect provider) {
    _providerMap[key] = provider;
  }

  SocketConnect? getProvider(String key) {
    return _providerMap[key];
  }

  void removeProvider(String key) {
    _providerMap.remove(key);
  }
}
