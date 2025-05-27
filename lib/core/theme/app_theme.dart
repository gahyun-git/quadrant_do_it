import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: const Color(0xFFF7F7F7),
  colorScheme: const ColorScheme.light(
    primary: Color(0xFF222222),
    secondary: Color(0xFF4F4F4F),
    background: Color(0xFFF7F7F7),
    surface: Color(0xFFFFFFFF),
    error: Color(0xFFD32F2F),
    onPrimary: Color(0xFFFFFFFF),
    onSecondary: Color(0xFFFFFFFF),
    onBackground: Color(0xFF222222),
    onSurface: Color(0xFF222222),
    onError: Color(0xFFFFFFFF),
  ),
  cardColor: Colors.white,
  dialogBackgroundColor: Colors.white,
  fontFamily: 'Pretendard',
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: const Color(0xFF151A23),
  colorScheme: const ColorScheme.dark(
    primary: Color(0xFFF7F7F7), // 하얀색
    secondary: Color(0xFFBDBDBD),
    background: Color(0xFF151A23),
    surface: Color(0xFF232B3A),
    error: Color(0xFFEF5350),
    onPrimary: Color(0xFF151A23),
    onSecondary: Color(0xFF232B3A),
    onBackground: Color(0xFFF7F7F7), // 하얀색
    onSurface: Color(0xFFF7F7F7),   // 하얀색
    onError: Color(0xFF232B3A),
  ),
  cardColor: const Color(0xFF232B3A),
  dialogBackgroundColor: const Color(0xFF232B3A),
  fontFamily: 'Pretendard',
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFF151A23),
    foregroundColor: Color(0xFFF7F7F7),
    elevation: 0,
    iconTheme: IconThemeData(color: Color(0xFFF7F7F7)),
    titleTextStyle: TextStyle(color: Color(0xFFF7F7F7), fontWeight: FontWeight.bold, fontSize: 20),
  ),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFF151A23),
    selectedItemColor: Color(0xFFF7F7F7),
    unselectedItemColor: Color(0xFFBDBDBD),
  ),
  checkboxTheme: CheckboxThemeData(
    fillColor: MaterialStatePropertyAll(Color(0xFFF7F7F7)),
    checkColor: MaterialStatePropertyAll(Color(0xFF151A23)),
  ),
  iconTheme: const IconThemeData(color: Color(0xFFF7F7F7)),
  textTheme: const TextTheme(
    bodyLarge: TextStyle(color: Color(0xFFF7F7F7)),
    bodyMedium: TextStyle(color: Color(0xFFF7F7F7)),
    bodySmall: TextStyle(color: Color(0xFFF7F7F7)),
    titleLarge: TextStyle(color: Color(0xFFF7F7F7), fontWeight: FontWeight.bold),
    titleMedium: TextStyle(color: Color(0xFFF7F7F7)),
    titleSmall: TextStyle(color: Color(0xFFF7F7F7)),
    labelLarge: TextStyle(color: Color(0xFFF7F7F7)),
    labelMedium: TextStyle(color: Color(0xFFF7F7F7)),
    labelSmall: TextStyle(color: Color(0xFFF7F7F7)),
  ),
); 