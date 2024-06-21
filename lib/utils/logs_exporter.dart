import 'dart:io';

import 'package:archive/archive.dart';
import 'package:flutter/foundation.dart';
import 'package:open_dir/open_dir.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';

class LogsExporter {
  void findResult(String path) async {
    final openDirPlugin = OpenDir();
    await openDirPlugin.openNativeDir(path: path);
  }

  Future<String?> createZipFile() async {
    final directory = await getApplicationSupportDirectory();
    final logDirectory = Directory(join(directory.path, 'logs'));
    final logFiles = await logDirectory.list().toList();

    final bytes = await _createZipFromFiles(logFiles);
    if (bytes == null) return null;

    final zipFilePath = join(directory.path, 'logs.zip');
    final zipFile = File(zipFilePath);
    await zipFile.writeAsBytes(bytes);

    if (kDebugMode) {
      print('Logs zip file created: ${zipFile.path}');
    }
    return zipFilePath;
  }

  Future<Uint8List?> _createZipFromFiles(List<FileSystemEntity> files) async {
    final archive = Archive();

    for (final file in files) {
      if (file is File) {
        final fileName = basename(file.path);
        final bytes = await file.readAsBytes();
        archive.addFile(ArchiveFile(fileName, bytes.length, bytes));
      }
    }

    final encoder = ZipEncoder();
    final bytes = encoder.encode(archive);
    if (bytes == null) return null;
    return Uint8List.fromList(bytes);
  }
}
