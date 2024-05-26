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

  FileExplorerState() {
    ServicesBinding.instance.keyboard.addHandler(
      onKeyEvent,
    );
  }

  @override
  void dispose() {
    ServicesBinding.instance.keyboard.removeHandler(
      onKeyEvent,
    );
    super.dispose();
  }

  List<FileSystemEntity> get files => _files;
  Map<String, bool> get isExpanded => _isExpanded;
  Map<String, bool> get isSelected => _isSelected;
  bool get isControlPressed => _isControlPressed;
  String? get selectedFolderPath => _selectedFolderPath;

  Future<void> openFolder() async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final selectedDirectory = await FilePicker.platform.getDirectoryPath(
        initialDirectory: directory.path,
      );
      _loadFiles(selectedDirectory);
      if (selectedDirectory != null) {
        _selectedFolderPath = selectedDirectory;
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
    return true;
  }
}