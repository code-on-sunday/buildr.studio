import 'package:flutter/material.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';

class VariableSection extends StatelessWidget {
  final Tool selectedTool;
  final List<Variable> variables;

  const VariableSection({
    super.key,
    required this.selectedTool,
    required this.variables,
  });

  @override
  Widget build(BuildContext context) {
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
            children: variables
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
                              maxLines: 10,
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
