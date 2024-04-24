import 'package:flutter/material.dart';

class AppColors {
  static const Color backgroundDark1 = Color(0xFF0F1E28);
  static const Color backgroundDark2 = Color(0xFF182A36);
  static const Color backgroundDark3 = Color(0xFF0D2636);
  static const Color backgroundDark4 = Color(0xFF01436D);

  static const Color backgroundLight1 = Color(0xFFF5FBFF);
  static const Color backgroundLight2 = Color(0xFFC5E6FD);
  static const Color backgroundLight3 = Color(0xFFE2F4FF);
  static const Color backgroundLight4 = Color(0xFFA8DBFF);

  static const Color textDark = Color(0xFF0F1E28);
  static const Color textLight = Color(0xFFF5FBFF);

  static const Color decorElementDark1 = Color(0xFF0F1E28);
  static const Color decorElementDark2 = Color(0xFF0186DF);
  static const Color decorElementDark3 = Color(0x4C0287DF);

  static const Color decorElementLight1 = Color(0xFFF5FBFF);
  static const Color decorElementLight2 = Color(0xFF01497A);
  static const Color decorElementLight3 = Color(0x4C024A7A);

  static const Color redDark = Color(0xFFE02849);
  static const Color redLight = Color(0xFFC6000F);
}

final lightTheme = ThemeData(
  primaryColorDark: AppColors.backgroundLight1,
  primaryColorLight: AppColors.backgroundLight2,
  hintColor: AppColors.backgroundLight3,
  hoverColor: AppColors.backgroundLight4,
  shadowColor: AppColors.decorElementLight2,
  cardColor: AppColors.decorElementLight3,
  highlightColor: AppColors.decorElementLight1,
  primaryColor: AppColors.textDark,
  disabledColor: AppColors.redLight,
);

final darkTheme = ThemeData(
  primaryColorDark: AppColors.backgroundDark1,
  primaryColorLight: AppColors.backgroundDark2,
  hintColor: AppColors.backgroundDark3,
  hoverColor: AppColors.backgroundDark4,
  shadowColor: AppColors.decorElementDark2,
  cardColor: AppColors.decorElementDark3,
  highlightColor: AppColors.decorElementLight2,
  primaryColor: AppColors.textLight,
  disabledColor: AppColors.redDark,
);
