import 'package:flutter/material.dart';

ThemeData darkMode = ThemeData(
  colorScheme: ColorScheme.dark(
    surface: Color.fromARGB(255, 17, 21, 28),
    primary: Color.fromARGB(255, 54, 59, 81),
    tertiary: Color.fromARGB(255, 80, 86, 99),
    secondary: Color.fromARGB(255, 32, 39, 49),
    onSecondary: Colors.white,
    onPrimary: Color.fromARGB(255, 206, 211, 216),
    onSurface: Color.fromARGB(255, 118, 127, 137),
    inverseSurface: Color.fromARGB(255, 217, 221, 226),
  ),
  textTheme: ThemeData.dark().textTheme.apply(
    bodyColor: Colors.white,
    displayColor: Colors.white,
  ),
);
