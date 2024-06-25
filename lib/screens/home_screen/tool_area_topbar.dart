import 'package:buildr_studio/screens/home_screen/button_run.dart';
import 'package:buildr_studio/screens/home_screen/tool_list_sidebar.dart';
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
          const ButtonRun(),
          const Spacer(),
          ShadButton.link(
            onPressed: () {
              _showToolSidebar(context, homeState);
            },
            text: Text(homeState.selectedTool?.name ?? ''),
            textDecoration: TextDecoration.underline,
          ),
          ShadButton.outline(
            onPressed: () {
              _showToolSidebar(context, homeState);
            },
            text: const Text('Change'),
          ),
        ],
      ),
    );
  }

  void _showToolSidebar(BuildContext context, HomeScreenState homeState) {
    showShadSheet(
      context: context,
      side: ShadSheetSide.right,
      builder: (context) => ChangeNotifierProvider.value(
        value: homeState,
        child: ToolListSidebar(openVariableSection: openVariableSection),
      ),
    );
  }
}
