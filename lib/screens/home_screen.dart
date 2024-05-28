import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_section.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';
import 'package:volta/screens/home_screen/output_section.dart';
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
                  destinations: const [
                    NavigationRailDestination(
                      icon: Icon(Icons.build),
                      label: Text('Build'),
                    ),
                    NavigationRailDestination(
                      icon: Icon(Icons.folder),
                      label: Text('File Explorer'),
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
                        : const FileExplorerSection(),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (homeState.selectedTool != null)
                            VariableSection(
                              selectedTool: homeState.selectedTool!,
                              variables: homeState.prompt?.variables ?? [],
                              variableSectionState: variableSectionState,
                            ),
                          const OutputSection(),
                        ],
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
                                : const FileExplorerSection(),
                          ),
                        ),
                      Positioned(
                        top: 16,
                        right: 16,
                        child: ElevatedButton(
                          onPressed: () {
                            variableSectionState.submit(context);
                          },
                          child: const Text('Run'),
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
