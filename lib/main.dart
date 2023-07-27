import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'menu.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _themeMode = false;
  bool _langMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MenuBloc(),
        child: Scaffold(
          appBar: AppBar(
            title: Text("Cool Chat"),
            leading: MainDropdownMenu(),
            actions: [
              Row(
                children: [
                  Switch(
                    activeColor: Colors.red,
                    activeTrackColor: Colors.amber,
                    value: _themeMode,
                    onChanged: (bool newValue) {
                      setState(() {
                        _themeMode = newValue;
                      });
                      // TODO: Дії при зміні перемикача
                    },
                  ),
                  Switch(
                    value: _langMode,
                    onChanged: (bool newValue) {
                      setState(() {
                        _langMode = newValue;
                      });
                      // TODO: Дії при зміні перемикача
                    },
                  ),
                ],
              ),
            ],
          ),
          body: Column(
            children: [
              HeaderWidget(),
              Expanded(child: ChatListWidget()),
            ],
          ),
        ),
      ),
    );
  }
}

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: 150,
      color: Colors.blue,
      child: const Text(
        'Welcome to Cool Chat',
        style: TextStyle(fontSize: 24, color: Colors.white),
      ),
    );
  }
}

class ChatListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(99, (i) => 'Chat $i');
    return Column(
      children: [
        const Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'Choose room for communication',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: items.length ~/ 2 + 1,
            itemBuilder: (context, index) {
              return Row(
                children: [
                  ChatItemWidget(items: items, index: index * 2),
                  ChatItemWidget(items: items, index: index * 2 + 1),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChatItemWidget extends StatelessWidget {
  final List<String> items;
  final int index;

  ChatItemWidget({required this.items, required this.index});

  @override
  Widget build(BuildContext context) {
    if (index < items.length) {
      return Expanded(
        child: Card(
          color: Colors.amber,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Container(
                  height: 150,
                  color: Colors.grey,
                  child: ListTile(
                    title: Text(
                      '${items[index]}',
                      style: TextStyle(color: Colors.black),
                      selectionColor: Colors.black,
                    ),
                    onTap: () {},
                  ),
                ),
              ),
              Container(
                height: 50,
                child: const Row(
                  verticalDirection: VerticalDirection.up,
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Text(
                      'Logo1',
                      style: TextStyle(color: Colors.black),
                      selectionColor: Colors.black,
                    ),
                    Text(
                      'Logo2',
                      style: TextStyle(color: Colors.black),
                      selectionColor: Colors.black,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    } else {
      return Expanded(
        child: Card(),
      );
    }
  }
}
