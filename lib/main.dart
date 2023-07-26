import 'package:flutter/material.dart';

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
  bool _isSwitched = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Cool Chat"),
        leading: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {
            // TODO: Дії при натисканні на кнопку меню
          },
        ),
        actions: [
          Switch(
            value: _isSwitched,
            onChanged: (bool newValue) {
              setState(() {
                _isSwitched = newValue;
              });
              // TODO: Дії при зміні перемикача
            },
          ),
        ],
      ),
      body: _chatList(),
    );
  }
}

Widget _chatList() {
  final List<String> items = List<String>.generate(100, (i) => 'Chat $i');
  return ListView.builder(
    itemCount: items.length ~/ 2,
    itemBuilder: (context, index) {
      return Row(
        children: [
          _chatItem(items, index * 2),
          _chatItem(items, index * 2 + 1),
        ],
      );
    },
  );
}

Widget _chatItem(items, index) {
  return Expanded(
    child: Card(
      child: ListTile(
        title: Text('${items[index]}',
            style: TextStyle(color: Colors.white),
            selectionColor: Colors.white),
        leading: Icon(Icons.insert_photo, color: Color(0xFF83C241)),
        trailing: Icon(Icons.keyboard_alt_rounded),
        tileColor: Color(0xFF2A2F24),
        onTap: () {},
      ),
    ),
  );
}
