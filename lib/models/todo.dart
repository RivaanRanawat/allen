const String tableTodo = 'todo';

class TodoFields {
  static final List<String> values = [
    id, title, date
  ];

  static const String id = '_id';
  static const String date = 'date';
  static const String title = 'title';
}

class Todo {
  final int? id;
  final String date;
  final String title;

  const Todo({
    this.id,
    required this.date,
    required this.title,
  });

  Todo copy({
    int? id,
    bool? isCompleted,
    String? title,
    String? date,
  }) =>
      Todo(
        id: id ?? this.id,
        title: title ?? this.title,
        date: date ?? this.date,
      );

  static Todo fromJson(Map<String, Object?> json) => Todo(
        id: json[TodoFields.id] as int?,
        title: json[TodoFields.title] as String,
        date: json[TodoFields.date] as String,
      );

  Map<String, Object?> toJson() => {
        TodoFields.id: id,
        TodoFields.title: title,
        TodoFields.date: date,
      };
}
