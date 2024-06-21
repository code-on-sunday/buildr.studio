import 'package:buildr_studio/screens/home_screen/settings/api_key_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';

class AiServiceContext extends StatefulWidget {
  const AiServiceContext({
    super.key,
    required this.aiService,
    required this.child,
  });

  final AIService aiService;
  final Widget child;

  @override
  State<AiServiceContext> createState() => _AiServiceContextState();
}

class _AiServiceContextState extends State<AiServiceContext> {
  final Map<String, ToolUsageManager> _toolUsageManagers = {};
  late final ToolUsageManager _toolUsageManagerForNull = ToolUsageManager(
    promptService: GetIt.I.get(instanceName: widget.aiService.name),
  );
  late final _homeState = context.read<HomeScreenState>();

  @override
  void initState() {
    super.initState();
    _onToolLoaded();
    _homeState.addListener(_onToolLoaded);
  }

  @override
  void dispose() {
    for (var toolUsageManager in _toolUsageManagers.values) {
      toolUsageManager.dispose();
    }
    _toolUsageManagerForNull.dispose();
    _homeState.removeListener(_onToolLoaded);
    super.dispose();
  }

  void _onToolLoaded() {
    final toolDetails = _homeState.prompt;
    if (toolDetails != null && _homeState.selectedTool != null) {
      _toolUsageManagers
          .putIfAbsent(
              _homeState.selectedTool!.id,
              () => ToolUsageManager(
                    promptService:
                        GetIt.I.get(instanceName: widget.aiService.name),
                  ))
          .setInitialValues(toolDetails);
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedTool = context.watch<HomeScreenState>().selectedTool;
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => ApiKeyState(
            aiService: widget.aiService,
            apiKeyManager: GetIt.I.get(),
          ),
        ),
        ChangeNotifierProvider.value(
          value: selectedTool == null
              ? _toolUsageManagerForNull
              : _toolUsageManagers[selectedTool.id],
        ),
      ],
      child: widget.child,
    );
  }
}
