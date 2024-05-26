import 'package:flutter/material.dart';

class MyIcons {
  static final Map<String, IconData> _iconsMap = {
    'home': Icons.home,
    'settings': Icons.settings,
    'search': Icons.search,
    'favorite': Icons.favorite,
    'account_circle': Icons.account_circle,
    'alarm': Icons.alarm,
    'camera': Icons.camera,
    'chat': Icons.chat,
    'check': Icons.check,
    'close': Icons.close,
    'cloud': Icons.cloud,
    'delete': Icons.delete,
    'edit': Icons.edit,
    'email': Icons.email,
    'face': Icons.face,
    'file_download': Icons.file_download,
    'file_upload': Icons.file_upload,
    'flag': Icons.flag,
    'help': Icons.help,
    'info': Icons.info,
    'link': Icons.link,
    'lock': Icons.lock,
    'logout': Icons.logout,
    'menu': Icons.menu,
    'more_vert': Icons.more_vert,
    'notifications': Icons.notifications,
    'phone': Icons.phone,
    'photo': Icons.photo,
    'print': Icons.print,
    'save': Icons.save,
    'send': Icons.send,
    'share': Icons.share,
    'shopping_cart': Icons.shopping_cart,
    'star': Icons.star,
    'thumb_up': Icons.thumb_up,
    'update': Icons.update,
    'visibility': Icons.visibility,
    'volume_up': Icons.volume_up,
    'warning': Icons.warning,
    'wifi': Icons.wifi,
    'work': Icons.work,
    'build': Icons.build,
    'calendar_today': Icons.calendar_today,
    'call': Icons.call,
    'directions': Icons.directions,
    'done': Icons.done,
    'download': Icons.download,
    'favorite_border': Icons.favorite_border,
  };

  static IconData returnIconData(String icon) {
    return _iconsMap[icon] ?? Icons.help;
  }

  static List<IconData> getAllIcons() {
    return _iconsMap.values.toList();
  }

  static List<String> getAllIconNames() {
    return _iconsMap.keys.toList();
  }
}
