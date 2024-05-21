import 'package:flutter/material.dart';

import 'output_section.dart';
import 'sidebar.dart';
import 'variable_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // List of tool names (for demo purpose)
  final List<String> _toolNames = [
    'Tool 1',
    'Tool 2',
    'Tool 3',
    'Tool 4',
    'Tool 5'
  ];

  // List of variables for each tool (for demo purpose)
  final Map<String, List<String>> _toolVariables = {
    'Tool 1': ['Variable 1', 'Variable 2', 'Variable 3'],
    'Tool 2': ['Variable 4', 'Variable 5', 'Variable 6'],
    'Tool 3': ['Variable 7', 'Variable 8', 'Variable 9'],
    'Tool 4': ['Variable 10', 'Variable 11', 'Variable 12'],
    'Tool 5': ['Variable 13', 'Variable 14', 'Variable 15'],
  };

  // Selected tool
  late String _selectedTool = _toolNames.first;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tool App'),
      ),
      body: Row(
        children: [
          // Sidebar
          Sidebar(
            toolNames: _toolNames,
            selectedTool: _selectedTool,
            onToolSelected: (toolName) {
              setState(() {
                _selectedTool = toolName;
              });
            },
          ),

          // Main Content Area
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variable Section
                VariableSection(
                  selectedTool: _selectedTool,
                  toolVariables: _toolVariables,
                ),

                // Output Section
                const OutputSection(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
