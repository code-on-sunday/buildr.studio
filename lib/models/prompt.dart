import 'package:volta/models/variable.dart';

class Prompt {
  final String text;
  final List<Variable> variables;

  Prompt({
    required this.text,
    required this.variables,
  });

  factory Prompt.fromJson(Map<String, dynamic> json) {
    final variables = (json['variables'] as List<dynamic>)
        .map((data) => Variable.fromJson(data))
        .toList();
    return Prompt(
      text: json['prompt'] as String,
      variables: variables,
    );
  }
}
