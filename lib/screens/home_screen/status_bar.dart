import 'dart:async';

import 'package:buildr_studio/models/prompt_service_connection_status.dart';
import 'package:buildr_studio/screens/home_screen/device_registration_state.dart';
import 'package:buildr_studio/screens/home_screen/export_logs_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class StatusBar extends StatefulWidget {
  const StatusBar({super.key});

  @override
  State<StatusBar> createState() => _StatusBarState();
}

class _StatusBarState extends State<StatusBar> {
  StreamSubscription? _connectionStatusSubscription;

  @override
  void initState() {
    super.initState();
    _connectionStatusSubscription =
        context.read<ToolUsageManager>().connectionStatusStream.listen((event) {
      context.read<DeviceRegistrationState>().registerDevice();
    });
  }

  @override
  void dispose() {
    _connectionStatusSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    late final toolUsageManager = context.watch<ToolUsageManager>();
    late final deviceRegistrationState =
        context.watch<DeviceRegistrationState>();
    late final exportLogsState = context.watch<ExportLogsState>();

    return ShadDecorator(
      decoration: ShadDecoration(
          border: ShadBorder(
        width: 1,
        color: ShadTheme.of(context).colorScheme.border,
        radius: ShadTheme.of(context).radius,
      )),
      child: SizedBox(
        height: 32,
        child: Row(
          children: [
            const SizedBox(width: 16),
            switch (toolUsageManager.connectionStatus) {
              Error(:final message) => ShadTooltip(
                  builder: (_) => Text(message),
                  child: const Icon(Icons.error, color: Colors.red)),
              Connected() => ShadTooltip(
                  builder: (_) => const Text("Connected to server"),
                  child: const Icon(Icons.check, color: Colors.green)),
              Connecting() => ShadTooltip(
                  builder: (_) => const Text("Connecting to server"),
                  child: const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      color: Colors.yellow,
                    ),
                  ),
                ),
              Disconnected() => const Icon(Icons.link_off, color: Colors.red),
            },
            const SizedBox(width: 8),
            if (exportLogsState.isRunning)
              ShadTooltip(
                builder: (_) => const Text('Exporting logs'),
                child: const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(
                    color: Colors.yellow,
                  ),
                ),
              ),
            if (exportLogsState.isRunning) const Text('Exporting...'),
            const Spacer(),
            if (deviceRegistrationState.errorMessage != null)
              ShadTooltip(
                builder: (_) => const Text('Cannot register device'),
                child: const Icon(Icons.error, color: Colors.red),
              ),
            if (deviceRegistrationState.accountId != null)
              ShadTooltip(
                builder: (_) =>
                    const Text('Click to copy account ID to clipboard'),
                child: InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(
                        text: deviceRegistrationState.accountId!));
                    ShadToaster.of(context).show(
                      const ShadToast(
                        description: Text('Account ID copied to clipboard'),
                      ),
                    );
                  },
                  child: Text(
                      "Account ID: ${deviceRegistrationState.accountId!.split("-").first}",
                      style: TextStyle(color: Colors.grey[600])),
                ),
              ),
            const SizedBox(width: 24),
          ],
        ),
      ),
    );
  }
}
