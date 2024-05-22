import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';
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
  List<Variable> _variables = [];
  bool _isSidebarVisible = true;

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
        await _loadVariables(_selectedTool!.id);
      }
      setState(() {});
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading tools: $e');
    }
  }

  Future<void> _loadVariables(String toolId) async {
    try {
      _variables = await _toolRepository.getVariables(toolId);
      setState(() {});
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading variables for tool $toolId: $e');
      _variables = [];
      setState(() {});
    }
  }

  void _toggleSidebar() {
    setState(() {
      _isSidebarVisible = !_isSidebarVisible;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isLargeScreen = MediaQuery.of(context).size.width >= 1024;

    return Scaffold(
      body: Stack(
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (isLargeScreen)
                Sidebar(
                  tools: _tools,
                  selectedTool: _selectedTool,
                  onToolSelected: (tool) async {
                    setState(() {
                      _selectedTool = tool;
                    });
                    await _loadVariables(tool.id);
                  },
                  onClose: _toggleSidebar,
                  showCloseButton:
                      false, // Hide the close button on large screens
                ),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (!isLargeScreen)
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          children: [
                            IconButton(
                              onPressed: _toggleSidebar,
                              icon: const Icon(Icons.menu),
                            ),
                            const SizedBox(width: 16),
                            const Text(
                              'Volta',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (_selectedTool != null)
                      VariableSection(
                        selectedTool: _selectedTool!,
                        variables: _variables,
                      ),
                    const OutputSection(),
                  ],
                ),
              ),
            ],
          ),
          if (!isLargeScreen && _isSidebarVisible)
            Positioned(
              left: 0,
              top: 0,
              bottom: 0,
              child: Sidebar(
                tools: _tools,
                selectedTool: _selectedTool,
                onToolSelected: (tool) async {
                  setState(() {
                    _selectedTool = tool;
                  });
                  await _loadVariables(tool.id);
                  _toggleSidebar();
                },
                onClose: _toggleSidebar,
                showCloseButton: true, // Show the close button on small screens
              ),
            ),
        ],
      ),
    );
  }
}
