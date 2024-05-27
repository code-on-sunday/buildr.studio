import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:volta/models/prompt.dart';
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

  Future<Prompt> getPromptAndVariables(String toolId) async {
    try {
      final toolDataJson =
          await rootBundle.loadString('assets/tools/$toolId.json');
      final toolData = json.decode(toolDataJson) as Map<String, dynamic>;

      final prompt = Prompt.fromJson(toolData);
      return prompt;
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading prompt and variables for tool $toolId: $e');
      rethrow;
    }
  }
}
