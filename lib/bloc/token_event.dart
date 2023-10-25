abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String email;
  final String password;

  TokenLoadEvent({required this.email, required this.password});
}

class TokenClearEvent extends TokenEvent {}
