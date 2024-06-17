import 'package:buildr_studio/env/env.dart';
import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/settings/token_usage_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';
import 'package:url_launcher/url_launcher_string.dart';

class SettingsAiServiceBuildrStudio extends StatefulWidget {
  const SettingsAiServiceBuildrStudio({super.key});

  @override
  State<SettingsAiServiceBuildrStudio> createState() =>
      _SettingsAiServiceBuildrStudioState();
}

class _SettingsAiServiceBuildrStudioState
    extends State<SettingsAiServiceBuildrStudio> {
  late final tokenUsageState = context.read<TokenUsageState>();

  @override
  void initState() {
    Future.delayed(Duration.zero, () {
      tokenUsageState.loadTokenUsage();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final deviceRegistrationState = context.watch<DeviceRegistrationState>();
    final tokenUsageState = context.watch<TokenUsageState>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '\$${tokenUsageState.tokenUsage?.balance.toStringAsFixed(4) ?? '0'}',
                style: ShadTheme.of(context).textTheme.h2,
              ),
              const SizedBox(height: 4),
              Text(
                'Remaining balance',
                style: Theme.of(context).textTheme.labelSmall,
              ),
            ],
          ),
        ),
        const Spacer(),
        ShadButton(
          onPressed: () {
            launchUrlString(
                '${Env.webBaseUrl}/add-funds?account-id=${deviceRegistrationState.accountId}');
          },
          text: const Text('Add Funds'),
        ),
      ],
    );
  }
}
