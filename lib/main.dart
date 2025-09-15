import 'package:flutter/material.dart';
import 'app/app_theme.dart';
import 'app/navigation/tabs.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Interview App',
      theme: appTheme(),
      home: const HomeTabs(), // all nav logic lives outside main.dart
    );
  }
}
