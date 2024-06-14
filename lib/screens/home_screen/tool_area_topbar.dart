import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ToolAreaTopBar extends StatelessWidget {
  const ToolAreaTopBar({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final toolUsageManager = context.watch<ToolUsageManager>();
    final fileExplorerState = context.watch<FileExplorerState>();
    final deviceRegistrationState = context.read<DeviceRegistrationState>();

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Tooltip(
            message: 'Show variables',
            child: OutlinedButton(
              onPressed: homeState.toggleVariableSection,
              child: const Text('{ }'),
            ),
          ),
          const SizedBox(width: 8),
          SizedBox(
            width: 300,
            height: 40,
            child: toolUsageManager.isResponseStreaming
                ? const FilledButton(
                    onPressed: null,
                    child: SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(),
                    ),
                  )
                : FilledButton.icon(
                    onPressed: toolUsageManager.isResponseStreaming
                        ? null
                        : () {
                            toolUsageManager.submitPrompt(
                                homeState.prompt?.prompt,
                                fileExplorerState,
                                deviceRegistrationState);
                          },
                    label: const Text('Run'),
                    icon: const Icon(Icons.play_arrow),
                  ),
          ),
        ],
      ),
    );
  }
}
