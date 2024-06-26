import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/tool_details.dart';
import 'package:buildr_studio/repositories/tool_repository.dart';
import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class HomeScreenState extends ChangeNotifier {
  final _logger = GetIt.I.get<Logger>();

  final BuildContext _context;
  late final ToolRepository _toolRepository;
  late final UserPreferencesRepository _userPreferencesRepository;
  List<Tool> _tools = [];
  Tool? _selectedTool;
  ToolDetails? _prompt;
  bool _isSidebarVisible = false;
  int _selectedNavRailIndex = 0;
  bool _isSettingsVisible = false;
  bool _isVariableSectionVisible = false;
  bool _isTerminalVisible = false;

  HomeScreenState(this._context) {
    _toolRepository = GetIt.I.get<ToolRepository>();
    _userPreferencesRepository = GetIt.I.get<UserPreferencesRepository>();
    _loadTools();
  }

  List<Tool> get tools => _tools;
  Tool? get selectedTool => _selectedTool;
  ToolDetails? get prompt => _prompt;
  bool get isSidebarVisible => _isSidebarVisible;
  int get selectedNavRailIndex => _selectedNavRailIndex;
  bool get isSettingsVisible => _isSettingsVisible;
  bool get isVariableSectionVisible => _isVariableSectionVisible;
  bool get isTerminalVisible => _isTerminalVisible;

  void toggleVariableSection() {
    _isVariableSectionVisible = !_isVariableSectionVisible;
    notifyListeners();
  }

  Future<void> _loadTools() async {
    try {
      _tools = await _toolRepository.getTools();
      _selectLastTool();
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading tools: $e');
    }
  }

  Future<void> _loadPromptAndVariables(String toolId) async {
    try {
      _prompt = await _toolRepository.getToolDetails(toolId);
      notifyListeners();
    } catch (e) {
      _logger.e('Error loading prompt and variables for tool $toolId: $e');
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
    if (_selectedNavRailIndex == 1) {
      _isSettingsVisible = !_isSettingsVisible;
    } else {
      _isSettingsVisible = false;
    }
    notifyListeners();
  }

  void onToolSelected(Tool tool) {
    _selectedTool = tool;
    _prompt = null;
    notifyListeners();
    _loadPromptAndVariables(tool.id);
    _userPreferencesRepository.setLastSelectedToolId(tool.id);
  }

  void toggleTerminal() {
    _isTerminalVisible = !_isTerminalVisible;
    notifyListeners();
  }

  Future<void> _selectLastTool() async {
    final lastSelectedToolId =
        _userPreferencesRepository.getLastSelectedToolId();
    if (lastSelectedToolId != null) {
      final tool = _tools.firstWhereOrNull((t) => t.id == lastSelectedToolId);
      if (tool != null) {
        _selectedTool = tool;
        await _loadPromptAndVariables(tool.id);
      } else {
        // If the last selected tool no longer exists, remove it from storage
        await _userPreferencesRepository.setLastSelectedToolId(null);
        if (_tools.isNotEmpty) {
          _selectedTool = _tools.first;
          await _loadPromptAndVariables(_selectedTool!.id);
        }
      }
    } else if (_tools.isNotEmpty) {
      _selectedTool = _tools.first;
      await _loadPromptAndVariables(_selectedTool!.id);
    }
  }
}
