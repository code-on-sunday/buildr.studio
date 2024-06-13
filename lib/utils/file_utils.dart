import 'dart:io';

import 'package:buildr_studio/utils/git_ignore_checker.dart';
import 'package:get_it/get_it.dart';
import 'package:logger/logger.dart';
import 'package:path/path.dart' as path;

class FileUtils {
  FileUtils({GitIgnoreChecker? gitIgnoreChecker})
      : _gitIgnoreChecker = gitIgnoreChecker ?? GitIgnoreChecker();

  final _logger = GetIt.I.get<Logger>();
  final GitIgnoreChecker _gitIgnoreChecker;

  String? getConcatenatedContent(
    List<String> selectedPaths,
    String? gitIgnoreContent,
    String rootDir,
  ) {
    try {
      final concatenatedContent = StringBuffer();
      for (final p in selectedPaths) {
        final fileInfo = FileSystemEntity.typeSync(p);
        if (fileInfo == FileSystemEntityType.file) {
          final file = File(p);
          final relativePath =
              '${path.separator}${path.relative(file.path, from: rootDir)}';
          if (gitIgnoreContent == null ||
              !_gitIgnoreChecker.isPathIgnored(
                  gitIgnoreContent, relativePath)) {
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
            final relativePath =
                '${path.separator}${path.relative(file.path, from: rootDir)}';
            if (gitIgnoreContent == null ||
                !_gitIgnoreChecker.isPathIgnored(
                    gitIgnoreContent, relativePath)) {
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
}
