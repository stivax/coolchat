abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String email;
  final String password;
  final String? roomName;

  TokenLoadEvent(
      {required this.email, required this.password, required this.roomName});
}

class TokenClearEvent extends TokenEvent {}
