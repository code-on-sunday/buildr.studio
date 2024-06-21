import 'package:buildr_studio/screens/home_screen/settings/api_key_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsApiKey extends StatefulWidget {
  const SettingsApiKey({super.key, required this.title, required this.helpUrl});

  final String title;
  final String helpUrl;

  @override
  State<SettingsApiKey> createState() => _SettingsApiKeyState();
}

class _SettingsApiKeyState extends State<SettingsApiKey> {
  final _apiKeyController = TextEditingController();
  late final _apiKeyState = context.read<ApiKeyState>();
  late final _toolUsageManager = context.read<ToolUsageManager>();

  void _changeApiKey() {
    setState(() {
      _apiKeyController.text = _apiKeyState.apiKey ?? '';
    });
  }

  @override
  void initState() {
    _apiKeyController.text = _apiKeyState.apiKey ?? '';
    _apiKeyState.addListener(_changeApiKey);
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    _apiKeyState.removeListener(_changeApiKey);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadInput(
          controller: _apiKeyController,
          placeholder: Text('${widget.title}\'s API Key'),
        ),
        ShadButton(
          onPressed: () async {
            final apiKey = _apiKeyController.text.trim();
            if (apiKey.isNotEmpty) {
              try {
                await _apiKeyState.saveApiKey(apiKey);
                _toolUsageManager.reconnectAiService();
                ShadToaster.of(context).show(
                  const ShadToast(
                    description: Text('API key saved successfully.'),
                  ),
                );
              } catch (e) {
                ShadToaster.of(context).show(
                  ShadToast.destructive(
                    description: Text('Error saving API key: $e.'),
                  ),
                );
              }
            } else {
              ShadToaster.of(context).show(
                const ShadToast.destructive(
                  description: Text('Please enter a valid API key.'),
                ),
              );
            }
          },
          text: const Text('Save API Key'),
        ),
        ShadButton.link(
          padding: EdgeInsets.zero,
          onPressed: () async {
            await launchUrlString(widget.helpUrl);
          },
          text: const Text('How to get an API key?'),
        )
      ],
    );
  }
}
