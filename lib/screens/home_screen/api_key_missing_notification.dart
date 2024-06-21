import 'package:buildr_studio/screens/home_screen/settings/api_key_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/choose_ai_service_state.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
      padding: const EdgeInsets.symmetric(horizontal: 24),
      color: ShadTheme.of(context).colorScheme.destructive,
      child: Row(
        children: [
          Text(
            'You need to set up ${chooseAiServiceState.selectedService.displayName} API key.',
            style: ShadTheme.of(context).textTheme.p.copyWith(
                color: ShadTheme.of(context).colorScheme.destructiveForeground),
          ),
          const SizedBox(width: 8),
          ShadButton(
              onPressed: () {
                homeState.onNavRailItemTapped(1);
              },
              text: const Text('Set up')),
        ],
      ),
    );
  }
}
