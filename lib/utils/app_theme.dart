import 'package:flutter/material.dart';

// Modern, vibrant app theme with light and dark mode
final ThemeData appThemeLight = ThemeData(
  brightness: Brightness.light,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF20BFA9),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    textStyle: TextStyle(color: Colors.white),
    color: Color(0xFF20BFA9),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
    backgroundColor: const Color(0xFF20BFA9),
    foregroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(200))),
  ),
  scaffoldBackgroundColor: Colors.transparent,
  primaryColor: Colors.white,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF20BFA9),
    secondary: Color(0xFF20BFA9),
    background: Colors.white,
    surface: Colors.white,
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.black,
    onSurface: Colors.black,
  ),
);

final ThemeData appThemeDark = ThemeData(
  brightness: Brightness.dark,
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF20BFA9),
    iconTheme: IconThemeData(color: Colors.white),
  ),
  popupMenuTheme: const PopupMenuThemeData(
    textStyle: TextStyle(color: Colors.white),
    color: Color(0xFF22223B),
  ),
  iconTheme: const IconThemeData(color: Colors.white),
  floatingActionButtonTheme: const FloatingActionButtonThemeData().copyWith(
    backgroundColor: const Color(0xFF20BFA9),
    foregroundColor: Colors.white,
    shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(200))),
  ),
  scaffoldBackgroundColor: Colors.transparent,
  primaryColor: Colors.white,
  fontFamily: 'Poppins',
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFF20BFA9),
    secondary: Color(0xFF20BFA9),
    background: Color(0xFF22223B),
    surface: Color(0xFF22223B),
    onPrimary: Colors.white,
    onSecondary: Colors.white,
    onBackground: Colors.white,
    onSurface: Colors.white,
  ),
);

// Modern color palette
class AppColors {
  static const Color primaryBlue = Color(0xFF22223B);
  static const Color secondaryBlue = Color(0xFF4A4E69);
  static const Color accentTeal = Color(0xFF20BFA9); // Teal accent
  static const Color white = Color(0xFFF2E9E4);
  static const Color gray = Color.fromARGB(255, 206, 204, 204);
  static const Color textColor = Color(0xFFC9ADA7);
  static const Color red = Color(0xFFD00000);
  static const Color chipUnselectedLight = Color(0xFFE0F2F1); // Light gray/teal
  static const Color chipUnselectedDark = Color(0xFF37474F); // Dark gray/blue
}
