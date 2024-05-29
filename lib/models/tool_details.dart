import 'package:buildr_studio/models/variable.dart';

class ToolDetails {
  final String prompt;
  final List<Variable> variables;

  ToolDetails({
    required this.prompt,
    required this.variables,
  });

  factory ToolDetails.fromJson(Map<String, dynamic> json) {
    final variables = (json['variables'] as List<dynamic>)
        .map((data) => Variable.fromJson(data))
        .toList();
    return ToolDetails(
      prompt: json['prompt'] as String,
      variables: variables,
    );
  }
}
