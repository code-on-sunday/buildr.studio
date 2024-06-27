import 'package:buildr_studio/screens/home_screen/api_key_missing_notification.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_tree.dart';
import 'package:buildr_studio/screens/home_screen/get_support_button.dart';
import 'package:buildr_studio/screens/home_screen/more_on_navigation_rail.dart';
import 'package:buildr_studio/screens/home_screen/primary_alert.dart';
import 'package:buildr_studio/screens/home_screen/settings/tab_settings.dart';
import 'package:buildr_studio/screens/home_screen/sidebar.dart';
import 'package:buildr_studio/screens/home_screen/status_bar.dart';
import 'package:buildr_studio/screens/home_screen/terminal_panel.dart';
import 'package:buildr_studio/screens/home_screen/tool_area_topbar.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/output_section.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/output_section_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'home_screen_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;
    final theme = ShadTheme.of(context);

    final child = Scaffold(
      backgroundColor: ShadTheme.of(context).colorScheme.muted,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.all(4).copyWith(bottom: 0),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.background,
                    borderRadius: theme.radius,
                    border: Border.all(
                      width: 1,
                      color: theme.colorScheme.border,
                    ),
                  ),
                  child: Column(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: theme.radius,
                          child: NavigationRail(
                            selectedIndex: homeState.selectedNavRailIndex,
                            onDestinationSelected:
                                homeState.onNavRailItemTapped,
                            indicatorColor: theme.colorScheme.primary,
                            selectedIconTheme: IconThemeData(
                              color: theme.colorScheme.primaryForeground,
                            ),
                            destinations: [
                              const NavigationRailDestination(
                                icon: Icon(Icons.folder),
                                label: Text('File Explorer'),
                              ),
                              NavigationRailDestination(
                                icon: const Icon(Icons.settings),
                                label: Text(homeState.isSettingsVisible
                                    ? 'Close Settings'
                                    : 'Settings'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const GetSupportButton(),
                      const MoreOnNavigationRail(),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
                if (isLargeScreen)
                  Sidebar(
                      onClose: homeState.toggleSidebar,
                      child: Stack(
                        children: [
                          Offstage(
                              offstage: homeState.selectedNavRailIndex != 0,
                              child: const FileExplorerTree()),
                          Offstage(
                              offstage: homeState.selectedNavRailIndex != 1,
                              child: const SettingsTab()),
                        ],
                      )),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ApiKeyMissingNotification(),
                            const PrimaryAlert(),
                            if (homeState.selectedTool != null)
                              ToolAreaTopBar(
                                openVariableSection: () {
                                  homeState.toggleVariableSection();
                                },
                              ),
                            Expanded(
                              child: Stack(
                                children: [
                                  ChangeNotifierProvider(
                                    create: (_) => OutputSectionState(),
                                    child: const OutputSection(),
                                  ),
                                  if (homeState.selectedTool != null)
                                    AnimatedSlide(
                                      duration: Durations.short4,
                                      offset: homeState.isVariableSectionVisible
                                          ? Offset.zero
                                          : const Offset(1, 0),
                                      child: VariableSection(
                                        selectedTool: homeState.selectedTool!,
                                        variables:
                                            homeState.prompt?.variables ?? [],
                                      ),
                                    )
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (!isLargeScreen)
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: AnimatedSlide(
                            duration: Durations.short4,
                            offset: homeState.isSidebarVisible
                                ? Offset.zero
                                : const Offset(-1.5, 0),
                            child: Sidebar(
                                onClose: homeState.toggleSidebar,
                                child: Stack(
                                  children: [
                                    Offstage(
                                        offstage:
                                            homeState.selectedNavRailIndex != 0,
                                        child: const FileExplorerTree()),
                                    Offstage(
                                        offstage:
                                            homeState.selectedNavRailIndex != 1,
                                        child: const SettingsTab()),
                                  ],
                                )),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const StatusBar(),
        ],
      ),
    );

    return Stack(
      children: [
        child,
        Offstage(
          offstage: !homeState.isTerminalVisible,
          child: SizedBox(
            height: 400,
            child: TerminalPanel(
              workingDirectory:
                  context.watch<FileExplorerState>().selectedFolderPath,
            ),
          ),
        )
      ],
    );
  }
}
