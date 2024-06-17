import 'dart:async';

import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class PromptErrorNotification extends StatefulWidget {
  const PromptErrorNotification({super.key, required this.child});

  final Widget child;

  @override
  State<PromptErrorNotification> createState() =>
      _PromptErrorNotificationState();
}

class _PromptErrorNotificationState extends State<PromptErrorNotification> {
  late final _toolUsageManager = context.read<ToolUsageManager>();
  late final StreamSubscription<String> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _toolUsageManager.errorStream.listen(_showError);
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return widget.child;
  }

  void _showError(String error) {
    ShadToaster.of(context).show(
      ShadToast.destructive(
        description: Text(error),
      ),
    );
  }
}
