import 'package:coolchat/model/message_privat_push.dart';

class MessagePrivatePushContainer {
  // Сет об'єктів з класу MessagePrivatPush
  static final List<MessagePrivatPush> _messageList = [];

  // Приватний конструктор для заборони створення об'єктів ззовні
  MessagePrivatePushContainer._();

  // Метод для отримання єдиного екземпляра
  static final MessagePrivatePushContainer _instance =
      MessagePrivatePushContainer._();

  static MessagePrivatePushContainer get instance => _instance;

  // Статичний метод для додавання об'єкта з класу MessagePrivatPush до сета
  static void addObject(List<MessagePrivatPush> object) {
    _messageList.addAll(object);
  }

// Статичний метод для видалення об'єктів, чий час "старший" за 5 секунд
  static void removeObjects() {
    _messageList.clear();
  }

  // Статичний метод для перегляду сета з об'єктами класу MessagePrivatPush
  static List<MessagePrivatPush> viewList() {
    return _messageList;
  }

  static bool containsObject(MessagePrivatPush object) {
    return _messageList.contains(object);
  }
}
