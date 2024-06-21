import 'dart:io';

import 'package:buildr_studio/models/variable.dart';
import 'package:buildr_studio/screens/home_screen/file_explorer_state.dart';
import 'package:buildr_studio/screens/home_screen/tool_usage/tool_usage_manager.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shadcn_ui/shadcn_ui.dart';

class VariableInput extends StatefulWidget {
  final Variable variable;
  final List<String> selectedPaths;
  final void Function(String, List<String>) onPathsSelected;
  final void Function(String, String) onValueChanged;

  const VariableInput({
    super.key,
    required this.variable,
    required this.selectedPaths,
    required this.onPathsSelected,
    required this.onValueChanged,
  });

  @override
  State<VariableInput> createState() => _VariableInputState();
}

class _VariableInputState extends State<VariableInput> {
  late final TextEditingController _textController;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();
    context.read<ToolUsageManager>().clearValuesStream.listen((_) {
      _textController.clear();
    });
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ShadTooltip(
          builder: (_) => Text(widget.variable.description),
          child: Text(
            '{{${widget.variable.name}}}',
            style: ShadTheme.of(context).textTheme.small,
          ),
        ),
        const SizedBox(height: 8),
        if (widget.variable.inputType == 'text_field')
          ShadInput(
            controller: _textController,
            minLines: 4,
            maxLines: 10,
            onChanged: (value) {
              widget.onValueChanged(widget.variable.name, value);
            },
          )
        else if (widget.variable.inputType == 'dropdown')
          DropdownButtonFormField<String>(
            hint: Text(widget.variable.selectLabel!),
            items: [
              ...?widget.variable.sourceName
                  ?.split(',')
                  .map((option) => DropdownMenuItem(
                        value: option.trim(),
                        child: Text(option.trim()),
                      )),
            ],
            onChanged: (value) {
              if (value != null) {
                widget.onValueChanged(widget.variable.name, value);
              }
            },
          )
        else if (widget.variable.inputType == 'sources')
          SourcesInput(
            selectedPaths: widget.selectedPaths,
            onPathsSelected: (paths) {
              widget.onPathsSelected(widget.variable.name, paths);
            },
          ),
      ],
    );
  }
}

class SourcesInput extends StatelessWidget {
  final List<String> selectedPaths;
  final void Function(List<String>) onPathsSelected;

  const SourcesInput({
    super.key,
    required this.selectedPaths,
    required this.onPathsSelected,
  });

  @override
  Widget build(BuildContext context) {
    final fileExplorerState = context.watch<FileExplorerState>();
    final theme = ShadTheme.of(context);

    return DragTarget<bool>(
      onAcceptWithDetails: (_) {
        onPathsSelected(fileExplorerState.selectedPaths);
      },
      builder: (context, candidateData, rejectedData) {
        final isHighlighted = candidateData.isNotEmpty;
        return Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: isHighlighted || selectedPaths.isNotEmpty
                ? theme.colorScheme.secondary
                : null,
            borderRadius: ShadTheme.of(context).radius,
            border: Border.all(
              width: 2,
              color: theme.colorScheme.border,
            ),
          ),
          child: selectedPaths.isNotEmpty
              ? Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  children: selectedPaths.map((path) {
                    try {
                      final isFolder = FileSystemEntity.isDirectorySync(path);
                      return switch (isFolder) {
                        true => ShadBadge(
                            text: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (isFolder)
                                  Icon(
                                    Icons.folder,
                                    size: 18,
                                    color: theme.colorScheme.primaryForeground,
                                  ),
                                const SizedBox(width: 4),
                                Text(
                                  fileExplorerState.getDisplayName(path),
                                  style: theme.textTheme.small.copyWith(
                                      color:
                                          theme.colorScheme.primaryForeground),
                                ),
                              ],
                            ),
                          ),
                        false => ShadBadge.outline(
                            backgroundColor: theme.colorScheme.selection,
                            hoverBackgroundColor: theme.colorScheme.selection,
                            text: Text(fileExplorerState.getDisplayName(path))),
                      };
                    } catch (e) {
                      return const SizedBox.shrink();
                    }
                  }).toList(),
                )
              : Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.upload_file, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      'Drag and drop your sources here',
                      style: theme.textTheme.p,
                    )
                  ],
                ),
        );
      },
    );
  }
}
