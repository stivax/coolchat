import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
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
            backgroundColor: Color(0xFF0F1E28),
            title: Row(
              children: [
                Image.asset('assets/images/logo.png'),
                SizedBox(width: 10),
                Container(
                  width: 50,
                  height: 35,
                  child: const Stack(
                    children: [
                      Positioned(
                        left: 0,
                        top: 0,
                        child: SizedBox(
                          width: 50,
                          height: 23,
                          child: Text(
                            'Team',
                            style: TextStyle(
                              color: Color(0xFFF5FBFF),
                              fontSize: 18,
                              fontFamily: 'Helvetica Neue',
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      Positioned(
                        left: 1,
                        top: 12,
                        child: SizedBox(
                          width: 50,
                          height: 23,
                          child: Text(
                            'Chat',
                            style: TextStyle(
                              color: Color(0xFFF5FBFF),
                              fontSize: 18,
                              fontFamily: 'Helvetica Neue',
                              fontWeight: FontWeight.w700,
                              letterSpacing: 0.06,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            leading: MainDropdownMenu(),
            actions: [
              Row(
                children: [
                  Switch(
                    inactiveThumbColor: Color(0xFF0F1E28),
                    activeColor: Color(0xFFF5FBFF),
                    splashRadius: 20,
                    activeThumbImage:
                        const AssetImage('assets/images/tema_dark.png'),
                    inactiveThumbImage:
                        const AssetImage('assets/images/tema_light.png'),
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
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20),
            child: Text(
              'Welcome every tourist to Teamchat',
              style: TextStyle(
                color: Color(0xFFF5FBFF),
                fontSize: 36,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.16,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20, top: 10),
            child: Text(
              'Chat about a wide variety of tourist equipment. Communicate, get good advice and choose!',
              style: TextStyle(
                color: Color(0xFFF5FBFF),
                fontSize: 16,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w400,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ChatListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final List<String> items = List<String>.generate(99, (i) => 'Chat $i');
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeaderWidget()),
        SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
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
          if (index < items.length) {
            return Column(
              children: [
                SizedBox(height: 5),
                Row(
                  children: [
                    ChatItemWidget(items: items, index: index * 2),
                    ChatItemWidget(items: items, index: index * 2 + 1),
                  ],
                ),
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
          child: GestureDetector(
        onTap: () {
          _playTapSound();
        },
        child: Container(
          width: 171,
          height: 207,
          decoration: const BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Color(0x660287DF),
                blurRadius: 8,
                offset: Offset(1, 1),
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
                            image: AssetImage('assets/images/tent.png'),
                            fit: BoxFit.cover,
                          ),
                          shape: RoundedRectangleBorder(
                            side: BorderSide(
                                width: 0.50, color: Color(0xFF0186DF)),
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
                          'Chat $index',
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
                            child: Stack(children: [
                              Image.asset('assets/images/people.png'),
                            ]),
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '$index',
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
                    const SizedBox(width: 90),
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
                                Image.asset('assets/images/people.png'),
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
        ),
      ));
    } else {
      return Expanded(
        child: Card(),
      );
    }
  }

  void _playTapSound() async {
    if (await Vibrate.canVibrate) {
      // Відтворюємо стандартний звук тапу
      Vibrate.vibrate();
    }
  }
}
