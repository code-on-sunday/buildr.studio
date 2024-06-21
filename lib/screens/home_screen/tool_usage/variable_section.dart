import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/variable.dart';
import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_input.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VariableSection extends StatelessWidget {
  final Tool selectedTool;
  final List<Variable> variables;

  const VariableSection({
    super.key,
    required this.selectedTool,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final fileExplorerState = context.watch<FileExplorerState>();
    final toolUsageManager = context.watch<ToolUsageManager>();
    final deviceRegistrationState = context.read<DeviceRegistrationState>();

    return Container(
      decoration: BoxDecoration(
        color: ShadTheme.of(context).colorScheme.background,
        borderRadius: ShadTheme.of(context).radius,
        border: Border.all(
          width: 1,
          color: ShadTheme.of(context).colorScheme.border,
        ),
      ),
      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(top: 8),
            child: Row(
              children: [
                Text(
                  homeState.selectedTool?.name ?? '',
                  style: ShadTheme.of(context).textTheme.h4,
                ),
                const Spacer(),
                ShadButton.outline(
                  onPressed: () async {
                    ShadToaster.of(context).show(
                      const ShadToast(
                        alignment: Alignment.topRight,
                        description: Text('Prompt copied to clipboard'),
                      ),
                    );
                    Clipboard.setData(
                      ClipboardData(
                        text: await toolUsageManager.exportPrompt(
                          homeState.prompt?.prompt,
                          fileExplorerState,
                        ),
                      ),
                    );
                  },
                  icon: const Icon(Icons.copy),
                ),
              ],
            ),
          ),
          const Divider(),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: variables
                    .map((variable) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8.0),
                          child: VariableInput(
                            key: Key(
                                '${variable.name}-${homeState.selectedTool?.id}'),
                            variable: variable,
                            selectedPaths:
                                toolUsageManager.selectedPaths[variable.name] ??
                                    [],
                            onPathsSelected: toolUsageManager.onPathsSelected,
                            onValueChanged: toolUsageManager.setInputValue,
                          ),
                        ))
                    .toList(),
              ),
            ),
          ),
          const Divider(),
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 16).copyWith(bottom: 8),
            child: Row(
              children: [
                ShadButton.destructive(
                  onPressed: () {
                    toolUsageManager.clearValues();
                  },
                  text: const Text('Clear values'),
                ),
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
          ),
        ],
      ),
    );
  }
}
