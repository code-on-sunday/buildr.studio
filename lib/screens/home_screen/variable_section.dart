import 'package:flutter/material.dart';
import 'package:volta/models/tool.dart';
import 'package:volta/models/variable.dart';
import 'package:volta/screens/home_screen/variable_input.dart';
import 'package:volta/screens/home_screen/variable_section_state.dart';

class VariableSection extends StatelessWidget {
  final Tool selectedTool;
  final List<Variable> variables;
  final VariableSectionState variableSectionState;

  const VariableSection({
    super.key,
    required this.selectedTool,
    required this.variables,
    required this.variableSectionState,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: MediaQuery.of(context).size.width * 0.6,
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 5,
            blurRadius: 7,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'Variables',
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
                      child: VariableInput(
                        variable: variable,
                        selectedPaths:
                            variableSectionState.selectedPaths[variable.name] ??
                                [],
                        onPathsSelected: variableSectionState.onPathsSelected,
                        onValueChanged: variableSectionState.setInputValue,
                      ),
                    ))
                .toList(),
          ),
          const Spacer(),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    variableSectionState.clearValues();
                  },
                  child: Container(
                      height: 40,
                      alignment: Alignment.center,
                      child: const Text('Clear values')),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: SizedBox(
                  height: 56,
                  child: variableSectionState.isRunning
                      ? const FilledButton(
                          onPressed: null,
                          child: SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(),
                          ),
                        )
                      : FilledButton.icon(
                          onPressed: variableSectionState.isRunning
                              ? null
                              : () {
                                  try {
                                    variableSectionState.submit(context);
                                  } catch (e) {
                                    // Log the error or display it to the UI
                                    print('Error: $e');
                                  }
                                },
                          label: const Text('Run'),
                          icon: const Icon(Icons.play_arrow),
                        ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
