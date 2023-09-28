import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'register_popup.dart';
import 'common_chat.dart';
import 'themeProvider.dart';

class Room extends StatelessWidget {
  String name;
  int id;
  String createdAt;
  ImageProvider image;
  int countPeople;
  int countOnline;

  Room(
      {required this.name,
      required this.id,
      required this.createdAt,
      required this.image,
      required this.countPeople,
      required this.countOnline});

  static List<Room> fromJsonList(List<dynamic> jsonList) {
    return jsonList.map((json) {
      return Room(
        name: json['name_room'],
        id: json['id'],
        createdAt: json['created_at'],
        image: AssetImage('assets/images/room1.png'),
        countPeople: 10,
        countOnline: 5,
      );
    }).toList()
      ..add(Room(
        id: 999,
        name: 'Add room',
        image: AssetImage('assets/images/add_room_dark.jpg'),
        countPeople: 0,
        countOnline: 0,
        createdAt: '',
      ));
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        id == 999
            ? showPopupDialog(context)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CommonChatScreen(
                    topicName: name,
                    id: id,
                  ),
                ),
              );
      },
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return Container(
            height: 207,
            width: double.infinity,
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
                    padding: const EdgeInsets.only(top: 0, left: 0, right: 0),
                    child: Container(
                      padding: EdgeInsets.all(8.0),
                      width: double.infinity,
                      alignment: Alignment.bottomCenter,
                      decoration: ShapeDecoration(
                        image: DecorationImage(
                          image: id != 999
                              ? image
                              : themeProvider.isLightMode
                                  ? const AssetImage(
                                      'assets/images/add_room_light.jpg')
                                  : const AssetImage(
                                      'assets/images/add_room_dark.jpg'),
                          fit: BoxFit.cover,
                        ),
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.50,
                              color: themeProvider.currentTheme.shadowColor),
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(10),
                            topRight: Radius.circular(10),
                          ),
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Container(
                            child: id == 999
                                ? Image(
                                    image: themeProvider.isLightMode
                                        ? AssetImage(
                                            'assets/images/add_light.png')
                                        : AssetImage(
                                            'assets/images/add_dark.png'),
                                  )
                                : Container(),
                          ),
                          Text(
                            name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: id == 999
                                  ? themeProvider.currentTheme.primaryColor
                                  : Color(0xFFF5FBFF),
                              fontSize: 14,
                              fontFamily: 'Manrope',
                              fontWeight: FontWeight.w600,
                              height: 1.30,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                Expanded(
                  flex: 1,
                  child: Padding(
                    padding: const EdgeInsets.only(left: 0, right: 0),
                    child: Container(
                      alignment: Alignment.bottomCenter,
                      decoration: ShapeDecoration(
                        color: themeProvider.currentTheme.shadowColor,
                        shape: RoundedRectangleBorder(
                          side: BorderSide(
                              width: 0.50,
                              color: themeProvider.currentTheme.shadowColor),
                          borderRadius: const BorderRadius.only(
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
                                    countPeople.toString(),
                                    textAlign: TextAlign.center,
                                    style: const TextStyle(
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
                                          Image.asset(
                                              'assets/images/people.png'),
                                          Positioned(
                                            left: 13,
                                            top: 1,
                                            child: Container(
                                              width: 3,
                                              height: 3,
                                              decoration: const ShapeDecoration(
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
                                      countOnline.toString(),
                                      textAlign: TextAlign.center,
                                      style: const TextStyle(
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
    );
  }
}

void showPopupDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return RegisterDialog();
    },
  );
}
