import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/tool_details.dart';
import 'package:buildr_studio/repositories/tool_repository.dart';
import 'package:buildr_studio/utils/api_key_manager.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';

class HomeScreenState extends ChangeNotifier {
  final BuildContext _context;
  late final ToolRepository _toolRepository;
  List<Tool> _tools = [];
  Tool? _selectedTool;
  ToolDetails? _prompt;
  bool _isSidebarVisible = false;
  int _selectedNavRailIndex = 0;
  bool _isSettingsVisible = false;
  String? _outputText;
  bool _isVariableSectionVisible = false;
  String? _apiKey;

  HomeScreenState(this._context) {
    _toolRepository = GetIt.I.get<ToolRepository>();
    _loadTools();
    _loadApiKey();
  }

  String? get apiKey => _apiKey;
  List<Tool> get tools => _tools;
  Tool? get selectedTool => _selectedTool;
  ToolDetails? get prompt => _prompt;
  bool get isSidebarVisible => _isSidebarVisible;
  int get selectedNavRailIndex => _selectedNavRailIndex;
  bool get isSettingsVisible => _isSettingsVisible;
  String? get outputText => _outputText;
  bool get isVariableSectionVisible => _isVariableSectionVisible;

  void toggleVariableSection() {
    _isVariableSectionVisible = !_isVariableSectionVisible;
    notifyListeners();
  }

  Future<void> _loadApiKey() async {
    try {
      _apiKey = await getApiKey();
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading API key: $e');
    }
  }

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
    if (_selectedNavRailIndex == 2) {
      _isSettingsVisible = !_isSettingsVisible;
    } else {
      _isSettingsVisible = false;
    }
    notifyListeners();
  }

  void onToolSelected(Tool tool) {
    _selectedTool = tool;
    notifyListeners();
    _loadPromptAndVariables(tool.id);
  }

  Future<String?> getApiKey() async {
    final key = await ApiKeyManager.getApiKey();
    if (key == null || key.isEmpty) {
      return null;
    }
    return key;
  }

  Future<void> saveApiKey(String apiKey) async {
    await ApiKeyManager.saveApiKey(apiKey);
    await _loadApiKey();
    // Set the API key in the environment variables or use it as needed
    print('API key saved: $apiKey');
  }

  void setOutputText(String text) {
    _outputText = text;
    notifyListeners();
  }
}
