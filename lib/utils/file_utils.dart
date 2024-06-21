import 'dart:io';

import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  final _logger = GetIt.I.get<Logger>();

  String? getConcatenatedContent(
    List<String> selectedPaths,
    bool Function(String) isPathIgnored,
    String rootDir,
  ) {
    try {
      final concatenatedContent = StringBuffer();
      for (final p in selectedPaths) {
        final fileInfo = FileSystemEntity.typeSync(p);
        final relativePath =
            '${path.separator}${path.relative(p, from: rootDir)}';
        if (fileInfo == FileSystemEntityType.file) {
          final file = File(p);
          if (!isPathIgnored(p)) {
            String? fileContent;
            try {
              fileContent = file.readAsStringSync();
            } catch (e) {}
            if (fileContent == null) {
              continue;
            }
            concatenatedContent.write('---$relativePath---\n```\n');
            concatenatedContent.write(fileContent);
            concatenatedContent.write('\n```\n');
          }
        } else if (fileInfo == FileSystemEntityType.directory) {
          final directory = Directory(p);
          final files =
              directory.listSync(recursive: true).whereType<File>().toList();
          for (final file in files) {
            if (!isPathIgnored(file.path)) {
              String? fileContent;
              try {
                fileContent = file.readAsStringSync();
              } catch (e) {}
              if (fileContent == null) {
                continue;
              }
              concatenatedContent.write('---$relativePath---\n```\n');
              concatenatedContent.write(fileContent);
              concatenatedContent.write('\n```\n');
            }
          }
        }
      }
      final content = concatenatedContent.toString().trim();
      return content;
    } catch (e) {
      _logger.e('Error concatenating file contents: $e');
      return null;
    }
  }

  String getDisplayFileName(String? rootFolderPath, String path) {
    try {
      final parts = path.split(Platform.pathSeparator);
      if (rootFolderPath != null && path.startsWith(rootFolderPath)) {
        final relativePath = path.substring(rootFolderPath.length + 1);
        final fileName = relativePath.split(Platform.pathSeparator).last;
        return fileName;
      } else {
        return parts.last;
      }
    } catch (e) {
      _logger.e('Error getting display file name: $e');
      return path.split(Platform.pathSeparator).last;
    }
  }
}
