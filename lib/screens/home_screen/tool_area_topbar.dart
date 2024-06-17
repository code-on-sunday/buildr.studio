import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ToolAreaTopBar extends StatelessWidget {
  const ToolAreaTopBar({
    super.key,
    required this.openVariableSection,
  });

  final VoidCallback openVariableSection;

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final toolUsageManager = context.watch<ToolUsageManager>();
    final fileExplorerState = context.watch<FileExplorerState>();
    final deviceRegistrationState = context.read<DeviceRegistrationState>();

    return Container(
      padding: const EdgeInsets.all(16.0),
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        borderRadius: ShadTheme.of(context).radius,
        border: Border.all(
          width: 1,
          color: ShadTheme.of(context).colorScheme.border,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          ShadTooltip(
            builder: (context) => const Text('Show variables'),
            child: ShadButton.outline(
              backgroundColor: homeState.isVariableSectionVisible
                  ? ShadTheme.of(context).colorScheme.accent
                  : null,
              onPressed: openVariableSection,
              text: const Text('{ }'),
            ),
          ),
          const SizedBox(width: 8),
          ShadButton(
            enabled: !toolUsageManager.isResponseStreaming,
            onPressed: () {
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
          ),
        ],
      ),
    );
  }
}
