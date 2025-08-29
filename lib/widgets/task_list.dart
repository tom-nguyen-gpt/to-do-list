import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/task.dart';
import '../providers/task_provider.dart';
import '../providers/auth_provider.dart' show AppAuthProvider;
import '../screens/task_detail_screen.dart';
import 'task_item.dart';

class TaskList extends StatelessWidget {
  final List<Task> tasks;

  const TaskList({
    Key? key,
    required this.tasks,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context);

    if (taskProvider.isLoading) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    if (tasks.isEmpty) {
      return _buildEmptyState(context);
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Re-fetch tasks - this will trigger the stream listener
        final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
        if (authProvider.firebaseUser != null) {
          taskProvider.setUserId(authProvider.firebaseUser!.uid);
        }
      },
      child: ListView.builder(
        itemCount: tasks.length,
        itemBuilder: (context, index) {
          final task = tasks[index];
          return Dismissible(
            key: Key(task.id),
            background: Container(
              color: Colors.green,
              alignment: Alignment.centerLeft,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.check_circle,
                color: Colors.white,
              ),
            ),
            secondaryBackground: Container(
              color: Colors.red,
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: const Icon(
                Icons.delete,
                color: Colors.white,
              ),
            ),
            confirmDismiss: (direction) async {
              if (direction == DismissDirection.endToStart) {
                return await _showDeleteConfirmation(context, task);
              } else {
                taskProvider.toggleTaskCompletion(task);
                return false;
              }
            },
            onDismissed: (direction) {
              if (direction == DismissDirection.endToStart) {
                taskProvider.deleteTask(task.id);
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Task "${task.title}" deleted'),
                    action: SnackBarAction(
                      label: 'Undo',
                      onPressed: () {
                        // Recreate the task with the same ID
                        taskProvider.addTask(task);
                      },
                    ),
                  ),
                );
              }
            },
            child: TaskItem(
              task: task,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TaskDetailScreen(task: task),
                  ),
                );
              },
              onToggle: (value) {
                taskProvider.toggleTaskCompletion(task);
              },
            ),
          );
        },
      ),
    );
  }

  Future<bool> _showDeleteConfirmation(BuildContext context, Task task) async {
    return await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Delete Task'),
          content: Text('Are you sure you want to delete "${task.title}"?'),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(false);
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(true);
              },
              child: const Text(
                'Delete',
                style: TextStyle(color: Colors.red),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);

    String message = 'No tasks found';
    String subMessage = 'Tap the + button to add a new task';

    if (taskProvider.filter == TaskFilter.completed) {
      message = 'No completed tasks';
      subMessage = 'Complete some tasks to see them here';
    } else if (taskProvider.filter == TaskFilter.pending) {
      message = 'No pending tasks';
      subMessage = 'All your tasks are completed!';
    } else if (taskProvider.categoryFilter != null) {
      message = 'No tasks in this category';
      subMessage = 'Add tasks to "${taskProvider.categoryFilter}" to see them here';
    } else if (taskProvider.searchQuery.isNotEmpty) {
      message = 'No matching tasks';
      subMessage = 'Try a different search term';
    }

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.assignment,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            message,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            subMessage,
            style: TextStyle(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }
}