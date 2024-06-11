import 'dart:async';

import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/prompt_submitter.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_manager.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:flutter/material.dart';

class ToolUsageManager extends ChangeNotifier {
  final VariableManager _variableManager;
  final PromptSubmitter _promptSubmitter;
  final PromptService _promptService;
  String _output = '';
  String? _error;
  bool _isResponseStreaming = false;

  ToolUsageManager({required PromptService promptService})
      : _variableManager = VariableManager(),
        _promptSubmitter = PromptSubmitter(
          promptService: promptService,
        ),
        _promptService = promptService {
    //TODO: Wait for the device to be registered before connecting to the prompt service
    Future.delayed(const Duration(seconds: 3), () {
      _listenForOutput();
    });

    _variableManager.addListener(() {
      notifyListeners();
    });
  }

  Map<String, List<String>> get selectedPaths => _variableManager.selectedPaths;
  Map<String, String?> get concatenatedContents =>
      _variableManager.concatenatedContents;
  Map<String, String> get inputValues => _variableManager.inputValues;
  Stream<bool> get clearValuesStream => _variableManager.clearValuesStream;

  bool get isResponseStreaming => _isResponseStreaming;
  String get output => _output;
  String? get error => _error;

  @override
  void dispose() {
    _variableManager.dispose();
    _promptService.dispose();
    super.dispose();
  }

  void onPathsSelected(String variableName, List<String> paths) {
    _variableManager.onPathsSelected(variableName, paths);
  }

  void setInputValue(String variableName, String value) {
    _variableManager.setInputValue(variableName, value);
  }

  void clearValues() {
    _variableManager.clearValues();
  }

  Future<void> submitPrompt(
    String? prompt,
    FileExplorerState fileExplorerState,
  ) async {
    _output = '';
    _isResponseStreaming = true;
    notifyListeners();
    try {
      await _promptSubmitter.submit(
        prompt,
        fileExplorerState,
        _variableManager,
      );
    } catch (e) {
      _isResponseStreaming = false;
      _output = '';
      _error = e.toString();
      notifyListeners();
    }
  }

  void _listenForOutput() {
    _promptService.connect();

    _promptService.responseStream.listen((chunk) {
      _output += chunk;
      notifyListeners();
    });

    _promptService.errorStream.listen((error) {
      _isResponseStreaming = false;
      _output = '';
      _error = error;
      notifyListeners();
    });

    _promptService.endStream.listen((_) {
      _isResponseStreaming = false;
      notifyListeners();
    });
  }
}
