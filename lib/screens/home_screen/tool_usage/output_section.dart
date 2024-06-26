import 'package:buildr_studio/screens/home_screen/tool_usage/output_section_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_highlight/themes/a11y-light.dart';
import 'package:markdown_widget/markdown_widget.dart';
import 'package:provider/provider.dart';
import 'package:re_highlight/styles/github-dark.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class OutputSection extends StatelessWidget {
  const OutputSection({super.key});

  @override
  Widget build(BuildContext context) {
    final outputText = context.watch<ToolUsageManager>().output;
    final theme = ShadTheme.of(context);
    final outputSectionState = context.watch<OutputSectionState>();

    return Container(
      margin: const EdgeInsets.all(4).copyWith(bottom: 0),
      color: ShadTheme.of(context).colorScheme.muted,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Text(
                'Output',
                style: ShadTheme.of(context).textTheme.h4,
              ),
              const Spacer(),
              const Text('Show raw text'),
              const SizedBox(width: 4),
              Checkbox.adaptive(
                value: outputSectionState.showRawText,
                onChanged: (value) {
                  outputSectionState.setShowRawText(value ?? false);
                },
              ),
              const SizedBox(width: 4),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                borderRadius: ShadTheme.of(context).radius,
                border: Border.all(
                  width: 1,
                  color: ShadTheme.of(context).colorScheme.border,
                ),
                color: ShadTheme.of(context).colorScheme.background,
              ),
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: outputSectionState.showRawText
                  ? SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: SelectableText(outputText,
                          style: theme.textTheme.p.copyWith(
                            height: 1.4,
                            fontSize: 14,
                          )),
                    )
                  : MarkdownWidget(
                      data: outputText,
                      padding: const EdgeInsets.all(16),
                      config: MarkdownConfig(configs: [
                        CodeConfig(
                          style: theme.textTheme.p.copyWith(
                            color: theme.colorScheme.secondaryForeground,
                            fontStyle: FontStyle.italic,
                            backgroundColor: theme.colorScheme.secondary,
                          ),
                        ),
                        PreConfig(
                            decoration: BoxDecoration(
                              borderRadius: theme.radius,
                              border: Border.all(
                                width: 1,
                                color: theme.colorScheme.ring,
                              ),
                              color: theme.brightness == Brightness.dark
                                  ? theme.colorScheme.secondary
                                  : null,
                            ),
                            theme: theme.brightness == Brightness.dark
                                ? githubDarkTheme
                                : a11yLightTheme,
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
