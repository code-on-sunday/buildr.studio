import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';
import 'package:volta/utils/git_ignore_checker.dart';

class VariableSectionState extends ChangeNotifier {
  List<String> _selectedPaths = [];
  String? _concatenatedContent;

  List<String> get selectedPaths => _selectedPaths;
  String? get concatenatedContent => _concatenatedContent;

  void onPathsSelected(List<String> paths) {
    _selectedPaths = paths;
    notifyListeners();
  }

  String? getConcatenatedContent(BuildContext context) {
    try {
      final gitIgnoreContent =
          context.read<FileExplorerState>().gitIgnoreContent;
      if (gitIgnoreContent == null) {
        return null;
      }

      final concatenatedContent = StringBuffer();
      for (final p in _selectedPaths) {
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
      _concatenatedContent = concatenatedContent.toString().trim();
      return _concatenatedContent;
    } catch (e) {
      // Log or display the error to the UI
      print('Error concatenating file contents: $e');
      return null;
    }
  }
}
