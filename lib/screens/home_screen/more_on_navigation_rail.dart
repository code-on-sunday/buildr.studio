import 'package:buildr_studio/screens/home_screen/export_logs_state.dart';
import 'package:buildr_studio/utils/logs_decryptor.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class MoreOnNavigationRail extends StatefulWidget {
  const MoreOnNavigationRail({super.key});

  @override
  State<MoreOnNavigationRail> createState() => _MoreOnNavigationRailState();
}

class _MoreOnNavigationRailState extends State<MoreOnNavigationRail> {
  final _popOverController = ShadPopoverController();

  @override
  void dispose() {
    _popOverController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final exportLogsState = context.read<ExportLogsState>();

    return ShadPopover(
      controller: _popOverController,
      child: ShadButton.ghost(
        onPressed: () {
          _popOverController.show();
        },
        size: ShadButtonSize.icon,
        icon: const Icon(Icons.more_horiz),
      ),
      popover: (_) => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (kDebugMode)
            ShadButton.ghost(
              onPressed: () {
                showShadDialog(
                    context: context,
                    builder: (_) {
                      return ShadDialog(
                        title: const Text('Decrypt log'),
                        content: ShadInput(
                          onSubmitted: (value) {
                            LogFileDecryptor().writeDecryptedLogs(value);
                            Navigator.of(context).pop();
                          },
                        ),
                      );
                    });
                _popOverController.hide();
              },
              text: const Text('Decrypt logs'),
            ),
          ShadButton.ghost(
            onPressed: () {
              exportLogsState.exportLogs(context);
              _popOverController.hide();
            },
            text: const Text('Export logs'),
          ),
        ],
      ),
    );
  }
}
