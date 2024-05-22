class Tool {
  final String id;
  final String name;
  final String description;
  final List<String> variables;

  Tool({
    required this.id,
    required this.name,
    required this.description,
    required this.variables,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      variables: List<String>.from(json['variables'] as List<dynamic>),
    );
  }
}
