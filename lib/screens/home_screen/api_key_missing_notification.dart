import 'package:buildr_studio/screens/home_screen/settings/api_key_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class ApiKeyMissingNotification extends StatelessWidget {
  const ApiKeyMissingNotification({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    final chooseAiServiceState = context.watch<ChooseAIServiceState>();
    final apiKeyState = context.watch<ApiKeyState>();
    final homeState = context.watch<HomeScreenState>();

    if (apiKeyState.apiKey != null) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.all(8.0),
      color: Theme.of(context).colorScheme.error,
      child: Row(
        children: [
          Text(
            'You need to set up ${chooseAiServiceState.selectedService.displayName} API key.',
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 8),
          OutlinedButton(
              onPressed: () {
                homeState.onNavRailItemTapped(2);
              },
              child: const Text('Set up')),
        ],
      ),
    );
  }
}
