import 'package:flutter/material.dart';

class VariableSectionState extends ChangeNotifier {
  List<String> _selectedPaths = [];

  List<String> get selectedPaths => _selectedPaths;

  void onPathsSelected(List<String> paths) {
    _selectedPaths = paths;
    notifyListeners();
  }
}
