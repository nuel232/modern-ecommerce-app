import 'package:flutter/material.dart';

ThemeData lightMode = ThemeData(
  colorScheme: ColorScheme.light(
    surface: Colors.grey.shade300,
    primary: Colors.grey.shade100,
    tertiary: const Color.fromARGB(255, 78, 88, 103),
    secondary: const Color.fromARGB(255, 54, 59, 81),
    onSecondary: Colors.black, // ← CHANGE to pure black
    onPrimary: Colors.black, // ← CHANGE to pure black
    onSurface: Colors.black, // ← CHANGE to pure black
  ),

  textTheme: ThemeData.light().textTheme.apply(
    bodyColor: Colors.black,
    displayColor: Colors.black,
  ),
);
