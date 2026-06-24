import 'package:flutter/material.dart';
import 'package:morden_ecommerce_app/services/theme/dark_mode.dart';
import 'package:morden_ecommerce_app/services/theme/light_mode.dart';

class ThemeProvider extends ChangeNotifier {
  //initially start in dark mode
  ThemeData _themeData = darkMode;

  //getter to get current theme
  ThemeData get themeData => _themeData;

  //to get if it si light mode or not
  bool get isLightMode => _themeData == lightMode;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (themeData == darkMode) {
      themeData = lightMode;
    } else {
      themeData = darkMode;
    }
  }
}
