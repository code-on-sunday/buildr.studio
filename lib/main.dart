import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:volta/app_theme.dart';
import 'package:volta/repositories/tool_repository.dart';
import 'package:volta/screens/home_screen.dart';

void main() {
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
    setupDependencyInjection();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: GetIt.I.allReady(),
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const MaterialApp(
              home: Scaffold(
                body: Center(
                  child: CircularProgressIndicator(),
                ),
              ),
            );
          }
          return MaterialApp(
            title: 'Tool App',
            theme: AppTheme.blackAndWhiteTheme,
            home: const HomeScreen(),
          );
        });
  }
}
