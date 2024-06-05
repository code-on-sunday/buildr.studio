import 'package:buildr_studio/screens/home_screen/file_explorer_section.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/output_section.dart';
import 'package:buildr_studio/screens/home_screen/settings_section.dart';
import 'package:buildr_studio/screens/home_screen/sidebar.dart';
import 'package:buildr_studio/screens/home_screen/sidebar_content.dart';
import 'package:buildr_studio/screens/home_screen/variable_section.dart';
import 'package:buildr_studio/screens/home_screen/variable_section_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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

          return GestureDetector(
            onTap: () {
              if (homeState.isVariableSectionVisible == true) {
                homeState.toggleVariableSection();
              }
            },
            child: Scaffold(
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
                              if (homeState.apiKey == null)
                                Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: Theme.of(context).colorScheme.error,
                                  child: Row(
                                    children: [
                                      const Text(
                                        'You need to set up Claude AI\'s API key.',
                                        style: TextStyle(
                                          color: Colors.white,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                          onPressed: () {
                                            homeState.onNavRailItemTapped(2);
                                          },
                                          child: const Text('Set up')),
                                    ],
                                  ),
                                ),
                              if (homeState.selectedTool != null)
                                Padding(
                                  padding: const EdgeInsets.all(16.0),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Tooltip(
                                        message: 'Show variables',
                                        child: OutlinedButton(
                                          onPressed:
                                              homeState.toggleVariableSection,
                                          child: const Text('{ }'),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      SizedBox(
                                        width: 300,
                                        height: 40,
                                        child: variableSectionState.isRunning
                                            ? const FilledButton(
                                                onPressed: null,
                                                child: SizedBox(
                                                  width: 16,
                                                  height: 16,
                                                  child:
                                                      CircularProgressIndicator(),
                                                ),
                                              )
                                            : FilledButton.icon(
                                                onPressed: variableSectionState
                                                        .isRunning
                                                    ? null
                                                    : () {
                                                        try {
                                                          variableSectionState
                                                              .submit(context);
                                                        } catch (e) {
                                                          // Log the error or display it to the UI
                                                          print('Error: $e');
                                                        }
                                                      },
                                                label: const Text('Run'),
                                                icon: const Icon(
                                                    Icons.play_arrow),
                                              ),
                                      ),
                                    ],
                                  ),
                                ),
                              const Expanded(child: OutputSection()),
                            ],
                          ),
                        ),
                        if (homeState.selectedTool != null)
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
            ),
          );
        },
      ),
    );
  }
}
