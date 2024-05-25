import 'dart:io';

import 'package:flutter/material.dart';

class FileExplorerSection extends StatelessWidget {
  final String? selectedFolderPath;
  final List<FileSystemEntity> files;
  final void Function() onOpenFolder;

  const FileExplorerSection({
    super.key,
    required this.selectedFolderPath,
    required this.files,
    required this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (selectedFolderPath == null)
            ElevatedButton(
              onPressed: onOpenFolder,
              child: const Text('Open Project'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened Folder: $selectedFolderPath',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: files.length,
                      itemBuilder: (context, index) {
                        final file = files[index];
                        final fileName = file.path.split('/').last;
                        return ListTile(
                          title: Text(fileName),
                          trailing: file is Directory
                              ? const Icon(Icons.folder)
                              : const Icon(Icons.insert_drive_file),
                          onTap: () {
                            if (file is Directory) {
                              onOpenFolder();
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
