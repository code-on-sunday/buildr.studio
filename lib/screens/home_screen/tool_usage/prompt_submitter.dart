import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_manager.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class PromptSubmitter {
  PromptSubmitter({
    required PromptService promptService,
  }) : _promptService = promptService;

  final PromptService _promptService;

  Future<void> submit(
      BuildContext context, VariableManager variableManager) async {
    final prompt = context.read<HomeScreenState>().prompt?.prompt;

    if (prompt == null) return;

    final inflatedPrompt = variableManager.inflatePrompt(
        context.read<FileExplorerState>().selectedFolderPath,
        context.read<FileExplorerState>().gitIgnoreContent,
        prompt);

    _promptService.sendPrompt(inflatedPrompt);
  }
}
