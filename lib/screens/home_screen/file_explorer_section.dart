import 'dart:io';

import 'package:flutter/material.dart';

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

  @override
  void initState() {
    super.initState();
    _loadFiles(widget.selectedFolderPath);
  }

  @override
  void didUpdateWidget(covariant FileExplorerSection oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selectedFolderPath != oldWidget.selectedFolderPath) {
      _loadFiles(widget.selectedFolderPath);
    }
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
      });
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading files: $e');
    }
  }

  Widget _buildFileSystemEntityTile(FileSystemEntity entity) {
    final fileName = _getDisplayFileName(entity);
    return ListTile(
      title: Text(fileName),
      trailing: entity is Directory
          ? IconButton(
              icon: Icon(_isExpanded[entity.path] ?? false
                  ? Icons.arrow_drop_down
                  : Icons.arrow_right),
              onPressed: () {
                setState(() {
                  _isExpanded[entity.path] =
                      !(_isExpanded[entity.path] ?? false);
                });
              },
            )
          : const Icon(Icons.insert_drive_file),
      onTap: () {
        if (entity is Directory) {
          setState(() {
            _isExpanded[entity.path] = !(_isExpanded[entity.path] ?? false);
          });
        }
      },
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

  Widget _buildFileSystemEntityTree(List<FileSystemEntity> entities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entities.map((entity) {
        if (entity is Directory && (_isExpanded[entity.path] ?? false)) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFileSystemEntityTile(entity),
              Padding(
                padding: const EdgeInsets.only(left: 16.0),
                child: _buildFileSystemEntityTree(
                  Directory(entity.path).listSync().toList(),
                ),
              ),
            ],
          );
        } else {
          return _buildFileSystemEntityTile(entity);
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
                        child: _buildFileSystemEntityTree(_files)),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
