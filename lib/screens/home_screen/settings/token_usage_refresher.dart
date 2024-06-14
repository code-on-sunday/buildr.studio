import 'dart:async';

import 'package:buildr_studio/models/prompt_service_connection_status.dart';
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

  final List<StreamSubscription> _subscriptions = [];

  @override
  void initState() {
    super.initState();
    _subscriptions.addAll([
      _toolUsageManager.endStream.listen(_refreshTokenUsage),
      _toolUsageManager.connectionStatusStream.listen((event) {
        if (event is Connected) {
          _refreshTokenUsage(null);
        }
      })
    ]);
  }

  @override
  void dispose() {
    for (var subscription in _subscriptions) {
      subscription.cancel();
    }
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
