import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';
import 'package:provider/provider.dart';
import 'themeProvider.dart';

enum MenuStatus { open, closed }

class MenuState extends Equatable {
  final MenuStatus status;

  const MenuState(this.status);

  @override
  List<Object> get props => [status];
}

abstract class MenuEvent extends Equatable {
  const MenuEvent();

  @override
  List<Object> get props => [];
}

class ToggleMenu extends MenuEvent {}

class MenuBloc extends Bloc<MenuEvent, MenuState> {
  MenuBloc() : super(const MenuState(MenuStatus.closed));

  @override
  Stream<MenuState> mapEventToState(MenuEvent event) async* {
    if (event is ToggleMenu) {
      yield state.status == MenuStatus.open
          ? const MenuState(MenuStatus.closed)
          : const MenuState(MenuStatus.open);
    }
  }
}

class MainDropdownMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return PopupMenuButton<String>(
              offset: const Offset(0, kToolbarHeight),
              onSelected: (value) {
                // Handle menu item selection here
                print("Selected: $value");
              },
              icon: Icon(Icons.menu_rounded,
                  color: themeProvider.currentTheme.primaryColor),
              itemBuilder: (context) => [
                PopupMenuItem<String>(
                  value: 'item1',
                  child: Text(
                    'Chat rooms',
                    style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item2',
                  child: Text(
                    'Personal chats',
                    style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item3',
                  child: Text(
                    'Setting',
                    style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor),
                  ),
                ),
                PopupMenuItem<String>(
                  value: 'item4',
                  child: Text(
                    'Rools of the chat',
                    style: TextStyle(
                        color: themeProvider.currentTheme.primaryColor),
                  ),
                ),
              ],
              //
              color: themeProvider.currentTheme.primaryColorDark,
              elevation: 8,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(8),
                    bottomRight: Radius.circular(8)),
              ),
            );
          },
        );
      },
    );
  }
}
