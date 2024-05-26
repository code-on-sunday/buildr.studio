import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FileExplorerSection extends StatefulWidget {
  final String? selectedFolderPath;
  final void Function() onOpenFolder;

  const FileExplorerSection({
    super.key,
    required this.selectedFolderPath,
    required this.onOpenFolder,
  });

  @override
  _FileExplorerSectionState createState() => _FileExplorerSectionState();
}

class _FileExplorerSectionState extends State<FileExplorerSection> {
  List<FileSystemEntity> _files = [];
  Map<String, bool> _isExpanded = {};
  Map<String, bool> _isSelected = {};
  bool _isControlPressed = false;

  @override
  void initState() {
    super.initState();
    _loadFiles(widget.selectedFolderPath);
    ServicesBinding.instance.keyboard.addHandler(_onKeyEvent);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(_onKeyEvent);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant FileExplorerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFolderPath != oldWidget.selectedFolderPath) {
      _loadFiles(widget.selectedFolderPath);
    }
  }

  bool _onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        setState(() {
          _isControlPressed = true;
        });
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        setState(() {
          _isControlPressed = false;
        });
      }
    }
    return true;
  }

  Future<void> _loadFiles(String? folderPath) async {
    if (folderPath == null) return;
    try {
      final directory = Directory(folderPath);
      final files = await directory.list().toList();
      setState(() {
        _files = files;
        _isExpanded = {
          for (final entity in files)
            if (entity is Directory) entity.path: false
        };
        _isSelected = {for (final entity in files) entity.path: false};
      });
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading files: $e');
    }
  }

  Widget _buildFileSystemEntityTile(FileSystemEntity entity, int level) {
    final fileName = _getDisplayFileName(entity);
    final isSelected = _isSelected[entity.path] ?? false;
    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: GestureDetector(
        onTap: () {
          setState(() {
            if (entity is Directory) {
              _isExpanded[entity.path] = !(_isExpanded[entity.path] ?? false);
            }
            if (_isControlPressed) {
              _isSelected[entity.path] = !(_isSelected[entity.path] ?? false);
            } else {
              _isSelected.forEach((key, value) {
                _isSelected[key] = false;
              });
              _isSelected[entity.path] = true;
            }
          });
        },
        child: Container(
          color: isSelected ? Colors.black : Colors.transparent,
          padding: const EdgeInsets.all(4),
          child: Row(
            children: [
              if (entity is Directory)
                RotatedBox(
                  quarterTurns: _isExpanded[entity.path] ?? false ? 1 : 0,
                  child: Icon(
                    _isExpanded[entity.path] ?? false
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
      final rootFolderPath = widget.selectedFolderPath;
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
        if (entity is Directory && (_isExpanded[entity.path] ?? false)) {
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
          if (widget.selectedFolderPath == null)
            ElevatedButton(
              onPressed: widget.onOpenFolder,
              child: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened Folder: ${widget.selectedFolderPath}',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: SingleChildScrollView(
                      child: _buildFileSystemEntityTree(_files, 0),
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
