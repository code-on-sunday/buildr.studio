import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:volta/app_theme.dart';
import 'package:volta/repositories/tool_repository.dart';
import 'package:volta/screens/home_screen.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  setupDependencyInjection();
  runApp(const MyApp());
}

void setupDependencyInjection() {
  GetIt.I.registerSingleton<ToolRepository>(ToolRepository());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tool App',
      theme: AppTheme.blackAndWhiteTheme,
      home: const HomeScreen(),
    );
  }
}
