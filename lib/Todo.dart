class Todo {
  final String id;
  final String title;
  final String description;

  Todo({
    required this.id,
    required this.title,
    required this.description,
  });

  factory Todo.fromJson(Map<String, dynamic> json) {
    return Todo(
      id: json['_id'],
      title: json['title'],
      description: json['description'],
    );
  }
}