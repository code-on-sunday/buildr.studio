class Tool {
  final String id;
  final String name;
  final String description;

  Tool({
    required this.id,
    required this.name,
    required this.description,
  });

  factory Tool.fromJson(Map<String, dynamic> json) {
    return Tool(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
    );
  }
}
