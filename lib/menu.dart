import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

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
  MenuBloc() : super(MenuState(MenuStatus.closed));

  @override
  Stream<MenuState> mapEventToState(MenuEvent event) async* {
    if (event is ToggleMenu) {
      yield state.status == MenuStatus.open
          ? MenuState(MenuStatus.closed)
          : MenuState(MenuStatus.open);
    }
  }
}

// Dropdown Menu Widget

class MainDropdownMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<MenuBloc, MenuState>(
      builder: (context, state) {
        return PopupMenuButton<String>(
          offset: Offset(0, kToolbarHeight),
          onSelected: (value) {
            // Handle menu item selection here
            print("Selected: $value");
          },
          icon: Icon(Icons.menu),
          itemBuilder: (context) => [
            PopupMenuItem<String>(
              value: 'item1',
              child: Text('Chat rooms'),
            ),
            PopupMenuItem<String>(
              value: 'item2',
              child: Text('Personal chats'),
            ),
            PopupMenuItem<String>(
              value: 'item3',
              child: Text('Setting'),
            ),
            PopupMenuItem<String>(
              value: 'item4',
              child: Text('Rools of the chat'),
            ),
          ],
        );
      },
    );
  }
}