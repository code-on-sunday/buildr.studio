import 'package:flutter/foundation.dart';

class OutputSectionState extends ChangeNotifier {
  bool showRawText = false;

  void setShowRawText(bool value) {
    showRawText = value;
    notifyListeners();
  }
}
