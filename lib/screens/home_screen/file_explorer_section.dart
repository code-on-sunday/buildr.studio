import 'package:flutter/material.dart';

class FileExplorerSection extends StatelessWidget {
  final String? openedFolderPath;
  final void Function(String) onOpenFolder;

  const FileExplorerSection({
    super.key,
    this.openedFolderPath,
    required this.onOpenFolder,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (openedFolderPath == null)
            ElevatedButton(
              onPressed: () {
                // Implement folder selection logic
                onOpenFolder('/path/to/folder');
              },
              child: const Text('Open Folder'),
            )
          else
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Opened Folder: $openedFolderPath',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: ListView.builder(
                      itemCount: 20,
                      itemBuilder: (context, index) {
                        final fileName = 'file_${index + 1}.txt';
                        return ListTile(
                          title: Text(fileName),
                          trailing: const Icon(Icons.insert_drive_file),
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
