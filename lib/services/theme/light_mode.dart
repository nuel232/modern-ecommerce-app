import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade100,
    tertiary: const Color.fromARGB(255, 78, 88, 103),
    secondary: const Color.fromARGB(255, 54, 59, 81),
    onSecondary: Colors.grey.shade100,
    onPrimary: Colors.grey.shade900,
    onSurface: Colors.grey.shade900,
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.grey.shade900,
    displayColor: Colors.grey.shade900,
  ),
);
