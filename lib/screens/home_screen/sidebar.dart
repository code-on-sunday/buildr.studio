import 'package:flutter/material.dart';
import 'package:volta/models/tool.dart';

class Sidebar extends StatelessWidget {
  final List<Tool> tools;
  final Tool? selectedTool;
  final void Function(Tool) onToolSelected;
  final VoidCallback onClose;
  final bool showCloseButton;

  const Sidebar({
    super.key,
    required this.tools,
    required this.selectedTool,
    required this.onToolSelected,
    required this.onClose,
    this.showCloseButton = true,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 400,
      child: Drawer(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Volta',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (showCloseButton)
                    IconButton(
                      onPressed: onClose,
                      icon: const Icon(Icons.close),
                    ),
                ],
              ),
            ),
            Expanded(
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
                      onClose();
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
