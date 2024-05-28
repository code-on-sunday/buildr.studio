import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_section.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';
import 'package:volta/screens/home_screen/output_section.dart';
import 'package:volta/screens/home_screen/settings_section.dart';
import 'package:volta/screens/home_screen/sidebar.dart';
import 'package:volta/screens/home_screen/sidebar_content.dart';
import 'package:volta/screens/home_screen/variable_section.dart';
import 'package:volta/screens/home_screen/variable_section_state.dart';

import 'home_screen_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (context) => HomeScreenState(context)),
        ChangeNotifierProvider(create: (context) => FileExplorerState()),
        ChangeNotifierProvider(create: (context) => VariableSectionState()),
      ],
      child:
          Consumer3<HomeScreenState, FileExplorerState, VariableSectionState>(
        builder: (context, homeState, fileExplorerState, variableSectionState,
            child) {
          final isLargeScreen = MediaQuery.of(context).size.width >= 1024;

          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationRail(
                  selectedIndex: homeState.selectedNavRailIndex,
                  onDestinationSelected: homeState.onNavRailItemTapped,
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
                if (isLargeScreen)
                  Sidebar(
                    onClose: homeState.toggleSidebar,
                    child: homeState.selectedNavRailIndex == 0
                        ? SidebarContent(
                            tools: homeState.tools,
                            selectedTool: homeState.selectedTool,
                            onToolSelected: homeState.onToolSelected,
                          )
                        : homeState.selectedNavRailIndex == 1
                            ? const FileExplorerSection()
                            : const SettingsSection(),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            if (homeState.selectedTool != null)
                              Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    ElevatedButton(
                                      onPressed:
                                          homeState.toggleVariableSection,
                                      child: Text(
                                        homeState.isVariableSectionVisible
                                            ? 'Hide Input'
                                            : 'Show Input',
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            const Expanded(child: OutputSection()),
                          ],
                        ),
                      ),
                      AnimatedPositioned(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                        top: 0,
                        bottom: 0,
                        right: homeState.isVariableSectionVisible
                            ? 0
                            : -MediaQuery.of(context).size.width,
                        child: VariableSection(
                          selectedTool: homeState.selectedTool!,
                          variables: homeState.prompt?.variables ?? [],
                          variableSectionState: variableSectionState,
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
                                ? SidebarContent(
                                    tools: homeState.tools,
                                    selectedTool: homeState.selectedTool,
                                    onToolSelected: homeState.onToolSelected,
                                  )
                                : homeState.selectedNavRailIndex == 1
                                    ? const FileExplorerSection()
                                    : const SettingsSection(),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
