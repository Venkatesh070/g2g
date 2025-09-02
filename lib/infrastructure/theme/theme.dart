import 'package:flutter/material.dart';

import 'app_bar.theme.dart';
import 'button.theme.dart';
import 'colors.theme.dart';

ThemeData themeData = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: ColorsTheme.colPrimary,
    primary: ColorsTheme.colPrimary,
    secondary: ColorsTheme.colSecondary,
    brightness: Brightness.dark,
    background: ColorsTheme.colBackground,
  ),
  primaryColor:ColorsTheme.colPrimary,
  hintColor: ColorsTheme.colHint,
  appBarTheme: appBarTheme,
  elevatedButtonTheme: buttonTheme,
  fontFamily: "SF-Pro",
  scaffoldBackgroundColor: Colors.white,
  useMaterial3: true
);