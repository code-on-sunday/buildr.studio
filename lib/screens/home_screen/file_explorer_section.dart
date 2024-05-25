import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';

class FileExplorerSection extends StatefulWidget {
  final void Function(String) onOpenFolder;

  const FileExplorerSection({
    super.key,
    required this.onOpenFolder,
  });

  @override
  _FileExplorerSectionState createState() => _FileExplorerSectionState();
}

class _FileExplorerSectionState extends State<FileExplorerSection> {
  String? _selectedFolderPath;
  List<FileSystemEntity> _files = [];

  Future<void> _loadFiles(String folderPath) async {
    try {
      final directory = Directory(folderPath);
      final files = await directory.list().toList();
      setState(() {
        _selectedFolderPath = folderPath;
        _files = files;
      });
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading files: $e');
    }
  }

  void _openFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: directory.path,
      );
      if (selectedDirectory != null) {
        _loadFiles(selectedDirectory);
        widget.onOpenFolder(selectedDirectory);
      }
    } catch (e) {
      // Log the error or display it to the UI
      print('Error selecting folder: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (_selectedFolderPath == null)
            ElevatedButton(
              onPressed: _openFolder,
              child: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened Folder: $_selectedFolderPath',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: _files.length,
                      itemBuilder: (context, index) {
                        final file = _files[index];
                        final fileName = file.path.split('/').last;
                        return ListTile(
                          title: Text(fileName),
                          trailing: file is Directory
                              ? const Icon(Icons.folder)
                              : const Icon(Icons.insert_drive_file),
                          onTap: () {
                            if (file is Directory) {
                              _loadFiles(file.path);
                            }
                          },
                        );
                      },
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
