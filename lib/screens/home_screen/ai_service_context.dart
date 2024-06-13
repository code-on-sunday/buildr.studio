import 'package:buildr_studio/screens/home_screen/settings/api_key_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class AiServiceContext extends StatelessWidget {
  const AiServiceContext(
      {super.key, required this.aiService, required this.child});

  final AIService aiService;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
            create: (_) => ApiKeyState(
                aiService: aiService, apiKeyManager: GetIt.I.get())),
        ChangeNotifierProvider(
            create: (_) => ToolUsageManager(
                promptService: GetIt.I.get(instanceName: aiService.name))),
      ],
      child: child,
    );
  }
}
