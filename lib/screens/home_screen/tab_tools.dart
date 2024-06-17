import 'package:buildr_studio/models/tool.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ToolsTab extends StatelessWidget {
  final List<Tool> tools;
  final Tool? selectedTool;
  final Function(Tool) onToolSelected;

  const ToolsTab({
    super.key,
    required this.tools,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Tools',
            style: ShadTheme.of(context).textTheme.h4,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: tools.length,
              itemBuilder: (context, index) {
                final tool = tools[index];
                return ShadTooltip(
                  builder: (_) => Text(tool.description),
                  child: ShadButton.ghost(
                    width: double.infinity,
                    mainAxisAlignment: MainAxisAlignment.start,
                    backgroundColor: selectedTool == tool
                        ? ShadTheme.of(context).colorScheme.primary
                        : null,
                    foregroundColor: selectedTool == tool
                        ? ShadTheme.of(context).colorScheme.primaryForeground
                        : null,
                    hoverBackgroundColor: selectedTool == tool
                        ? ShadTheme.of(context)
                            .colorScheme
                            .primary
                            .withOpacity(0.9)
                        : null,
                    hoverForegroundColor: selectedTool == tool
                        ? ShadTheme.of(context).colorScheme.primaryForeground
                        : null,
                    onPressed: () => onToolSelected(tool),
                    text: Text(tool.name),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
