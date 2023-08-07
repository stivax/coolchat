import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:provider/provider.dart';
import 'menu.dart';
import 'themes.dart';
import 'themeProvider.dart';
import 'formChatList.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: MyApp(),
      ),
    );

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);

    return MaterialApp(
      theme: themeProvider.currentTheme,
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MenuBloc(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              appBar: AppBar(
                backgroundColor: themeProvider.currentTheme.primaryColorDark,
                title: Container(
                  width: 70,
                  height: 35,
                  child: Image(
                    image: themeProvider.isLightMode
                        ? AssetImage('assets/images/logo_light_tema.png')
                        : AssetImage('assets/images/logo_dark_tema.png'),
                  ),
                ),
                leading: MainDropdownMenu(),
                actions: [
                  Row(
                    children: [
                      GestureDetector(
                        onTap: () {
                          themeProvider.toggleTheme();
                        },
                        child: Image(
                          image: themeProvider.isLightMode
                              ? AssetImage('assets/images/toogle_light.png')
                              : AssetImage('assets/images/toogle_dark.png'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                      GestureDetector(
                        onTap: () {},
                        child: Image(
                          image: themeProvider.isLightMode
                              ? AssetImage('assets/images/lang_en_light.png')
                              : AssetImage('assets/images/lang_en_dark.png'),
                        ),
                      ),
                      const SizedBox(
                        width: 16,
                      ),
                    ],
                  ),
                ],
              ),
              body: Column(
                children: [
                  Consumer<ThemeProvider>(
                    builder: (context, themeProvider, child) {
                      return Expanded(
                        child: Container(
                          clipBehavior: Clip.antiAlias,
                          decoration: BoxDecoration(
                              color:
                                  themeProvider.currentTheme.primaryColorDark),
                          child: ChatListWidget(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            );
          },
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
            padding: EdgeInsets.only(left: 20, right: 20),
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
            padding: EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
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
    //   final List<String> items = List<String>.generate(9, (i) => 'Chat $i');
    List<ChatItem> items = formChatList();
    ChatItem addNewItem = addItem;
    return CustomScrollView(
      slivers: [
        SliverToBoxAdapter(child: HeaderWidget()),
        const SliverToBoxAdapter(
          child: SizedBox(height: 30),
        ),
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SliverToBoxAdapter(
              child: SizedBox(
                width: 361,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 5, right: 20),
                  child: Text(
                    'Choose rooms for communication',
                    style: TextStyle(
                      color: themeProvider.currentTheme.primaryColor,
                      fontSize: 24,
                      fontFamily: 'Manrope',
                      fontWeight: FontWeight.w500,
                      height: 1.24,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        scrollChatList(items),
      ],
    );
  }

  SliverList scrollChatList(List<ChatItem> items) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (BuildContext context, int index) {
          if (index < (items.length ~/ 2) + 0) {
            return Column(
              children: [
                Row(
                  children: [
                    const SizedBox(width: 8),
                    ChatItemWidget(
                        items: items, index: index * 2, id: items[index].id),
                    ChatItemWidget(
                        items: items,
                        index: index * 2 + 1,
                        id: items[index].id),
                    const SizedBox(width: 8),
                  ],
                ),
                const SizedBox(height: 8),
              ],
            );
          } else {
            return SizedBox.shrink();
          }
        },
        childCount: (items.length ~/ 2) + 2,
      ),
    );
  }
}

class ChatItemWidget extends StatelessWidget {
  final List<ChatItem> items;
  final int index;
  final int id;

  ChatItemWidget({required this.items, required this.index, required this.id});

  @override
  Widget build(BuildContext context) {
    if (index < items.length) {
      return Expanded(
        child: GestureDetector(
          onTap: () {
            _playTapSound();
          },
          child: Consumer<ThemeProvider>(
            builder: (context, themeProvider, child) {
              return Container(
                height: 207,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                      color: themeProvider.currentTheme.primaryColorDark,
                      blurRadius: 0,
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
                    Expanded(
                      flex: 5,
                      child: Padding(
                        padding:
                            const EdgeInsets.only(top: 8, left: 8, right: 8),
                        child: Container(
                          padding: EdgeInsets.all(8.0),
                          width: double.infinity,
                          alignment: Alignment.bottomCenter,
                          decoration: ShapeDecoration(
                            image: DecorationImage(
                              image: items[index].id != 999
                                  ? AssetImage(items[index].image)
                                  : themeProvider.isLightMode
                                      ? AssetImage(
                                          'assets/images/add_room_light.jpg')
                                      : AssetImage(
                                          'assets/images/add_room_dark.jpg'),
                              fit: BoxFit.cover,
                            ),
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50,
                                  color:
                                      themeProvider.currentTheme.shadowColor),
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(10),
                                topRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          child: Text(
                            items[index].name,
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
                    ),
                    Expanded(
                      flex: 1,
                      child: Padding(
                        padding: const EdgeInsets.only(
                            left: 8, right: 8, bottom: 0, top: 0),
                        child: Container(
                          alignment: Alignment.bottomCenter,
                          decoration: ShapeDecoration(
                            color: themeProvider.currentTheme.shadowColor,
                            shape: RoundedRectangleBorder(
                              side: BorderSide(
                                  width: 0.50,
                                  color:
                                      themeProvider.currentTheme.shadowColor),
                              borderRadius: BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                          ),
                          child: Center(
                            heightFactor: 0.5,
                            child: Container(
                              padding: EdgeInsets.only(left: 8, right: 8),
                              child: Row(
                                verticalDirection: VerticalDirection.down,
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    mainAxisSize: MainAxisSize.max,
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: 16,
                                        height: 16,
                                        clipBehavior: Clip.antiAlias,
                                        decoration: BoxDecoration(),
                                        child: Stack(children: [
                                          Image.asset(
                                              'assets/images/people.png'),
                                        ]),
                                      ),
                                      const SizedBox(width: 2),
                                      Text(
                                        items[index].countPeople.toString(),
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
                                  Expanded(
                                    child: Container(width: double.infinity),
                                  ),
                                  Container(
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 16,
                                          height: 16,
                                          clipBehavior: Clip.antiAlias,
                                          decoration: BoxDecoration(),
                                          child: Stack(
                                            children: [
                                              Image.asset(
                                                  'assets/images/people.png'),
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
                                          items[index].countOnline.toString(),
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
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      );
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
