import 'dart:async';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

class FileExplorerState extends ChangeNotifier {
  List<FileSystemEntity> _files = [];
  Map<String, bool> _isExpanded = {};
  Map<String, bool> _isSelected = {};
  bool _isControlPressed = false;
  String? _selectedFolderPath;
  String? _gitIgnoreContent;
  final DirectoryWatcher _directoryWatcher = DirectoryWatcher();

  FileExplorerState() {
    ServicesBinding.instance.keyboard.addHandler(
      onKeyEvent,
    );
    _directoryWatcher.events.listen(_onDirectoryChanged);
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(
      onKeyEvent,
    );
    _directoryWatcher.dispose();
    super.dispose();
  }

  List<FileSystemEntity> get files => _files;
  Map<String, bool> get isExpanded => _isExpanded;
  Map<String, bool> get isSelected => _isSelected;
  bool get isControlPressed => _isControlPressed;
  String? get selectedFolderPath => _selectedFolderPath;
  String? get gitIgnoreContent => _gitIgnoreContent;
  List<String> get selectedPaths {
    final selectedPaths = <String>[];
    final selectedEntries = _isSelected.entries.where((entry) => entry.value);
    for (final entry in selectedEntries) {
      if (entry.value) {
        bool isDescendant = false;
        for (final folderPath in selectedEntries.map((e) => e.key)) {
          if (entry.key.startsWith(folderPath) && entry.key != folderPath) {
            isDescendant = true;
            break;
          }
        }
        if (!isDescendant) {
          selectedPaths.add(entry.key);
        }
      }
    }
    return selectedPaths;
  }

  Future<void> openFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: directory.path,
      );
      _loadFiles(selectedDirectory);
      if (selectedDirectory != null) {
        _selectedFolderPath = selectedDirectory;
        _directoryWatcher.folderPath = selectedDirectory;
        await _loadGitIgnoreContent();
        notifyListeners();
      }
    } catch (e) {
      // Log the error or display it to the UI
      print('Error selecting folder: $e');
    }
  }

  Future<void> _loadFiles(String? folderPath) async {
    if (folderPath == null) return;
    try {
      final directory = Directory(folderPath);
      final files = await directory.list().toList();
      _files = files;
      _isExpanded = {
        for (final entity in files)
          if (entity is Directory) entity.path: false
      };
      _isSelected = {for (final entity in files) entity.path: false};
      notifyListeners();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading files: $e');
    }
  }

  Future<void> _loadGitIgnoreContent() async {
    try {
      final gitIgnorePath = '$_selectedFolderPath/.gitignore';
      if (await File(gitIgnorePath).exists()) {
        final gitIgnoreFile = File(gitIgnorePath);
        _gitIgnoreContent = await gitIgnoreFile.readAsString();
      } else {
        _gitIgnoreContent = null;
      }
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading .gitignore file: $e');
      _gitIgnoreContent = null;
    }
  }

  void _onDirectoryChanged(DirectoryChangeEvent event) {
    if (event.type == ChangeType.create || event.type == ChangeType.delete) {
      _loadFiles(_selectedFolderPath);
      notifyListeners();
    }
  }

  void toggleExpansion(FileSystemEntity entity) {
    if (entity is Directory) {
      _isExpanded[entity.path] = !(_isExpanded[entity.path] ?? false);
      notifyListeners();
    }
  }

  void toggleSelection(FileSystemEntity entity) {
    if (_isControlPressed) {
      _isSelected[entity.path] = !(_isSelected[entity.path] ?? false);
    } else {
      _isSelected.forEach((key, value) {
        _isSelected[key] = false;
      });
      _isSelected[entity.path] = true;
    }
    notifyListeners();
  }

  bool onKeyEvent(KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _isControlPressed = true;
        notifyListeners();
      }
    } else if (event is KeyUpEvent) {
      if (event.logicalKey == LogicalKeyboardKey.controlLeft ||
          event.logicalKey == LogicalKeyboardKey.controlRight) {
        _isControlPressed = false;
        notifyListeners();
      }
    }
    return false;
  }

  String getDisplayFileName(String path) {
    try {
      final parts = path.split(Platform.pathSeparator);
      final rootFolderPath = selectedFolderPath;
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
      return path.split(Platform.pathSeparator).last;
    }
  }
}

class DirectoryWatcher {
  late Directory _directory;
  late final StreamController<DirectoryChangeEvent> _controller;
  StreamSubscription<FileSystemEvent>? _directorySubscription;

  DirectoryWatcher() {
    _controller = StreamController.broadcast();
  }

  String? _folderPath;
  set folderPath(String? value) {
    _folderPath = value;
    _directory = Directory(_folderPath ?? '');
    _startWatching();
  }

  Stream<DirectoryChangeEvent> get events => _controller.stream;
  void _startWatching() {
    _directorySubscription?.cancel();
    _directorySubscription = _directory.watch().listen((event) {
      _controller.sink.add(DirectoryChangeEvent(
        type: _getChangeType(event),
        path: event.path,
      ));
    });
  }

  ChangeType _getChangeType(FileSystemEvent event) {
    switch (event) {
      case FileSystemCreateEvent():
        return ChangeType.create;
      case FileSystemDeleteEvent():
        return ChangeType.delete;
      case FileSystemModifyEvent():
        return ChangeType.modify;
      case FileSystemMoveEvent():
        return ChangeType.move;
    }
  }

  void dispose() {
    _directorySubscription?.cancel();
    _controller.close();
  }
}

enum ChangeType { create, delete, modify, move }

class DirectoryChangeEvent {
  final ChangeType type;
  final String path;
  DirectoryChangeEvent({
    required this.type,
    required this.path,
  });
}
