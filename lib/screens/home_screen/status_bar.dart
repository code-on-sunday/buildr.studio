import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StatusBar extends StatelessWidget {
  const StatusBar({super.key});

  @override
  Widget build(BuildContext context) {
    final toolUsageManager = context.watch<ToolUsageManager>();

    return Container(
      height: 32,
      color: Theme.of(context).colorScheme.primary,
      child: Row(
        children: [
          const SizedBox(width: 16),
          switch (toolUsageManager.connectionStatus) {
            Error(:final message) => Tooltip(
                message: message,
                child: const Icon(Icons.error, color: Colors.red)),
            Connected() => const Tooltip(
                message: "Connected to server",
                child: Icon(Icons.check, color: Colors.green)),
            Connecting() => const Tooltip(
                message: "Connecting to server",
                child: SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ),
                ),
              ),
            Disconnected() => const Icon(Icons.link_off, color: Colors.red),
          }
        ],
      ),
    );
  }
}
