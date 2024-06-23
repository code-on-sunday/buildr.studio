import 'package:buildr_studio/repositories/user_preferences_repository.dart';
import 'package:buildr_studio/screens/home_screen/settings/token_usage_state.dart';
import 'package:buildr_studio/screens/home_screen_state.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PrimaryAlert extends StatefulWidget {
  const PrimaryAlert({
    super.key,
  });

  @override
  State<PrimaryAlert> createState() => _PrimaryAlertState();
}

class _PrimaryAlertState extends State<PrimaryAlert> {
  final _userPreferencesRepository = GetIt.I.get<UserPreferencesRepository>();
  bool _primaryAlertHidden = false;

  @override
  void initState() {
    super.initState();
    _checkHidePrimaryAlert();
  }

  Future<void> _checkHidePrimaryAlert() async {
    setState(() {
      _primaryAlertHidden = _userPreferencesRepository.getHidePrimaryAlert();
    });
  }

  @override
  Widget build(BuildContext context) {
    final homeState = context.read<HomeScreenState>();
    final theme = ShadTheme.of(context);

    if (_primaryAlertHidden) return const SizedBox.shrink();

    return ShadAlert(
      decoration: ShadDecoration(
        border: ShadBorder(
          width: 1,
          color: theme.colorScheme.border,
          padding: const EdgeInsets.all(16),
          radius: theme.radius,
        ),
        shadows: ShadShadows.md,
        color: theme.colorScheme.primary,
      ),
      icon: ShadButton.outline(
        size: ShadButtonSize.icon,
        width: 24,
        height: 24,
        foregroundColor: theme.colorScheme.primaryForeground,
        hoverForegroundColor: theme.colorScheme.primary,
        icon: Icon(
          Icons.close,
          size: 16,
          color: theme.colorScheme.primaryForeground,
        ),
        onPressed: () {
          _hide();
        },
      ),
      iconPadding: const EdgeInsets.only(right: 12),
      titleStyle: theme.textTheme.large.copyWith(
        color: theme.colorScheme.primaryForeground,
      ),
      descriptionStyle: theme.textTheme.p.copyWith(
        color: theme.colorScheme.primaryForeground,
      ),
      title: const Padding(
        padding: EdgeInsets.only(top: 2, bottom: 4),
        child: Text('You are using buildr.studio AI service'),
      ),
      description: Row(
        children: [
          const Text('Claim your free credits or select a different service.'),
          const SizedBox(width: 8),
          ShadButton(
            backgroundColor: theme.colorScheme.primaryForeground,
            foregroundColor: theme.colorScheme.primary,
            hoverBackgroundColor:
                theme.colorScheme.primaryForeground.withOpacity(0.9),
            hoverForegroundColor: theme.colorScheme.primary,
            onPressed: () {
              _hide();
              homeState.onNavRailItemTapped(1);
              context.read<TokenUsageState>().loadTokenUsage();
            },
            text: const Text('Click here'),
          ),
        ],
      ),
    );
  }

  Future<void> _hide() async {
    await _userPreferencesRepository.setHidePrimaryAlert(true);
    setState(() {
      _primaryAlertHidden = true;
    });
  }
}
