import 'dart:async';

import 'package:buildr_studio/screens/home_screen/settings/token_usage_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class TokenUsageRefresher extends StatefulWidget {
  const TokenUsageRefresher({super.key, required this.child});
  final Widget child;

  @override
  State<TokenUsageRefresher> createState() => _TokenUsageRefresherState();
}

class _TokenUsageRefresherState extends State<TokenUsageRefresher> {
  late final _toolUsageManager = context.read<ToolUsageManager>();
  late final _tokenUsageState = context.read<TokenUsageState>();

  late final StreamSubscription<void> _subscription;

  @override
  void initState() {
    super.initState();
    _subscription = _toolUsageManager.endStream.listen(_refreshTokenUsage);
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

  void _refreshTokenUsage(void _) {
    _tokenUsageState.loadTokenUsage();
  }
}
