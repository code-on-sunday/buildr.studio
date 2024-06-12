import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/variable.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_input.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

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

    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              const Text(
                'Variables',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: () async {
                  await Clipboard.setData(
                    ClipboardData(
                      text: await toolUsageManager.exportPrompt(
                        homeState.prompt?.prompt,
                        fileExplorerState,
                      ),
                    ),
                  );
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Prompt copied to clipboard'),
                    ),
                  );
                },
                icon: const Icon(Icons.copy),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: variables
                .map((variable) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: VariableInput(
                        variable: variable,
                        selectedPaths:
                            toolUsageManager.selectedPaths[variable.name] ?? [],
                        onPathsSelected: toolUsageManager.onPathsSelected,
                        onValueChanged: toolUsageManager.setInputValue,
                      ),
                    ))
                .toList(),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    toolUsageManager.clearValues();
                  },
                  child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: const Text('Clear values')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: toolUsageManager.isResponseStreaming
                      ? const FilledButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 24,
                            height: 24,
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
                                  );
                                  homeState.toggleVariableSection();
                                },
                          label: const Text('Run'),
                          icon: const Icon(Icons.play_arrow),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
