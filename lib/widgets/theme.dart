import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.light(
    background: Colors.white,
    primary: Colors.blue,
    secondary: Colors.black87,
    tertiary: Colors.grey.shade200,
  ),
  fontFamily: 'Fredoka',
  iconButtonTheme: IconButtonThemeData(
      style:
          ButtonStyle(foregroundColor: MaterialStateProperty.all(Colors.blue))),
  useMaterial3: true,
);

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    background: Colors.black26,
    primary: Colors.lightBlue,
    secondary: Colors.grey,
    tertiary: Colors.grey.shade700,
  ),
  fontFamily: 'Fredoka',
  iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
          foregroundColor: MaterialStateProperty.all(Colors.lightBlue))),
  useMaterial3: true,
);
