import 'package:buildr_studio/screens/home_screen/settings/settings_ai_service.dart';
import 'package:buildr_studio/screens/home_screen/settings/settings_theme_mode.dart';
import 'package:flutter/material.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class SettingsTab extends StatelessWidget {
  const SettingsTab({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Settings',
            style: ShadTheme.of(context).textTheme.h4,
          ),
          const SizedBox(height: 16),
          const ShadCard(content: SettingsAiService()),
          const SizedBox(height: 16),
          const ShadCard(content: SettingsThemeMode()),
        ],
      ),
    );
  }
}
