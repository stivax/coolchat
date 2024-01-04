import 'package:coolchat/model/message_privat_push.dart';

class MessagePrivatePushContainer {
  // Сет об'єктів з класу MessagePrivatPush
  static final Set<MessagePrivatPush> _messageSet = {};

  // Приватний конструктор для заборони створення об'єктів ззовні
  MessagePrivatePushContainer._();

  // Метод для отримання єдиного екземпляра
  static final MessagePrivatePushContainer _instance =
      MessagePrivatePushContainer._();

  static MessagePrivatePushContainer get instance => _instance;

  // Статичний метод для додавання об'єкта з класу MessagePrivatPush до сета
  static void addObject(MessagePrivatPush object) {
    _messageSet.add(object);
  }

// Статичний метод для видалення об'єктів, чий час "старший" за 5 секунд
  static void removeOldObjects() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    _messageSet.removeWhere((object) {
      final objectTime = object.time ?? 0;
      final differenceInSeconds =
          (currentTime - objectTime) / 1000; // переведення мілісекунд у секунди

      return differenceInSeconds > 5;
    });
  }

  // Статичний метод для перегляду сета з об'єктами класу MessagePrivatPush
  static Set<MessagePrivatPush> viewSet() {
    return _messageSet;
  }
}
