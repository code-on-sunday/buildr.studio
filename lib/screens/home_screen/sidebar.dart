import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final List<String> toolNames;
  final String selectedTool;
  final void Function(String) onToolSelected;

  const Sidebar({
    super.key,
    required this.toolNames,
    required this.selectedTool,
    required this.onToolSelected,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 200,
      child: ListView.builder(
        itemCount: toolNames.length,
        itemBuilder: (context, index) {
          final toolName = toolNames[index];
          return ListTile(
            title: Text(toolName),
            selected: toolName == selectedTool,
            onTap: () {
              onToolSelected(toolName);
            },
          );
        },
      ),
    );
  }
}
