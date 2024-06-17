import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

import 'choose_theme_mode_state.dart';

class SettingsThemeMode extends StatelessWidget {
  const SettingsThemeMode({super.key});

  @override
  Widget build(BuildContext context) {
    final themeState = context.watch<ChooseThemeModeState>();

    return Row(
      children: [
        Text(
          'Theme mode:',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const Spacer(),
        ShadSelect<ThemeMode>(
          placeholder: const Text('Theme Mode'),
          initialValue: themeState.themeMode,
          options: const [
            ShadOption(value: ThemeMode.system, child: Text('System')),
            ShadOption(value: ThemeMode.dark, child: Text('Dark')),
            ShadOption(value: ThemeMode.light, child: Text('Light')),
          ],
          onChanged: themeState.setThemeMode,
          selectedOptionBuilder: (_, mode) =>
              Text(mode.name.replaceRange(0, 1, mode.name[0].toUpperCase())),
        ),
      ],
    );
  }
}
