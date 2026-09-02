import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.dark(
    surface: Color.fromARGB(255, 17, 21, 28),
    primary: Color.fromARGB(255, 54, 59, 81),
    tertiary: Colors.white,
    secondary: Color.fromARGB(255, 32, 39, 49),
    onSecondary: Colors.white,
    onPrimary: Colors.grey.shade100,
    onSurface: Colors.grey.shade100,
    inverseSurface: Color.fromARGB(255, 217, 221, 226),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.grey.shade100,
    displayColor: Colors.grey.shade100,
  ),
);
