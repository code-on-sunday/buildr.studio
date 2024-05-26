import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';

class FileExplorerSection extends StatefulWidget {
  const FileExplorerSection({super.key});

  @override
  _FileExplorerSectionState createState() => _FileExplorerSectionState();
}

class _FileExplorerSectionState extends State<FileExplorerSection> {
  Widget _buildFileSystemEntityTile(FileSystemEntity entity, int level) {
    final fileName = _getDisplayFileName(entity);
    final isSelected =
        context.watch<FileExplorerState>().isSelected[entity.path] ?? false;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          context.read<FileExplorerState>().toggleExpansion(entity);
          context.read<FileExplorerState>().toggleSelection(entity);
        },
        child: Container(
          color: isSelected ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              if (entity is Directory)
                RotatedBox(
                  quarterTurns: context
                              .watch<FileExplorerState>()
                              .isExpanded[entity.path] ??
                          false
                      ? 1
                      : 0,
                  child: Icon(
                    context
                                .watch<FileExplorerState>()
                                .isExpanded[entity.path] ??
                            false
                        ? Icons.chevron_right
                        : Icons.chevron_right,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                )
              else
                Icon(
                  Icons.insert_drive_file,
                  size: 12,
                  color: isSelected ? Colors.white : Colors.black,
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: isSelected ? Colors.white : Colors.black,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _getDisplayFileName(FileSystemEntity entity) {
    try {
      final path = entity.path;
      final parts = path.split(Platform.pathSeparator);
      final rootFolderPath =
          context.read<FileExplorerState>().selectedFolderPath;
      if (rootFolderPath != null && path.startsWith(rootFolderPath)) {
        final relativePath = path.substring(rootFolderPath.length + 1);
        final fileName = relativePath.split(Platform.pathSeparator).last;
        return fileName;
      } else {
        return parts.last;
      }
    } catch (e) {
      // Log the error or display it to the UI
      print('Error getting display file name: $e');
      return entity.path.split(Platform.pathSeparator).last;
    }
  }

  Widget _buildFileSystemEntityTree(
      List<FileSystemEntity> entities, int level) {
    final folders = <Directory>[];
    final files = <File>[];

    for (final entity in entities) {
      if (entity is Directory) {
        folders.add(entity);
      } else if (entity is File) {
        files.add(entity);
      }
    }

    folders
        .sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));
    files.sort((a, b) => a.path.toLowerCase().compareTo(b.path.toLowerCase()));

    final sortedEntities = [...folders, ...files];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: sortedEntities.map((entity) {
        if (entity is Directory &&
            (context.watch<FileExplorerState>().isExpanded[entity.path] ??
                false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileSystemEntityTile(entity, level),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildFileSystemEntityTree(
                  Directory(entity.path).listSync().toList(),
                  level + 1,
                ),
              ),
            ],
          );
        } else {
          return _buildFileSystemEntityTile(entity, level);
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (context.watch<FileExplorerState>().selectedFolderPath == null)
            ElevatedButton(
              onPressed: context.read<FileExplorerState>().openFolder,
              child: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened Folder: ${context.watch<FileExplorerState>().selectedFolderPath}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFileSystemEntityTree(
                        context.watch<FileExplorerState>().files,
                        0,
                      ),
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
