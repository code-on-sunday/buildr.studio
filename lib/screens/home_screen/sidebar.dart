import 'package:flutter/material.dart';
import 'package:volta/models/tool.dart';

class Sidebar extends StatelessWidget {
  final List<Tool> tools;
  final Tool? selectedTool;
  final void Function(Tool) onToolSelected;

  const Sidebar({
    super.key,
    required this.tools,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ListView.builder(
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
            onTap: () {
              onToolSelected(tool);
            },
          );
        },
      ),
    );
  }
}
