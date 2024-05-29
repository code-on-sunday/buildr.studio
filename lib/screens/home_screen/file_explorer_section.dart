import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path/path.dart' as path;
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';
import 'package:volta/utils/git_ignore_checker.dart';

class FileExplorerSection extends StatelessWidget {
  const FileExplorerSection({super.key});

  Widget _buildFileSystemEntityTile(
    BuildContext context,
    FileSystemEntity entity,
    int level,
    FileExplorerState fileExplorerState,
  ) {
    final fileName = fileExplorerState.getDisplayFileName(entity.path);
    final isSelected = fileExplorerState.isSelected[entity.path] ?? false;
    final isExpanded = fileExplorerState.isExpanded[entity.path] ?? false;
    var normalizedPath =
        '${path.separator}${path.relative(entity.path, from: fileExplorerState.selectedFolderPath!)}';
    if (entity is Directory) {
      normalizedPath += path.separator;
    }
    final isIgnored = fileExplorerState.gitIgnoreContent == null
        ? false
        : GitIgnoreChecker.isPathIgnored(
            fileExplorerState.gitIgnoreContent!,
            normalizedPath,
          );

    return MouseRegion(
      cursor:
          isIgnored ? SystemMouseCursors.forbidden : SystemMouseCursors.click,
      child: GestureDetector(
        onTap: isIgnored
            ? null
            : () {
                if (fileExplorerState.isControlPressed) {
                  fileExplorerState.toggleSelection(entity);
                } else {
                  if (entity is Directory) {
                    fileExplorerState.toggleExpansion(entity);
                  }
                  fileExplorerState.toggleSelection(entity);
                }
              },
        child: Container(
          color: isSelected ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              if (entity is Directory)
                RotatedBox(
                  quarterTurns: isExpanded ? 1 : 0,
                  child: GestureDetector(
                    onTap: () {
                      if (!fileExplorerState.isControlPressed || !isSelected) {
                        fileExplorerState.toggleExpansion(entity);
                      }
                    },
                    child: Icon(
                      isExpanded ? Icons.chevron_right : Icons.chevron_right,
                      color: isSelected
                          ? Colors.white
                          : (isIgnored ? Colors.grey : Colors.black),
                    ),
                  ),
                )
              else
                Icon(
                  Icons.insert_drive_file,
                  size: 12,
                  color: isSelected
                      ? Colors.white
                      : (isIgnored ? Colors.grey : Colors.black),
                ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  fileName,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.normal,
                    color: isSelected
                        ? Colors.white
                        : (isIgnored ? Colors.grey : Colors.black),
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

  Widget _buildFileSystemEntityTree(
    BuildContext context,
    List<FileSystemEntity> entities,
    int level,
  ) {
    final fileExplorerState = context.read<FileExplorerState>();
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
            (fileExplorerState.isExpanded[entity.path] ?? false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileSystemEntityTile(
                  context, entity, level, fileExplorerState),
              Padding(
                padding: const EdgeInsets.only(left: 16),
                child: _buildFileSystemEntityTree(
                  context,
                  Directory(entity.path).listSync().toList(),
                  level + 1,
                ),
              ),
            ],
          );
        } else {
          return _buildFileSystemEntityTile(
              context, entity, level, fileExplorerState);
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final fileExplorerState = context.watch<FileExplorerState>();
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fileExplorerState.selectedFolderPath == null)
            ElevatedButton(
              onPressed: fileExplorerState.openFolder,
              child: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Explorer: ${path.basename(fileExplorerState.selectedFolderPath!)}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      PopupMenuButton(
                        icon: const Icon(Icons.more_vert),
                        onSelected: (value) {
                          if (value == 'change_folder') {
                            fileExplorerState.openFolder();
                          }
                        },
                        itemBuilder: (context) => [
                          const PopupMenuItem(
                            value: 'change_folder',
                            child: Text('Change folder'),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: LongPressDraggable<List<String>>(
                        data: fileExplorerState.selectedPaths,
                        dragAnchorStrategy: pointerDragAnchorStrategy,
                        feedback: const CollectionIcon(),
                        child: _buildFileSystemEntityTree(
                          context,
                          fileExplorerState.files,
                          0,
                        ),
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

class CollectionIcon extends StatelessWidget {
  const CollectionIcon({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.black,
          borderRadius: BorderRadius.circular(8),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ]),
      child: const Icon(
        Icons.collections,
        color: Colors.white,
        size: 24,
      ),
    );
  }
}
