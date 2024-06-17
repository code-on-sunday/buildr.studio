import 'package:buildr_studio/screens/home_screen/settings/token_usage_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

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
    tokenUsageState.loadTokenUsage();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final tokenUsageState = context.watch<TokenUsageState>();
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          flex: 2,
          child: ShadCard(
            padding: const EdgeInsets.all(24),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '\$${tokenUsageState.tokenUsage?.balance.toStringAsFixed(4) ?? '0'}',
                  style: Theme.of(context)
                      .textTheme
                      .displayLarge!
                      .copyWith(fontSize: 40),
                ),
                Text(
                  'Remaining balance',
                  style: Theme.of(context).textTheme.labelSmall,
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: ShadButton(
            onPressed: () {},
            text: const Text('Add Funds'),
          ),
        ),
      ],
    );
  }
}
