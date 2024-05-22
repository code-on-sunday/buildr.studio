import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:volta/models/tool.dart';

class ToolRepository {
  Future<List<Tool>> getTools() async {
    try {
      final toolsJson = await rootBundle.loadString('assets/tools.json');
      final toolsData = json.decode(toolsJson) as List<dynamic>;
      return toolsData.map((data) => Tool.fromJson(data)).toList();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading tools: $e');
      rethrow;
    }
  }
}
