import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/repositories/tool_repository.dart';

import 'output_section.dart';
import 'sidebar.dart';
import 'variable_section.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final ToolRepository _toolRepository;
  List<Tool> _tools = [];
  Tool? _selectedTool;

  @override
  void initState() {
    super.initState();
    _toolRepository = GetIt.I.get<ToolRepository>();
    _loadTools();
  }

  Future<void> _loadTools() async {
    try {
      _tools = await _toolRepository.getTools();
      if (_tools.isNotEmpty) {
        _selectedTool = _tools.first;
      }
      setState(() {});
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading tools: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Sidebar
          Sidebar(
            tools: _tools,
            selectedTool: _selectedTool,
            onToolSelected: (tool) {
              setState(() {
                _selectedTool = tool;
              });
            },
          ),

          // Main Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Variable Section
                if (_selectedTool != null)
                  VariableSection(
                    selectedTool: _selectedTool!,
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
