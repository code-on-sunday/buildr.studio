import 'dart:async';

import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/models/tool_details.dart';
import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
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
  PromptServiceConnectionStatus _promptServiceConnectionStatus =
      const PromptServiceConnectionStatus.connected();
  final List<StreamSubscription> _promptServiceSubscriptions = [];

  ToolUsageManager({required PromptService promptService})
      : _variableManager = VariableManager(),
        _promptSubmitter = PromptSubmitter(
          promptService: promptService,
        ),
        _promptService = promptService {
    _listenForOutput();
    _promptService.connect();
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
  PromptServiceConnectionStatus get connectionStatus =>
      _promptServiceConnectionStatus;
  Stream<String> get errorStream => _promptService.errorStream;
  Stream<void> get endStream => _promptService.endStream;
  Stream<PromptServiceConnectionStatus> get connectionStatusStream =>
      _promptService.connectionStatusStream;

  @override
  void dispose() {
    _variableManager.dispose();
    _promptService.dispose();
    for (var subscription in _promptServiceSubscriptions) {
      subscription.cancel();
    }
    super.dispose();
  }

  void setInitialValues(ToolDetails toolDetails) {
    for (var variable in toolDetails.variables) {
      // TO-DO: Support other input types
      if (variable.inputType == 'text_field') {
        _variableManager.setInitialInputvalue(
            variable.name, variable.defaultValue);
      }
    }
    notifyListeners();
  }

  void reconnectAiService() {
    _promptService.connect();
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
    DeviceRegistrationState deviceRegistrationState,
  ) async {
    _output = '';
    _isResponseStreaming = true;
    _error = null;
    notifyListeners();
    try {
      await _promptSubmitter.submit(
        prompt,
        fileExplorerState,
        _variableManager,
        deviceRegistrationState,
      );
    } catch (e) {
      _isResponseStreaming = false;
      _output = '';
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<String> exportPrompt(
    String? prompt,
    FileExplorerState fileExplorerState,
  ) async {
    return _promptSubmitter.exportPrompt(
      prompt,
      fileExplorerState,
      _variableManager,
    );
  }

  void _listenForOutput() {
    _promptServiceSubscriptions.addAll([
      _promptService.responseStream.listen((chunk) {
        _output += chunk;
        notifyListeners();
      }),
      _promptService.errorStream.listen((error) {
        _isResponseStreaming = false;
        _output = '';
        _error = error;
        notifyListeners();
      }),
      _promptService.endStream.listen((_) {
        _isResponseStreaming = false;
        notifyListeners();
      }),
      _promptService.connectionStatusStream.listen((status) {
        if (status is Error) {
          _isResponseStreaming = false;
          _output = '';
        }
        _promptServiceConnectionStatus = status;
        notifyListeners();
      }),
    ]);
  }
}
