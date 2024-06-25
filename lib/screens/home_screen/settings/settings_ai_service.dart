import 'package:ambilytics/ambilytics.dart';
import 'package:buildr_studio/analytics_events.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/settings_ai_service_buildr_studio.dart';
import 'package:buildr_studio/screens/home_screen/settings/settings_api_key.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
              'AI Service:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const Spacer(),
            Listener(
              onPointerDown: (_) {
                ambilytics?.sendEvent(
                    AnalyticsEvents.aiServiceDropdownOpened.name, null);
              },
              behavior: HitTestBehavior.translucent,
              child: ShadSelect<AIService>(
                placeholder: const Text('Select AI Service'),
                initialValue: chooseAIServiceState.selectedService,
                selectedOptionBuilder: (context, value) {
                  return Text(value.displayName);
                },
                onChanged: (AIService? newService) {
                  if (newService != null) {
                    ambilytics
                        ?.sendEvent(AnalyticsEvents.aiServiceSelected.name, {
                      'service': newService.displayName,
                    });
                    chooseAIServiceState.setSelectedService(newService);
                  }
                },
                options: AIService.values.map((service) {
                  return ShadOption(
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
          AIService.anthropic => const SettingsApiKey(
              title: "Claude AI",
              helpUrl:
                  "https://www.buildr.studio/blog/cach-lay-api-key-claude-anthropic",
            ),
          AIService.google => const SettingsApiKey(
              title: "Gemini AI",
              helpUrl: "https://ai.google.dev/gemini-api/docs/api-key",
            ),
          AIService.buildrStudio => const SettingsAiServiceBuildrStudio(),
        },
      ],
    );
  }
}
