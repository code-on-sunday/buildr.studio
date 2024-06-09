import 'package:buildr_studio/app_theme.dart';
import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/repositories/tool_repository.dart';
import 'package:buildr_studio/screens/splash_screen.dart';
import 'package:buildr_studio/utils/device_registration.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:wiredash/wiredash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

Future<void> setupDependencyInjection() async {
  GetIt.I.registerSingleton<ToolRepository>(ToolRepository());
  final Highlight highlight = Highlight();
  highlight.registerLanguages(builtinAllLanguages);
  GetIt.I.registerSingleton(highlight);
  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  GetIt.I.registerSingleton(packageInfo);
  GetIt.I.registerSingleton(DeviceRegistration());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ContextMenuOverlay(
      child: Wiredash(
        projectId: Env.wireDashProjectId ?? '',
        secret: Env.wireDashSecret ?? '',
        child: MaterialApp(
          title: 'buildr.studio',
          theme: AppTheme.blackAndWhiteTheme,
          debugShowCheckedModeBanner: false,
          home: const SplashScreen(),
        ),
      ),
    );
  }
}
