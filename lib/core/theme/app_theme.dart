import 'package:flutter/material.dart';

final lightTheme = ThemeData(
  brightness: Brightness.light,
  scaffoldBackgroundColor: Color(0xFFF7F7F7),
  colorScheme: ColorScheme.light(
    primary: Color(0xFF222222),
    secondary: Color(0xFF4F4F4F),
    background: Color(0xFFF7F7F7),
  ),
  fontFamily: 'Pretendard',
);

final darkTheme = ThemeData(
  brightness: Brightness.dark,
  scaffoldBackgroundColor: Color(0xFF181818),
  colorScheme: ColorScheme.dark(
    primary: Color(0xFFF7F7F7),
    secondary: Color(0xFFBDBDBD),
    background: Color(0xFF181818),
  ),
  fontFamily: 'Pretendard',
); 