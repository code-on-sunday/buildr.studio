import 'package:buildr_studio/screens/home_screen/api_key_missing_notification.dart';
import 'package:buildr_studio/screens/home_screen/export_logs_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/tab_settings.dart';
import 'package:buildr_studio/screens/home_screen/sidebar.dart';
import 'package:buildr_studio/screens/home_screen/status_bar.dart';
import 'package:buildr_studio/screens/home_screen/tab_file_explorer.dart';
import 'package:buildr_studio/screens/home_screen/tab_tools.dart';
import 'package:buildr_studio/screens/home_screen/tool_area_topbar.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/output_section.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_section.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

import 'home_screen_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final homeState = context.watch<HomeScreenState>();
    final exportLogsState = context.read<ExportLogsState>();
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Column(
                  children: [
                    Expanded(
                      child: NavigationRail(
                        selectedIndex: homeState.selectedNavRailIndex,
                        onDestinationSelected: homeState.onNavRailItemTapped,
                        indicatorColor:
                            ShadTheme.of(context).colorScheme.primary,
                        selectedIconTheme: IconThemeData(
                          color: ShadTheme.of(context)
                              .colorScheme
                              .primaryForeground,
                        ),
                        destinations: [
                          const NavigationRailDestination(
                            icon: Icon(Icons.build),
                            label: Text('Build'),
                          ),
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
                    PopupMenuButton(
                      tooltip: 'Get help',
                      icon: const Icon(Icons.support),
                      offset: const Offset(0, -120),
                      itemBuilder: (context) {
                        return [
                          PopupMenuItem(
                            onTap: () => exportLogsState.exportLogs(context),
                            child: const Text('Export logs'),
                          ),
                          PopupMenuItem(
                            onTap: () {
                              launchUrlString("https://discord.gg/JVQmxkBqMY");
                            },
                            child: const Text('Join group chat'),
                          ),
                        ];
                      },
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
                if (isLargeScreen)
                  Sidebar(
                    onClose: homeState.toggleSidebar,
                    child: homeState.selectedNavRailIndex == 0
                        ? ToolsTab(
                            tools: homeState.tools,
                            selectedTool: homeState.selectedTool,
                            onToolSelected: homeState.onToolSelected,
                          )
                        : homeState.selectedNavRailIndex == 1
                            ? FileExplorerTab()
                            : const SettingsTab(),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            const ApiKeyMissingNotification(),
                            if (homeState.selectedTool != null)
                              ToolAreaTopBar(
                                openVariableSection: () {
                                  homeState.toggleVariableSection();
                                },
                              ),
                            Expanded(
                              child: Stack(
                                children: [
                                  const OutputSection(),
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
                      if (!isLargeScreen && homeState.isSidebarVisible)
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: Sidebar(
                            onClose: homeState.toggleSidebar,
                            child: homeState.selectedNavRailIndex == 0
                                ? ToolsTab(
                                    tools: homeState.tools,
                                    selectedTool: homeState.selectedTool,
                                    onToolSelected: homeState.onToolSelected,
                                  )
                                : homeState.selectedNavRailIndex == 1
                                    ? FileExplorerTab()
                                    : const SettingsTab(),
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
  }
}
