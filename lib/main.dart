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
              Expanded(
                  child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(color: Color(0xFF0F1E28)),
                      child: ChatListWidget())),
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
      width: 393,
      height: 428,
      decoration: BoxDecoration(
        image: DecorationImage(
          image: NetworkImage("https://via.placeholder.com/393x428"),
          fit: BoxFit.cover,
        ),
      ),
    );
  }
}

class ChatListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(9, (i) => 'Chat $i');
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeaderWidget()),
        const SliverToBoxAdapter(
            child: SizedBox(
          width: 361,
          child: Text(
            'Choose rooms for communication',
            style: TextStyle(
              color: Color(0xFFF5FBFF),
              fontSize: 24,
              fontFamily: 'Manrope',
              fontWeight: FontWeight.w500,
              height: 1.24,
            ),
          ),
        )),
        scrollChatList(items),
      ],
    );
  }

  SliverList scrollChatList(List<String> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index < items.length ~/ 2 + 1) {
            return Row(
              children: [
                ChatItemWidget(items: items, index: index * 2),
                ChatItemWidget(items: items, index: index * 2 + 1),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
        childCount: (items.length ~/ 2) + 1,
      ),
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
          child: Container(
        width: 171,
        height: 212,
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Color(0x660287DF),
              blurRadius: 8,
              offset: Offset(2, 2),
              spreadRadius: 0,
            )
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              width: 171,
              height: 171,
              child: Stack(
                children: [
                  Positioned(
                    left: 0,
                    top: 0,
                    child: Container(
                      width: 171,
                      height: 171,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: NetworkImage(
                              "https://via.placeholder.com/171x171"),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          side:
                              BorderSide(width: 0.50, color: Color(0xFF0186DF)),
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    left: 27,
                    top: 133,
                    child: SizedBox(
                      width: 117,
                      child: Text(
                        'Tents, awnings, canopies',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Color(0xFFF5FBFF),
                          fontSize: 14,
                          fontFamily: 'Manrope',
                          fontWeight: FontWeight.w600,
                          height: 1.30,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 171,
              padding: const EdgeInsets.all(10),
              decoration: ShapeDecoration(
                color: Color(0xFF0186DF),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(10),
                    bottomRight: Radius.circular(10),
                  ),
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(children: []),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '4',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF5FBFF),
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 100),
                  Container(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          width: 16,
                          height: 16,
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(),
                          child: Stack(
                            children: [
                              Positioned(
                                left: 13,
                                top: 1,
                                child: Container(
                                  width: 3,
                                  height: 3,
                                  decoration: ShapeDecoration(
                                    color: Color(0xFFF5FBFF),
                                    shape: OvalBorder(),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 2),
                        Text(
                          '2',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Color(0xFFF5FBFF),
                            fontSize: 12,
                            fontFamily: 'Manrope',
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ));
    } else {
      return Expanded(
        child: Card(),
      );
    }
  }
}
