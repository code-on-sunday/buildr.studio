import 'package:buildr_studio/models/tool.dart';
import 'package:flutter/material.dart';

class SidebarContent extends StatelessWidget {
  final List<Tool> tools;
  final Tool? selectedTool;
  final Function(Tool) onToolSelected;

  const SidebarContent({
    super.key,
    required this.tools,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: tools.length,
      itemBuilder: (context, index) {
        final tool = tools[index];
        return ListTile(
          title: Text(tool.name),
          trailing: Tooltip(
            message: tool.description,
            child: const Icon(Icons.info_outline),
          ),
          selected: selectedTool == tool,
          onTap: () => onToolSelected(tool),
        );
      },
    );
  }
}
