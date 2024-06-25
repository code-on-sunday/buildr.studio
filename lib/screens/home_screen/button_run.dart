import 'package:ambilytics/ambilytics.dart';
import 'package:buildr_studio/analytics_events.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'device_registration_state.dart';
import 'file_explorer_state.dart';
import 'tool_usage/tool_usage_manager.dart';

class ButtonRun extends StatelessWidget {
  const ButtonRun({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final toolUsageManager = context.watch<ToolUsageManager>();
    final fileExplorerState = context.watch<FileExplorerState>();
    final deviceRegistrationState = context.read<DeviceRegistrationState>();

    return ShadButton(
      enabled: !toolUsageManager.isResponseStreaming,
      onPressed: () {
        ambilytics?.sendEvent(AnalyticsEvents.runPressed.name, null);
        toolUsageManager.submitPrompt(
          homeState.prompt?.prompt,
          fileExplorerState,
          deviceRegistrationState,
        );
        if (homeState.isVariableSectionVisible) {
          homeState.toggleVariableSection();
        }
      },
      text: const Text('Run'),
      icon: toolUsageManager.isResponseStreaming
          ? const Padding(
              padding: EdgeInsets.only(right: 8),
              child: SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                ),
              ),
            )
          : const Icon(Icons.play_arrow),
    );
  }
}
