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
          const SizedBox(height: 16),
          Align(
            alignment: Alignment.centerRight,
            child: ElevatedButton(
              onPressed: variableSectionState.isRunning
                  ? null
                  : () {
                      variableSectionState.submit(context);
                    },
              child: variableSectionState.isRunning
                  ? const SizedBox(
                      width: 24,
                      height: 24,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Text('Run'),
            ),
          ),
        ],
      ),
    );
  }
}
