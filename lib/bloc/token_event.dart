import 'package:flutter/material.dart';

abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String? roomName;
  final String? type;

  TokenLoadEvent({required this.roomName, required this.type});
}

class TokenLoadFromGetEvent extends TokenEvent {
  final String? roomName;
  BuildContext context;

  TokenLoadFromGetEvent({
    required this.roomName,
    required this.context,
  });
}

class TokenClearEvent extends TokenEvent {}
