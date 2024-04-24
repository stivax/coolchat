import 'package:coolchat/message_provider.dart';

class MessageProviderContainer {
  // Єдиний екземпляр класу
  static MessageProviderContainer? _instance;

  // Контейнер для зберігання об'єктів MessageProvider
  final Map<String, MessageProvider> _providerMap = {};

  // Приватний конструктор для заборони створення об'єктів ззовні
  MessageProviderContainer._();

  // Метод для отримання єдиного екземпляра
  static MessageProviderContainer get instance {
    _instance ??= MessageProviderContainer._();
    return _instance!;
  }

  // Метод для додавання MessageProvider до контейнера
  void addProvider(String key, MessageProvider provider) {
    _providerMap[key] = provider;
  }

  // Метод для отримання MessageProvider за ключем
  MessageProvider? getProvider(String key) {
    return _providerMap[key];
  }

  // Метод для видалення MessageProvider за ключем
  void removeProvider(String key) {
    _providerMap.remove(key);
  }
}
