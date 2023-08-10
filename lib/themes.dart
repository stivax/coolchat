import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark1 = Color(0xFF0F1E28);
  static const Color backgroundDark2 = Color(0xFF182A36);
  static const Color backgroundLight1 = Color(0xFFC5E6FD);
  static const Color backgroundLight2 = Color(0xFFF5FBFF);
  static const Color textDark = Color(0xFF0F1E28);
  static const Color textLight = Color(0xFFF5FBFF);
  static const Color decorElementDark = Color(0xFF0F1E28);
  static const Color decorElementBlue = Color(0xFF01497A);
  static const Color decorElementBlueLight = Color(0xFF0186DF);
  static const Color decorElementLight = Color(0xFFF5FBFF);
}

final lightTheme = ThemeData(
  primaryColorDark: AppColors.backgroundLight2,
  primaryColorLight: AppColors.backgroundLight2,
  shadowColor: AppColors.decorElementBlue,
  highlightColor: AppColors.decorElementLight,
  primaryColor: AppColors.textDark,
);

final darkTheme = ThemeData(
  primaryColorDark: AppColors.backgroundDark1,
  primaryColorLight: AppColors.backgroundDark2,
  shadowColor: AppColors.decorElementBlueLight,
  highlightColor: AppColors.decorElementBlue,
  primaryColor: AppColors.textLight,
);
