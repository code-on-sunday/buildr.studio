import 'package:buildr_studio/app_theme.dart';
import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/repositories/tool_repository.dart';
import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:buildr_studio/screens/home_screen.dart';
import 'package:buildr_studio/screens/home_screen/ai_service_context.dart';
import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:buildr_studio/screens/splash_screen.dart';
import 'package:buildr_studio/services/device_registration_service.dart';
import 'package:buildr_studio/services/prompt_service/anthropic_prompt_service.dart';
import 'package:buildr_studio/services/prompt_service/authenticated_buildr_studio_request_builder.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:buildr_studio/utils/file_utils.dart';
import 'package:context_menus/context_menus.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';
import 'package:re_highlight/languages/all.dart';
import 'package:re_highlight/re_highlight.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:wiredash/wiredash.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await setupDependencyInjection();
  runApp(const MyApp());
}

Future<void> setupDependencyInjection() async {
  final Highlight highlight = Highlight();
  highlight.registerLanguages(builtinAllLanguages);
  GetIt.I.registerSingleton(highlight);

  PackageInfo packageInfo = await PackageInfo.fromPlatform();
  GetIt.I.registerSingleton(packageInfo);

  GetIt.I.registerSingleton(await SharedPreferences.getInstance());

  GetIt.I.registerSingleton(ToolRepository());
  GetIt.I.registerSingleton(UserPreferencesRepository(prefs: GetIt.I.get()));

  GetIt.I.registerSingleton(FileUtils());
  GetIt.I.registerSingleton(ApiKeyManager(prefs: GetIt.I.get()));

  GetIt.I.registerSingleton(DeviceRegistrationService());
  GetIt.I.registerSingleton(
      AuthenticatedBuildrStudioRequestBuilder(GetIt.I.get()));

  GetIt.I.registerFactory<PromptService>(
      () => BuildrStudioPromptService(requestBuilder: GetIt.I.get()),
      instanceName: AIService.buildrStudio.name);
  GetIt.I.registerFactory<PromptService>(
      () => AnthropicPromptService(apiKeyManager: GetIt.I.get()),
      instanceName: AIService.anthropic.name);
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
          routes: {
            '/': (context) => const SplashScreen(),
            '/home': (context) => MultiProvider(
                  providers: [
                    ChangeNotifierProvider(
                        create: (context) => HomeScreenState(context)),
                    ChangeNotifierProvider(create: (_) => FileExplorerState()),
                    ChangeNotifierProvider(
                        create: (_) => ChooseAIServiceState(
                            userPreferencesRepository: GetIt.I.get())),
                    ChangeNotifierProvider(
                        create: (_) =>
                            DeviceRegistrationState()..registerDevice()),
                  ],
                  child: Consumer<ChooseAIServiceState>(
                    builder: (context, chooseAIServiceState, child) {
                      return AiServiceContext(
                          key: ValueKey(chooseAIServiceState.selectedService),
                          aiService: chooseAIServiceState.selectedService,
                          child: child!);
                    },
                    child: const HomeScreen(),
                  ),
                ),
          },
        ),
      ),
    );
  }
}
