import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'formChatList.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'themeProvider.dart';
import 'splashScreen.dart';
import 'login_popup.dart';
import 'rooms.dart';

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
      home: FutureBuilder(
        future: Future.delayed(Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (themeProvider.isThemeChange &&
              snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedSwitcher(
              duration: Duration(milliseconds: 100),
              child: SplashScreen(),
            );
          } else {
            return MyHomePage();
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  @override
  void initState() {
    super.initState();
    requestPermissions();
  }

  Future<void> requestPermissions() async {
    // Запит дозволу на доступ до файлової системи (запис)
    final storagePermission = await Permission.storage.request();

    if (storagePermission.isGranted) {
      // Дозвіл отримано, ви можете виконувати дії, які потребують цього дозволу
    } else {
      // Ви не отримали необхідний дозвіл, обробіть це відповідно
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: BlocProvider(
        create: (context) => MenuBloc(),
        child: Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return Scaffold(
              appBar: MyAppBar(),
              body: Column(
                children: [
                  Expanded(
                    child: Container(
                      clipBehavior: Clip.antiAlias,
                      decoration: BoxDecoration(
                          color: themeProvider.currentTheme.primaryColorDark),
                      child: ChatListWidget(),
                    ),
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

class ChatListWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
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
                width: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 5, right: 20),
                  child: Text(
                    'Choose rooms for\ncommunication',
                    textScaleFactor: 0.97,
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
        ScrollRoomsList(),
        SliverToBoxAdapter(child: SizedBox(height: 8, width: double.infinity)),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var screenWidth = MediaQuery.of(context).size.width;
    return Container(
      width: 393,
      height: 428,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/main.jpg'),
          fit: BoxFit.cover,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsets.only(left: 20, right: 20),
            child: Text(
              'Welcome every\ntourist to Teamchat',
              textScaleFactor: 0.97,
              style: TextStyle(
                color: Color(0xFFF5FBFF),
                fontSize: screenWidth * 0.095,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.16,
              ),
            ),
          ),
          Padding(
            padding: EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
            child: Text(
              'Chat about a wide variety of tourist equipment.\nCommunicate, get good advice and choose!',
              textScaleFactor: 0.97,
              style: TextStyle(
                color: Color(0xFFF5FBFF),
                fontSize: screenWidth * 0.042,
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

class ScrollRoomsList extends StatefulWidget {
  @override
  State<ScrollRoomsList> createState() => _ScrollRoomsListState();
}

class _ScrollRoomsListState extends State<ScrollRoomsList> {
  List<Room> roomsList = [];

  @override
  void initState() {
    super.initState();
    fetchData();
  }

  Future<http.Response> _getData() async {
    var url = 'http://35.228.45.65:8000/rooms/';
    return await http.get(Uri.parse(url));
  }

  Future<void> fetchData() async {
    try {
      http.Response response = await _getData();
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<Room> rooms = Room.fromJsonList(jsonList).toList();
        if (mounted) {
          setState(() {
            roomsList = rooms;
          });
        }
      } else {}
      // ignore: empty_catches
    } catch (error) {}
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => roomsList[index],
          childCount: roomsList.length,
        ),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 16.0,
          mainAxisSpacing: 16.0,
          childAspectRatio: 0.826,
        ),
      ),
    );
  }
}

void showPopupDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return MyPopupDialog();
    },
  );
}
