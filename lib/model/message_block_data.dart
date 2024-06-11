import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

class MessagesBlockData {
  ItemScrollController _itemScrollController;
  bool _showWriting;
  bool _showArrowDown;
  int _countNewMessages;

  MessagesBlockData()
      : _itemScrollController = ItemScrollController(),
        _showWriting = false,
        _showArrowDown = false,
        _countNewMessages = 0;

  ItemScrollController get itemScrollController => _itemScrollController;
  bool get showWriting => _showWriting;
  bool get showArrowDown => _showArrowDown;
  int get countNewMessages => _countNewMessages;

  void addShowWrite() {
    _showWriting = true;
  }

  void removeShowWrite() {
    _showWriting = false;
  }

  void showingArrowDown(bool state) {
    _showArrowDown = state;
  }

  void addNewMessageInArrow() {
    _countNewMessages++;
  }

  void clearNewMessagessInArrow() {
    _countNewMessages = 0;
  }
}
