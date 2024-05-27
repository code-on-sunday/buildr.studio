import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/tool_details.dart';
import 'package:volta/repositories/tool_repository.dart';

class HomeScreenState extends ChangeNotifier {
  final BuildContext _context;
  late final ToolRepository _toolRepository;
  List<Tool> _tools = [];
  Tool? _selectedTool;
  ToolDetails? _prompt;
  bool _isSidebarVisible = false;
  int _selectedNavRailIndex = 0;

  HomeScreenState(this._context) {
    _toolRepository = GetIt.I.get<ToolRepository>();
    _loadTools();
  }

  List<Tool> get tools => _tools;
  Tool? get selectedTool => _selectedTool;
  ToolDetails? get prompt => _prompt;
  bool get isSidebarVisible => _isSidebarVisible;
  int get selectedNavRailIndex => _selectedNavRailIndex;

  Future<void> _loadTools() async {
    try {
      _tools = await _toolRepository.getTools();
      if (_tools.isNotEmpty) {
        _selectedTool = _tools.first;
        await _loadPromptAndVariables(_selectedTool!.id);
      }
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading tools: $e');
    }
  }

  Future<void> _loadPromptAndVariables(String toolId) async {
    try {
      _prompt = await _toolRepository.getToolDetails(toolId);
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading prompt and variables for tool $toolId: $e');
      _prompt = null;
      notifyListeners();
    }
  }

  void toggleSidebar() {
    _isSidebarVisible = !_isSidebarVisible;
    notifyListeners();
  }

  void onNavRailItemTapped(int index) {
    final isLargeScreen = MediaQuery.of(_context).size.width >= 1024;
    if (!isLargeScreen) {
      if (_selectedNavRailIndex == index) {
        _isSidebarVisible = !_isSidebarVisible;
      } else {
        _isSidebarVisible = true;
      }
    }
    _selectedNavRailIndex = index;
    notifyListeners();
  }

  void onToolSelected(Tool tool) {
    _selectedTool = tool;
    notifyListeners();
    _loadPromptAndVariables(tool.id);
  }
}
