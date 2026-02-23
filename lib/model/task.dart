class Task {
  final int id;
  String title;
  String description;
  bool completed;


  Task({
    required this.id,
    required this.title,
    required this.description,
    this.completed = false,
  });
}
