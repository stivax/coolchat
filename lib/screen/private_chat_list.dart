import 'dart:convert';

import 'package:coolchat/account.dart';
import 'package:coolchat/animation_start.dart';
import 'package:coolchat/bloc/token_blok.dart';
import 'package:coolchat/menu.dart';
import 'package:coolchat/my_appbar.dart';
import 'package:coolchat/private_rooms.dart';
import 'package:coolchat/server/server.dart';
import 'package:coolchat/servises/message_provider_container.dart';
import 'package:coolchat/servises/token_provider.dart';
import 'package:coolchat/servises/token_repository.dart';
import 'package:coolchat/theme_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';

class PrivateChatList extends StatefulWidget {
  PrivateChatList({super.key});

  @override
  _PrivateChatListState createState() => _PrivateChatListState();
}

class _PrivateChatListState extends State<PrivateChatList> {
  final _scrollController = ScrollController();
  List<RoomPrivate> roomsList = [];
  final server = Server.server;
  late int id;
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
    fetchData(server);
  }

  getToken() async {
    final acc = await _readAccount();
    var tok = await loginProcess(context, acc.email, acc.password);
    setState(() {
      token = tok;
      id = acc.id;
    });
    fetchData(server);
  }

  Future<Account> _readAccount() async {
    Account acc = await readAccountFuture();
    return acc;
  }

  Future<http.Response> _getData(String server) async {
    final url = Uri.https(server, '/direct/$id');
    return await http.get(url);
  }

  Future<void> fetchData(String server) async {
    final account = await readAccountFuture();
    try {
      http.Response response = await _getData(server);
      if (response.statusCode == 200) {
        String responseBody = utf8.decode(response.bodyBytes);
        List<dynamic> jsonList = jsonDecode(responseBody);
        List<RoomPrivate> rooms =
            RoomPrivate.fromJsonList(jsonList, account).toList();
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
      home: MultiBlocProvider(
        providers: [
          BlocProvider<MenuBloc>(
            create: (context) => MenuBloc(),
          ),
          BlocProvider<TokenBloc>(
            create: (context) => TokenBloc(
              tokenRepository: context.read<TokenRepository>(),
            ),
          )
        ],
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
                      child: ChatPrivateListWidget(
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

class ChatPrivateListWidget extends StatelessWidget {
  final ScrollController scrollController;
  List<RoomPrivate> roomsList;
  ChatPrivateListWidget(
      {super.key, required this.scrollController, required this.roomsList});

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: scrollController,
      slivers: [
        Consumer<ThemeProvider>(
          builder: (context, themeProvider, child) {
            return SliverToBoxAdapter(
              child: SizedBox(
                width: double.infinity,
                child: Padding(
                  padding:
                      const EdgeInsets.only(left: 20, bottom: 5, right: 20),
                  child: Text(
                    'Your personal chats',
                    textScaler: const TextScaler.linear(0.97),
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

class ScrollRoomsList extends StatefulWidget {
  List<RoomPrivate> roomsList;
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
