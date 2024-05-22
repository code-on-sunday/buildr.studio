class Variable {
  final String name;
  final String description;
  final String valueFormat;
  final String inputType;
  final String? sourceName;
  final String hintLabel;
  final String? selectLabel;

  Variable({
    required this.name,
    required this.description,
    required this.valueFormat,
    required this.inputType,
    this.sourceName,
    required this.hintLabel,
    this.selectLabel,
  });

  factory Variable.fromJson(Map<String, dynamic> json) {
    return Variable(
      name: json['name'] as String,
      description: json['description'] as String,
      valueFormat: json['value_format'] as String,
      inputType: json['input_type'] as String,
      sourceName: json['source_name'] as String?,
      hintLabel: json['hint_label'] as String,
      selectLabel: json['select_label'] as String?,
    );
  }
}
