import 'dart:convert';

import 'package:buildr_studio/models/tool.dart';
import 'package:buildr_studio/models/tool_details.dart';
import 'package:flutter/services.dart';

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

  Future<ToolDetails> getToolDetails(String toolId) async {
    try {
      final toolDataJson =
          await rootBundle.loadString('assets/tools/$toolId.json');
      final toolData = json.decode(toolDataJson) as Map<String, dynamic>;

      final prompt = ToolDetails.fromJson(toolData);
      return prompt;
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading prompt and variables for tool $toolId: $e');
      rethrow;
    }
  }
}
