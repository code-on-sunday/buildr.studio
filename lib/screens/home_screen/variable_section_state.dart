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

  String? getConcatenatedContent(BuildContext context, List<String> paths) {
    try {
      final gitIgnoreContent =
          context.read<FileExplorerState>().gitIgnoreContent;
      if (gitIgnoreContent == null) {
        return null;
      }

      final concatenatedContent = StringBuffer();
      for (final p in paths) {
        final file = File(p);
        final relativePath =
            '${path.separator}${path.relative(p, from: context.read<FileExplorerState>().selectedFolderPath!)}';
        if (!GitIgnoreChecker.isPathIgnored(gitIgnoreContent, relativePath)) {
          concatenatedContent.write(file.readAsStringSync());
          concatenatedContent.write('\n');
        }
      }
      return concatenatedContent.toString().trim();
    } catch (e) {
      // Log or display the error to the UI
      print('Error concatenating file contents: $e');
      return null;
    }
  }
}
