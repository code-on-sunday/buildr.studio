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
      });
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading files: $e');
    }
  }

  Widget _buildFileSystemEntityTile(FileSystemEntity entity) {
    final fileName = entity.path.split('/').last;
    return ListTile(
      title: Text(_toSnakeCase(fileName)),
      trailing: entity is Directory
          ? const Icon(Icons.folder)
          : const Icon(Icons.insert_drive_file),
      onTap: () {
        if (entity is Directory) {
          _loadFiles(entity.path);
        }
      },
    );
  }

  Widget _buildFileSystemEntityTree(List<FileSystemEntity> entities) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entities.map((entity) {
        if (entity is Directory) {
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

  String _toSnakeCase(String input) {
    return input.replaceAll(' ', '_').toLowerCase();
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
