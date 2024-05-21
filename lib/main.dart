import 'package:flutter/material.dart';
import 'package:volta/app_theme.dart';
import 'package:volta/screens/home_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tool App',
      theme: AppTheme.blackAndWhiteTheme,
      home: const HomeScreen(),
    );
  }
}
