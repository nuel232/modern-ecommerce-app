import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color.fromARGB(255, 17, 21, 28),
    primary: Color.fromARGB(255, 54, 59, 81),
    tertiary: Colors.white,
    secondary: Color.fromARGB(255, 32, 39, 49),
    onSecondary: Colors.white,
    onPrimary: Colors.white, // ← CHANGE to pure white
    onSurface: Colors.white, // ← CHANGE to pure white
    inverseSurface: Color.fromARGB(255, 217, 221, 226),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);
