import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/variable_manager.dart';
import 'package:buildr_studio/services/prompt_service/prompt_service.dart';

class PromptSubmitter {
  PromptSubmitter({
    required PromptService promptService,
  }) : _promptService = promptService;

  final PromptService _promptService;

  Future<void> submit(
    String? prompt,
    FileExplorerState fileExplorerState,
    VariableManager variableManager,
    DeviceRegistrationState deviceRegistrationState,
  ) async {
    if (prompt == null) return;

    final inflatedPrompt = variableManager.inflatePrompt(
        fileExplorerState.selectedFolderPath,
        fileExplorerState.gitIgnoreContent,
        prompt);

    _promptService.sendPrompt(
      deviceKey: await deviceRegistrationState.registerDevice(),
      prompt: inflatedPrompt,
    );
  }

  Future<String> exportPrompt(
    String? prompt,
    FileExplorerState fileExplorerState,
    VariableManager variableManager,
  ) async {
    if (prompt == null) return '';

    final inflatedPrompt = variableManager.inflatePrompt(
        fileExplorerState.selectedFolderPath,
        fileExplorerState.gitIgnoreContent,
        prompt);

    return inflatedPrompt;
  }
}
