import 'dart:async';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';
import 'package:volta/screens/home_screen_state.dart';
import 'package:volta/utils/git_ignore_checker.dart';

class VariableSectionState extends ChangeNotifier {
  final Map<String, List<String>> _selectedPaths = {};
  final Map<String, String?> _concatenatedContents = {};
  final Map<String, String> _inputValues = {};
  bool _isRunning = false;

  final _clearValuesStreamController = StreamController<bool>.broadcast();
  late final Stream<bool> clearValuesStream;

  VariableSectionState() {
    clearValuesStream = _clearValuesStreamController.stream;
  }

  Map<String, List<String>> get selectedPaths => _selectedPaths;
  Map<String, String?> get concatenatedContents => _concatenatedContents;
  Map<String, String> get inputValues => _inputValues;
  bool get isRunning => _isRunning;

  @override
  void dispose() {
    _clearValuesStreamController.close();
    super.dispose();
  }

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

  String? getConcatenatedContent(BuildContext context, String variableName) {
    if (!_selectedPaths.containsKey(variableName) ||
        _selectedPaths[variableName]?.isEmpty == true) {
      return null;
    }

    try {
      final gitIgnoreContent =
          context.read<FileExplorerState>().gitIgnoreContent;
      if (gitIgnoreContent == null) {
        return null;
      }

      final concatenatedContent = StringBuffer();
      for (final p in _selectedPaths[variableName]!) {
        final fileInfo = FileSystemEntity.typeSync(p);
        if (fileInfo == FileSystemEntityType.file) {
          final file = File(p);
          final relativePath =
              '${path.separator}${path.relative(file.path, from: context.read<FileExplorerState>().selectedFolderPath!)}';
          if (!GitIgnoreChecker.isPathIgnored(gitIgnoreContent, relativePath)) {
            concatenatedContent.write('---${path.basename(p)}---\n```\n');
            concatenatedContent.write(file.readAsStringSync());
            concatenatedContent.write('\n```\n');
          }
        } else if (fileInfo == FileSystemEntityType.directory) {
          final directory = Directory(p);
          final files =
              directory.listSync(recursive: true).whereType<File>().toList();
          for (final file in files) {
            final relativePath =
                '${path.separator}${path.relative(file.path, from: context.read<FileExplorerState>().selectedFolderPath!)}';
            if (!GitIgnoreChecker.isPathIgnored(
                gitIgnoreContent, relativePath)) {
              concatenatedContent
                  .write('---${path.basename(file.path)}---\n```\n');
              concatenatedContent.write(file.readAsStringSync());
              concatenatedContent.write('\n```\n');
            }
          }
        }
      }
      final content = concatenatedContent.toString().trim();
      _concatenatedContents[variableName] = content;
      return content;
    } catch (e) {
      // Log or display the error to the UI
      print('Error concatenating file contents for variable $variableName: $e');
      return null;
    }
  }

  Future<void> submit(BuildContext context) async {
    _isRunning = true;
    notifyListeners();

    for (final entry in _inputValues.entries) {
      print('${entry.key}: ${entry.value}');
    }

    for (final variableName in _selectedPaths.keys) {
      _concatenatedContents[variableName] =
          getConcatenatedContent(context, variableName);
    }

    final prompt = context.read<HomeScreenState>().prompt?.prompt;
    if (prompt != null) {
      final replacedPrompt = _replacePromptPlaceholders(prompt);

      try {
        final apiKey = await context.read<HomeScreenState>().getApiKey();
        if (apiKey == null) {
          print('Error: ANTHROPIC_API_KEY environment variable is not set.');
          _isRunning = false;
          notifyListeners();
          return;
        }

        final client = AnthropicClient(apiKey: apiKey);
        final response = await client.createMessage(
          request: CreateMessageRequest(
            model: const Model.model(Models.claude3Haiku20240307),
            maxTokens: 4000,
            messages: [
              Message(
                role: MessageRole.user,
                content: MessageContent.text(replacedPrompt),
              ),
            ],
          ),
        );

        context.read<HomeScreenState>().setOutputText(response.content.text);
      } catch (e) {
        print('Error calling Anthropic API: $e');
        context.read<HomeScreenState>().setOutputText('Error: $e');
      } finally {
        _isRunning = false;
        notifyListeners();
      }
    } else {
      print('No prompt available');
      _isRunning = false;
      notifyListeners();
    }
  }

  String _replacePromptPlaceholders(String prompt) {
    for (final entry in _inputValues.entries) {
      prompt = prompt.replaceAll('{{${entry.key}}}', entry.value);
    }

    for (final entry in _concatenatedContents.entries) {
      prompt = prompt.replaceAll('{{${entry.key}}}', entry.value ?? '');
    }

    return prompt;
  }
}
