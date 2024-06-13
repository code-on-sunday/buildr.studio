import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';

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
          const Text(
            'Output',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
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
              child: ElevatedButton(
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: code));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Code copied to clipboard'),
                    ),
                  );
                },
                child: const Text('Copy'),
              ),
            ),
          ],
        ));
  }
}
