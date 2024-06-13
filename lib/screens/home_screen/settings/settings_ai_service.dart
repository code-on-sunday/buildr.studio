import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/settings_ai_service_buildr_studio.dart';
import 'package:buildr_studio/screens/home_screen/settings/settings_api_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SettingsAiService extends StatelessWidget {
  const SettingsAiService({super.key});

  @override
  Widget build(BuildContext context) {
    final chooseAIServiceState = context.watch<ChooseAIServiceState>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'AI Service: ',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: DropdownButtonFormField<AIService>(
                value: chooseAIServiceState.selectedService,
                onChanged: (AIService? newService) {
                  if (newService != null) {
                    chooseAIServiceState.setSelectedService(newService);
                  }
                },
                items: AIService.values.map((service) {
                  return DropdownMenuItem<AIService>(
                    value: service,
                    child: Text(service.displayName),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        const SizedBox(height: 24),
        switch (chooseAIServiceState.selectedService) {
          AIService.anthropic => const Column(
              children: [
                SettingsApiKey(
                  title: "Claude AI",
                  helpUrl:
                      "https://www.buildr.studio/blog/cach-lay-api-key-claude-anthropic",
                ),
                SizedBox(height: 24),
              ],
            ),
          AIService.google => const Column(
              children: [
                SettingsApiKey(
                  title: "Gemini AI",
                  helpUrl: "https://ai.google.dev/gemini-api/docs/api-key",
                ),
                SizedBox(height: 24),
              ],
            ),
          AIService.buildrStudio => const SettingsAiServiceBuildrStudio(),
        },
      ],
    );
  }
}
