import 'dart:convert';

import 'package:coolchat/servises/token_provider.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

import 'account.dart';
import 'menu.dart';
import 'my_appbar.dart';
import 'theme_provider.dart';
import 'splashScreen.dart';
import 'rooms.dart';
import 'server_provider.dart';

void main() => runApp(
      ChangeNotifierProvider(
        create: (context) => ThemeProvider(),
        child: RepositoryProvider(
            create: (context) => TokenRepository(),
            child:
                const ServerProvider(server: 'cool-chat.club', child: MyApp())),
      ),
    );

final myHomePageStateKey = GlobalKey<_MyHomePageState>();

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final GlobalKey<ScaffoldMessengerState> scaffoldMessengerKey =
        GlobalKey<ScaffoldMessengerState>();

    return MaterialApp(
      scaffoldMessengerKey: scaffoldMessengerKey,
      theme: themeProvider.currentTheme,
      home: FutureBuilder(
        future: Future.delayed(const Duration(seconds: 3)),
        builder: (context, snapshot) {
          if (themeProvider.isThemeChange &&
              snapshot.connectionState == ConnectionState.waiting) {
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 100),
              child: SplashScreen(),
            );
          } else {
            return MyHomePage(key: myHomePageStateKey);
          }
        },
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key});

  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final _scrollController = ScrollController();
  List<Room> roomsList = [];
  late String server;
  late Map<dynamic, dynamic> token;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    getToken();
    requestPermissions();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    server = ServerProvider.of(context).server;
    fetchData(server);
  }

  getToken() async {
    final acc = await _readAccount();
    var tok = await loginProcess(context, acc.email, acc.password);
    setState(() {
      token = tok;
    });
  }

  Future<Account> _readAccount() async {
    Account acc = await readAccountFuture();
    return acc;
  }

  Future<http.Response> _getData(String server) async {
    final url = Uri.https(server, '/rooms/');
    return await http.get(url);
  }

  Future<void> fetchData(String server) async {
    print('fetch main');
    try {
      http.Response response = await _getData(server);
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

  void _onScroll() {
    // Отримуємо поточну позицію скролінгу
    double offset = _scrollController.position.pixels;
    // Отримуємо максимально можливий офсет (кінцеву позицію) скролінгу
    double maxOffset = _scrollController.position.maxScrollExtent;
    // Перевіряємо, чи користувач знаходиться внизу екрану (різниця між офсетом і максимально можливим офсетом дорівнює 0)
    if (offset >= maxOffset &&
        _scrollController.position.userScrollDirection ==
            ScrollDirection.reverse) {
      // Викликаємо ваш метод при спробі скролити вниз, коли вже знаходишся внизу
      _handleScrollDown();
    }
  }

  void _handleScrollDown() {
    fetchData(server);
  }

  Future<void> requestPermissions() async {
    final storagePermission = await Permission.storage.request();

    if (storagePermission.isGranted) {
    } else {}
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
                      child: ChatListWidget(
                        scrollController: _scrollController,
                        roomsList: roomsList,
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
  }
}

class ChatListWidget extends StatelessWidget {
  final ScrollController scrollController;
  List<Room> roomsList;
  ChatListWidget(
      {super.key, required this.scrollController, required this.roomsList});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        const SliverToBoxAdapter(child: HeaderWidget()),
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
        ScrollRoomsList(
          roomsList: roomsList,
        ),
        const SliverToBoxAdapter(
            child: SizedBox(height: 8, width: double.infinity)),
      ],
    );
  }
}

class HeaderWidget extends StatelessWidget {
  const HeaderWidget({super.key});

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
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Text(
              'Welcome every\ntourist to Teamchat',
              textScaleFactor: 0.97,
              style: TextStyle(
                color: const Color(0xFFF5FBFF),
                fontSize: screenWidth * 0.095,
                fontFamily: 'Manrope',
                fontWeight: FontWeight.w700,
                height: 1.16,
              ),
            ),
          ),
          Padding(
            padding:
                const EdgeInsets.only(left: 20, bottom: 20, top: 10, right: 20),
            child: Text(
              'Chat about a wide variety of tourist equipment.\nCommunicate, get good advice and choose!',
              textScaleFactor: 0.97,
              style: TextStyle(
                color: const Color(0xFFF5FBFF),
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
  List<Room> roomsList;
  ScrollRoomsList({super.key, required this.roomsList});

  @override
  State<ScrollRoomsList> createState() => _ScrollRoomsListState();
}

class _ScrollRoomsListState extends State<ScrollRoomsList> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: const EdgeInsets.all(16.0),
      sliver: SliverGrid(
        delegate: SliverChildBuilderDelegate(
          (context, index) => widget.roomsList[index],
          childCount: widget.roomsList.length,
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
