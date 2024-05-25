import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_section.dart';
import 'package:volta/screens/home_screen/output_section.dart';
import 'package:volta/screens/home_screen/sidebar.dart';
import 'package:volta/screens/home_screen/sidebar_content.dart';
import 'package:volta/screens/home_screen/variable_section.dart';

import 'home_screen_state.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => HomeScreenState(context),
      child: Consumer<HomeScreenState>(
        builder: (context, state, child) {
          final isLargeScreen = MediaQuery.of(context).size.width >= 1024;

          return Scaffold(
            body: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                NavigationRail(
                  selectedIndex: state.selectedNavRailIndex,
                  onDestinationSelected: state.onNavRailItemTapped,
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
                    onClose: state.toggleSidebar,
                    child: state.selectedNavRailIndex == 0
                        ? SidebarContent(
                            tools: state.tools,
                            selectedTool: state.selectedTool,
                            onToolSelected: state.onToolSelected,
                          )
                        : FileExplorerSection(
                            selectedFolderPath: state.selectedFolderPath,
                            onOpenFolder: state.openFolder,
                          ),
                  ),
                Expanded(
                  child: Stack(
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (state.selectedTool != null)
                            VariableSection(
                              selectedTool: state.selectedTool!,
                              variables: state.variables,
                            ),
                          const OutputSection(),
                        ],
                      ),
                      if (!isLargeScreen && state.isSidebarVisible)
                        Positioned(
                          top: 0,
                          left: 0,
                          bottom: 0,
                          child: Sidebar(
                            onClose: state.toggleSidebar,
                            child: state.selectedNavRailIndex == 0
                                ? SidebarContent(
                                    tools: state.tools,
                                    selectedTool: state.selectedTool,
                                    onToolSelected: state.onToolSelected,
                                  )
                                : FileExplorerSection(
                                    selectedFolderPath:
                                        state.selectedFolderPath,
                                    onOpenFolder: state.openFolder,
                                  ),
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
