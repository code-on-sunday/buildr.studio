import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsSection extends StatefulWidget {
  const SettingsSection({super.key});

  @override
  State<SettingsSection> createState() => _SettingsSectionState();
}

class _SettingsSectionState extends State<SettingsSection> {
  final _apiKeyController = TextEditingController();


  @override
  void initState() {
    _apiKeyController.text = context.read<HomeScreenState>().apiKey ?? '';
    super.initState();
  }

  @override
  void dispose() {
    _apiKeyController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Settings',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _apiKeyController,
            decoration: const InputDecoration(
              labelText: 'Claude AI\'s or Gemini AI\'s API Key',
              border: OutlineInputBorder(),
            ),
          ),
          // fluent_ui.ToggleSwitch(
          //   checked: checked,
          //   onChanged: (v) => setState(() => checked = v)
          // ),
                    const SizedBox(height: 16),

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
            const Text('Gemeni AI\'s API Key turn on this switch:'),
            Switch(
              // value: _,
              value: context.watch<HomeScreenState>().IsgeminiAI,
              onChanged: (v) {
                context.read<HomeScreenState>().setIsgeminiAI(v);
              }
              ),
            
          ],),

          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () async {
              final apiKey = _apiKeyController.text.trim();
              if (apiKey.isNotEmpty) {
                try {
                  await context.read<HomeScreenState>().saveApiKey(apiKey);

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
                await launchUrlString(
                    "https://www.buildr.studio/blog/cach-lay-api-key-claude-anthropic");
              },
              child: const Text('How to get an API key?',
                  style: TextStyle(color: Colors.blue)))
        ],
      ),
    );
  }
}
