abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String? roomName;

  TokenLoadEvent({required this.roomName});
}

class TokenClearEvent extends TokenEvent {}
