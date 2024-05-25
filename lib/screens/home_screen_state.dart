import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:path_provider/path_provider.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';
import 'package:volta/repositories/tool_repository.dart';

class HomeScreenState extends ChangeNotifier {
  final BuildContext _context;
  late final ToolRepository _toolRepository;
  List<Tool> _tools = [];
  Tool? _selectedTool;
  List<Variable> _variables = [];
  bool _isSidebarVisible = false;
  int _selectedNavRailIndex = 0;
  String? _selectedFolderPath;

  HomeScreenState(this._context) {
    _toolRepository = GetIt.I.get<ToolRepository>();
    _loadTools();
  }

  List<Tool> get tools => _tools;
  Tool? get selectedTool => _selectedTool;
  List<Variable> get variables => _variables;
  bool get isSidebarVisible => _isSidebarVisible;
  int get selectedNavRailIndex => _selectedNavRailIndex;
  String? get selectedFolderPath => _selectedFolderPath;

  Future<void> _loadTools() async {
    try {
      _tools = await _toolRepository.getTools();
      if (_tools.isNotEmpty) {
        _selectedTool = _tools.first;
        await _loadVariables(_selectedTool!.id);
      }
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading tools: $e');
    }
  }

  Future<void> _loadVariables(String toolId) async {
    try {
      _variables = await _toolRepository.getVariables(toolId);
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the US
      print('Error loading variables for tool $toolId: $e');
      _variables = [];
      notifyListeners();
    }
  }

  Future<void> openFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: directory.path,
      );
      if (selectedDirectory != null) {
        _selectedFolderPath = selectedDirectory;
        notifyListeners();
      }
    } catch (e) {
      // Log the error or display it to the UI
      print('Error selecting folder: $e');
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
    _loadVariables(tool.id);
  }
}
