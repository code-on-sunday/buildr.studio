import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:anthropic_sdk_dart/anthropic_sdk_dart.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:buildr_studio/utils/git_ignore_checker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:path/path.dart' as path;
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';


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

      final concatenatedContent = StringBuffer();
      for (final p in _selectedPaths[variableName]!) {
        final fileInfo = FileSystemEntity.typeSync(p);
        if (fileInfo == FileSystemEntityType.file) {
          final file = File(p);
          final relativePath =
              '${path.separator}${path.relative(file.path, from: context.read<FileExplorerState>().selectedFolderPath!)}';
          if (gitIgnoreContent == null ||
              !GitIgnoreChecker.isPathIgnored(gitIgnoreContent, relativePath)) {
            String? fileContent;
            try {
              fileContent = file.readAsStringSync();
            } catch (e) {}
            if (fileContent == null) {
              continue;
            }
            concatenatedContent.write('---${path.basename(p)}---\n```\n');
            concatenatedContent.write(fileContent);
            concatenatedContent.write('\n```\n');
          }
        } else if (fileInfo == FileSystemEntityType.directory) {
          final directory = Directory(p);
          final files =
              directory.listSync(recursive: true).whereType<File>().toList();
          for (final file in files) {
            final relativePath =
                '${path.separator}${path.relative(file.path, from: context.read<FileExplorerState>().selectedFolderPath!)}';
            if (gitIgnoreContent == null ||
                !GitIgnoreChecker.isPathIgnored(
                    gitIgnoreContent, relativePath)) {
              String? fileContent;
              try {
                fileContent = file.readAsStringSync();
              } catch (e) {}
              if (fileContent == null) {
                continue;
              }
              concatenatedContent.write('---${path.basename(p)}---\n```\n');
              concatenatedContent.write(fileContent);
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
          print('Error: API_KEY environment variable is not set.');
          _isRunning = false;
          notifyListeners();
          return;
        }
        var responseStream;
        String output = '';

        if (context.read<HomeScreenState>().IsgeminiAI) {
          final apiKey = await context.read<HomeScreenState>().getApiKey();
          Gemini.init(apiKey: apiKey!);
          final gemini = Gemini.instance;

          gemini.text(replacedPrompt).then((value) {
        
            responseStream = value?.output;
            context
                .read<HomeScreenState>()
                .setOutputText(output += responseStream);
          });

              /// or value?.content?.parts?.last.text
        } else {
          final client = AnthropicClient(apiKey: apiKey);

          client.createMessageStream(
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
          await for (final res in responseStream) {
            res.map(
              messageStart: (e) {
                print(e.message.usage);
              },
              messageDelta: (e) {
                print(e.usage);
              },
              messageStop: (e) {},
              contentBlockStart: (e) {},
              contentBlockDelta: (e) {
                context
                    .read<HomeScreenState>()
                    .setOutputText(output += e.delta.text);
              },
              contentBlockStop: (e) {},
              ping: (e) {},
            );
          }
        }
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
