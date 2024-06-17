import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OutputSection extends StatelessWidget {
  const OutputSection({super.key});

  @override
  Widget build(BuildContext context) {
    final outputText = context.watch<ToolUsageManager>().output;
    return Container(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Output',
            style: ShadTheme.of(context).textTheme.h4,
          ),
          const SizedBox(height: 16),
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: ShadTheme.of(context).radius,
                border: Border.all(
                  width: 1,
                  color: ShadTheme.of(context).colorScheme.border,
                ),
              ),
              child: MarkdownWidget(
                  data: outputText,
                  padding: const EdgeInsets.all(16),
                  config: MarkdownConfig(configs: [
                    PreConfig(
                        theme: a11yLightTheme,
                        textStyle: const TextStyle(fontSize: 14),
                        wrapper: buildCodeWrapper(context)),
                  ])),
            ),
          ),
        ],
      ),
    );
  }

  CodeWrapper buildCodeWrapper(BuildContext context) {
    return ((child, code, language) => Stack(
          children: [
            child,
            Positioned(
              top: 16,
              right: 8.0,
              child: ShadButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ShadToaster.of(context).show(
                    const ShadToast(
                      description: Text('Code copied to clipboard'),
                    ),
                  );
                },
                text: const Text('Copy'),
              ),
            ),
          ],
        ));
  }
}
