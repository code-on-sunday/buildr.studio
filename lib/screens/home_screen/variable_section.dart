import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';
import 'package:volta/screens/home_screen/file_explorer_state.dart';

class VariableSection extends StatefulWidget {
  final Tool selectedTool;
  final List<Variable> variables;

  const VariableSection({
    super.key,
    required this.selectedTool,
    required this.variables,
  });

  @override
  State<VariableSection> createState() => _VariableSectionState();
}

class _VariableSectionState extends State<VariableSection> {
  List<String> _selectedPaths = [];

  @override
  Widget build(BuildContext context) {
    final fileExplorerState = Provider.of<FileExplorerState>(context);

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Input',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: widget.variables
                .map((variable) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                '<${variable.name.toUpperCase()}>',
                                style: Theme.of(context)
                                    .textTheme
                                    .labelLarge!
                                    .copyWith(fontWeight: FontWeight.bold),
                              ),
                              Tooltip(
                                message: variable.description,
                                child: const Icon(Icons.info_outline),
                              )
                            ],
                          ),
                          const SizedBox(height: 8),
                          if (variable.inputType == 'text_field')
                            TextField(
                              decoration: InputDecoration(
                                hintText: variable.hintLabel,
                                border: const OutlineInputBorder(),
                              ),
                              maxLines: 3,
                            )
                          else if (variable.inputType == 'dropdown')
                            DropdownButtonFormField<String>(
                              hint: Text(variable.selectLabel!),
                              items: [
                                ...?variable.sourceName
                                    ?.split(',')
                                    .map((option) => DropdownMenuItem(
                                          value: option.trim(),
                                          child: Text(option.trim()),
                                        )),
                              ],
                              onChanged: (value) {},
                            )
                          else if (variable.inputType == 'sources')
                            DragTarget<List<String>>(
                              onAcceptWithDetails: (details) {
                                setState(() {
                                  _selectedPaths = details.data;
                                });
                              },
                              builder: (context, candidateData, rejectedData) {
                                final isHighlighted = candidateData.isNotEmpty;
                                return Container(
                                  padding: const EdgeInsets.all(16.0),
                                  decoration: BoxDecoration(
                                    color: isHighlighted ||
                                            _selectedPaths.isNotEmpty
                                        ? Colors.orange.shade50
                                        : null,
                                    border: Border.all(
                                      color: isHighlighted
                                          ? Colors.orange
                                          : Colors.grey.shade400,
                                      width: isHighlighted ? 4.0 : 2.0,
                                    ),
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  child: _selectedPaths.isNotEmpty
                                      ? Wrap(
                                          spacing: 4,
                                          runSpacing: 4,
                                          children: _selectedPaths
                                              .map((path) => Chip(
                                                    label: Text(
                                                      fileExplorerState
                                                          .getDisplayFileName(
                                                              path),
                                                    ),
                                                  ))
                                              .toList(),
                                        )
                                      : Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            const Icon(Icons.upload_file,
                                                size: 48, color: Colors.grey),
                                            const SizedBox(height: 16),
                                            Text(
                                              'Drag and drop your sources here',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodyLarge
                                                  ?.copyWith(
                                                      color: Colors.grey),
                                            )
                                          ],
                                        ),
                                );
                              },
                            ),
                        ],
                      ),
                    ))
                .toList(),
          ),
        ],
      ),
    );
  }
}
