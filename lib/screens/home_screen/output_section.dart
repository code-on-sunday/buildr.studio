import 'package:flutter/material.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:volta/screens/home_screen_state.dart';

class OutputSection extends StatelessWidget {
  const OutputSection({super.key});

  @override
  Widget build(BuildContext context) {
    final outputText = context.watch<HomeScreenState>().outputText;
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
                  data: outputText ?? 'No output available.',
                  padding: const EdgeInsets.all(8),
                  config: MarkdownConfig(configs: [
                    const PreConfig(
                        theme: a11yLightTheme,
                        textStyle: TextStyle(fontSize: 14)),
                  ])),
            ),
          ),
        ],
      ),
    );
  }
}
