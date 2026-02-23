import 'package:flutter/material.dart';
import 'package:flutter_todo_app/model/task.dart';
import 'package:flutter_todo_app/provider/task_provider.dart';
import 'package:flutter_todo_app/task_dialog.dart';
import 'package:provider/provider.dart';

void _showTaskDialog(BuildContext context, [Task? task]) {
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    builder: (context) {
      return Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom,
        ),
        child: TaskDialog(task: task),
      );
    },
  );
}

class TaskList extends StatefulWidget {
  const TaskList({super.key});

  @override
  State<TaskList> createState() => _TaskListState();
}

class _TaskListState extends State<TaskList> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text("Mes tâches"),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showTaskDialog(context);
        },
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        child: const Icon(Icons.add),
      ),
      body: Consumer<TaskProvider>(
        builder: (context, value, child) {
          return CustomScrollView(
            slivers: [
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.only(
                    top: 16,
                    right: 16,
                    bottom: 16,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Checkbox(
                        value: value.allCompleted,
                        tristate: true,
                        onChanged: (completed) {
                          value.toggleAllCompleted(completed ?? false);
                        },
                      ),
                      ToggleButtons(
                        direction: Axis.horizontal,
                        onPressed: (int index) {
                          var newState = switch (index) {
                            0 => DisplayState.all,
                            1 => DisplayState.active,
                            _ => DisplayState.completed
                          };
                          final provider =
                              Provider.of<TaskProvider>(context, listen: false);
                          provider.updateDisplayState(newState);
                        },
                        borderRadius:
                            const BorderRadius.all(Radius.circular(8)),
                        selectedColor: Colors.white,
                        fillColor: Colors.black,
                        textStyle: const TextStyle(fontSize: 12),
                        constraints: const BoxConstraints(
                          minHeight: 40.0,
                          minWidth: 90,
                        ),
                        isSelected: [
                          value.displayState == DisplayState.all,
                          value.displayState == DisplayState.active,
                          value.displayState == DisplayState.completed,
                        ],
                        children: [
                          Text("Tout (${value.allCount})"),
                          Text("En cours (${value.activeCount})"),
                          Text("Terminé (${value.completedCount})"),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              SliverList.separated(
                itemCount: value.tasks.length,
                itemBuilder: (context, index) {
                  final task = value.tasks[index];

                  return Dismissible(
                    key: ValueKey(task.id),
                    onDismissed: (direction) {
                      value.deleteTask(task);
                    },
                    background: Container(
                      color: Colors.red,
                      alignment: Alignment.center,
                      child: const Text(
                        "Supprimer",
                        style: TextStyle(color: Colors.white),
                      ),
                    ),
                    child: TaskItem(task: task),
                  );
                },
                separatorBuilder: (context, index) {
                  return Divider(
                    height: 1,
                    color: Colors.grey[100],
                  );
                },
              ),
            ],
          );
        },
      ),
    );
  }
}

class TaskItem extends StatelessWidget {
  final Task task;

  const TaskItem({super.key, required this.task});

  Widget _renderCheckBox() {
    if (!task.completed) {
      return Container(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.grey[600]!,
            width: 2,
          ),
        ),
        width: 20,
        height: 20,
        margin: const EdgeInsets.only(top: 6),
      );
    }

    return Container(
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: Colors.green,
      ),
      width: 20,
      height: 20,
      margin: const EdgeInsets.only(top: 6),
      alignment: Alignment.center,
      child: const Icon(
        Icons.check,
        size: 14,
        color: Colors.white,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;

    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            onTap: () {
              final provider =
                  Provider.of<TaskProvider>(context, listen: false);
              provider.toggleComplete(task);
            },
            child: _renderCheckBox(),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task.title,
                  style: textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                  ),
                ),
                Text(
                  task.description,
                  style: textTheme.bodyMedium?.copyWith(
                    color: Colors.grey[600],
                    decoration:
                        task.completed ? TextDecoration.lineThrough : null,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              _showTaskDialog(context, task);
            },
            icon: const Icon(Icons.edit),
          ),
        ],
      ),
    );
  }
}
