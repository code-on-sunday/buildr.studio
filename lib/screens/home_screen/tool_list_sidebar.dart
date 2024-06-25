import 'package:ambilytics/ambilytics.dart';
import 'package:buildr_studio/analytics_events.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class ToolListSidebar extends StatelessWidget {
  const ToolListSidebar({
    super.key,
    required this.openVariableSection,
  });

  final VoidCallback openVariableSection;

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final theme = ShadTheme.of(context);

    return ShadSheet(
      constraints:
          BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.5),
      scrollable: true,
      title: const Row(
        children: [
          Icon(Icons.home_repair_service),
          SizedBox(width: 16),
          Text('AI Toolbox'),
        ],
      ),
      description: const Text(
          'Select a tool to use. The tool you select will determine the available variables to run.'),
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const SizedBox(height: 16),
          const Divider(),
          const SizedBox(height: 16),
          for (final tool in homeState.tools)
            ShadButton.ghost(
              width: double.infinity,
              mainAxisAlignment: MainAxisAlignment.start,
              text: Text(tool.name),
              onPressed: () {
                ambilytics?.sendEvent(AnalyticsEvents.toolSelected.name, {
                  'tool': tool.id,
                });
                homeState.onToolSelected(tool);
                if (!homeState.isVariableSectionVisible) {
                  openVariableSection();
                }
                Navigator.of(context).pop();
              },
              backgroundColor: homeState.selectedTool == tool
                  ? theme.colorScheme.primary
                  : null,
              foregroundColor: homeState.selectedTool == tool
                  ? theme.colorScheme.primaryForeground
                  : null,
              hoverBackgroundColor: homeState.selectedTool == tool
                  ? theme.colorScheme.primary.withOpacity(0.9)
                  : null,
              hoverForegroundColor: homeState.selectedTool == tool
                  ? theme.colorScheme.primaryForeground
                  : null,
            ),
        ],
      ),
    );
  }
}
