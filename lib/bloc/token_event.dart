import 'package:flutter/material.dart';

abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String? roomName;

  TokenLoadEvent({required this.roomName});
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
