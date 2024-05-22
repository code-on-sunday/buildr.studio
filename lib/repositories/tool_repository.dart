import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';

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

  Future<List<Variable>> getVariables(String toolId) async {
    try {
      final variablesJson =
          await rootBundle.loadString('assets/variables_$toolId.json');
      final variablesData = json.decode(variablesJson) as List<dynamic>;
      return variablesData.map((data) => Variable.fromJson(data)).toList();
    } catch (e) {
      // Log the error or display it to the UI
      print('Error loading variables for tool $toolId: $e');
      rethrow;
    }
  }
}
