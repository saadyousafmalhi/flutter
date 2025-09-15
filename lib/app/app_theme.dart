import 'package:flutter/material.dart';

ThemeData appTheme() => ThemeData(
  useMaterial3: true,
  colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF3366FF)),
  inputDecorationTheme: const InputDecorationTheme(border: OutlineInputBorder()),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(minimumSize: const Size.fromHeight(44)),
  ),
);
