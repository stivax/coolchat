import 'package:flutter/material.dart';

abstract class TokenEvent {}

class TokenLoadEvent extends TokenEvent {
  final String? screenName;
  final int? screenId;
  final String? type;

  TokenLoadEvent(
      {required this.screenName, required this.screenId, required this.type});
}

class TokenLoadFromGetEvent extends TokenEvent {
  final String? screenName;
  final int? screenId;
  BuildContext context;

  TokenLoadFromGetEvent({
    required this.screenName,
    required this.screenId,
    required this.context,
  });
}

class TokenClearEvent extends TokenEvent {}
