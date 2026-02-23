import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/task.dart';

enum DisplayState {
  all,
  active,
  completed,
}

class TaskProvider extends ChangeNotifier {
  final List<Task> _tasks = [
    Task(
      id: 1,
      title: "Tache 1",
      description: "Faire la tâche 1",
    ),
    Task(
      id: 2,
      title: "Tache 2",
      description: "Faire la tâche 2",
    ),
  ];

  DisplayState _displayState = DisplayState.all;

  DisplayState get displayState => _displayState;

  List<Task> get tasks {
    return switch (_displayState) {
      DisplayState.completed => _tasks.where((t) => t.completed).toList(),
      DisplayState.active => _tasks.where((t) => !t.completed).toList(),
      _ => _tasks,
    };
  }

  int get allCount => _tasks.length;
  int get activeCount => _tasks.where((t) => !t.completed).length;
  int get completedCount => _tasks.where((t) => t.completed).length;

  bool? get allCompleted {
    bool hasCompletedTasks = _tasks.any((task) => task.completed);
    bool hasUncompletedTasks = _tasks.any((task) => !task.completed);

    if (hasCompletedTasks && hasUncompletedTasks) {
      return null;
    } else if (hasCompletedTasks) {
      return true;
    } else {
      return false;
    }
  }

  void addTask(String title, String description) {
    var task = Task(
      id: DateTime.now().microsecond,
      title: title,
      description: description,
    );
    _tasks.add(task);
    notifyListeners();
  }

  void updateTask(int taskId, String title, String description) {
    var foundTask = _tasks.where((t) => t.id == taskId).first;
    foundTask.title = title;
    foundTask.description = description;
    notifyListeners();
  }

  void toggleComplete(Task task) {
    task.completed = !task.completed;
    notifyListeners();
  }

  void deleteTask(Task task) {
    _tasks.remove(task);
    notifyListeners();
  }

  void toggleAllCompleted(bool completed) {
    for (var t in _tasks) {
      t.completed = completed;
    }
    notifyListeners();
  }

  void updateDisplayState(DisplayState newState) {
    _displayState = newState;
    notifyListeners();
  }
}
