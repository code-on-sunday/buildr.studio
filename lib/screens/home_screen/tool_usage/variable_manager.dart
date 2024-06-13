import 'dart:async';

import 'package:buildr_studio/utils/file_utils.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';

class VariableManager extends ChangeNotifier {
  final _logger = GetIt.I.get<Logger>();

  final Map<String, List<String>> _selectedPaths = {};
  final Map<String, String?> _concatenatedContents = {};
  final Map<String, String> _inputValues = {};

  final _clearValuesStreamController = StreamController<bool>.broadcast();
  late final Stream<bool> clearValuesStream;

  VariableManager() {
    clearValuesStream = _clearValuesStreamController.stream;
  }

  @override
  void dispose() {
    _clearValuesStreamController.close();
    super.dispose();
  }

  Map<String, List<String>> get selectedPaths => _selectedPaths;
  Map<String, String?> get concatenatedContents => _concatenatedContents;
  Map<String, String> get inputValues => _inputValues;

  void onPathsSelected(String variableName, List<String> paths) {
    _selectedPaths[variableName] = paths;
    _concatenatedContents[variableName] = null;
    notifyListeners();
  }

  void setInputValue(String variableName, String value) {
    _inputValues[variableName] = value;
    notifyListeners();
  }

  void clearValues() {
    _selectedPaths.clear();
    _concatenatedContents.clear();
    _inputValues.clear();
    _clearValuesStreamController.add(true);
    notifyListeners();
  }

  String? _getConcatenatedContent(
      String? rootDir, String? gitIgnoreContent, String variableName) {
    if (rootDir == null) return null;

    if (!_selectedPaths.containsKey(variableName) ||
        _selectedPaths[variableName]?.isEmpty == true) {
      return null;
    }

    try {
      return GetIt.I.get<FileUtils>().getConcatenatedContent(
            _selectedPaths[variableName]!,
            gitIgnoreContent,
            rootDir,
          );
    } catch (e) {
      _logger.e(
          'Error concatenating file contents for variable $variableName: $e');
      return null;
    }
  }

  String inflatePrompt(
      String? rootDir, String? gitIgnoreContent, String prompt) {
    for (final variableName in _selectedPaths.keys) {
      _concatenatedContents[variableName] =
          _getConcatenatedContent(rootDir, gitIgnoreContent, variableName);
    }
    for (final entry in _inputValues.entries) {
      prompt = prompt.replaceAll('{{${entry.key}}}', entry.value);
    }

    for (final entry in _concatenatedContents.entries) {
      prompt = prompt.replaceAll('{{${entry.key}}}', entry.value ?? '');
    }

    return prompt;
  }
}
