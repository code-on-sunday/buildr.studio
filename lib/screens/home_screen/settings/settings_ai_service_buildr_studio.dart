import 'package:buildr_studio/screens/home_screen/settings/token_usage_state.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

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
    return Container(
      width: double.infinity,
      alignment: Alignment.centerRight,
      child: Card.filled(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
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
    );
  }
}
