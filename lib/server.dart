import 'package:flutter/material.dart';

class ServerProvider extends InheritedWidget {
  final String server;

  const ServerProvider({
    super.key,
    required this.server,
    required Widget child,
  }) : super(child: child);

  @override
  bool updateShouldNotify(ServerProvider oldWidget) {
    return server != oldWidget.server;
  }

  static ServerProvider of(BuildContext context) {
    return context.dependOnInheritedWidgetOfExactType<ServerProvider>()!;
  }
}
