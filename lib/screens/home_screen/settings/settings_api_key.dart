import 'package:buildr_studio/screens/home_screen/api_key_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
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

  @override
  void initState() {
    context.read<ApiKeyState>().addListener(() {
      _apiKeyController.text = context.read<ApiKeyState>().apiKey ?? '';
    });
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _apiKeyController,
          decoration: InputDecoration(
            labelText: '${widget.title}\'s API Key',
            border: const OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 16),
        ElevatedButton(
          onPressed: () async {
            final apiKey = _apiKeyController.text.trim();
            if (apiKey.isNotEmpty) {
              try {
                await context.read<ApiKeyState>().saveApiKey(apiKey);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('API key saved successfully.'),
                  ),
                );
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error saving API key: $e.'),
                  ),
                );
              }
            } else {
              // Display an error message to the user
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Please enter a valid API key.'),
                ),
              );
            }
          },
          child: const Text('Save API Key'),
        ),
        TextButton(
            onPressed: () async {
              await launchUrlString(widget.helpUrl);
            },
            child: const Text('How to get an API key?',
                style: TextStyle(color: Colors.blue)))
      ],
    );
  }
}
