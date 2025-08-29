import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/task.dart';
import 'add_task_screen.dart';

class TaskDetailScreen extends StatelessWidget {
  final Task task;

  const TaskDetailScreen({
    Key? key,
    required this.task,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Task Details'),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddTaskScreen(task: task),
                ),
              );
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title Section
            Text(
              task.title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            
            // Status Section
            _buildStatusSection(context),
            const SizedBox(height: 24),
            
            // Details Section
            _buildDetailsSection(context),
            const SizedBox(height: 24),
            
            // Description Section
            _buildDescriptionSection(context),
            const SizedBox(height: 24),
            
            // Timestamps Section
            _buildTimestampsSection(context),
          ],
        ),
      ),
    );
  }

  Widget _buildStatusSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            Container(
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                color: task.isCompleted ? Colors.green : Colors.orange,
                shape: BoxShape.circle,
              ),
              child: Icon(
                task.isCompleted ? Icons.check : Icons.hourglass_empty,
                color: Colors.white,
                size: 16,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Status',
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    task.isCompleted ? 'Completed' : 'Pending',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (task.isCompleted && task.completedAt != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Completed on ${DateFormat('MMM dd, yyyy').format(task.completedAt!)}',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailsSection(BuildContext context) {
    Color priorityColor;
    String priorityText;

    switch (task.priority) {
      case Priority.low:
        priorityColor = Colors.green;
        priorityText = 'Low';
        break;
      case Priority.medium:
        priorityColor = Colors.blue;
        priorityText = 'Medium';
        break;
      case Priority.high:
        priorityColor = Colors.orange;
        priorityText = 'High';
        break;
      case Priority.urgent:
        priorityColor = Colors.red;
        priorityText = 'Urgent';
        break;
    }

    return Card(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(Icons.calendar_today),
            title: const Text('Due Date'),
            subtitle: Text(
              task.dueDate != null
                  ? DateFormat('MMM dd, yyyy').format(task.dueDate!)
                  : 'No due date',
            ),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.flag, color: priorityColor),
            title: const Text('Priority'),
            subtitle: Text(priorityText),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(Icons.category, color: Colors.blue),
            title: const Text('Category'),
            subtitle: Text(task.category),
          ),
        ],
      ),
    );
  }

  Widget _buildDescriptionSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Description',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              task.description.isEmpty ? 'No description' : task.description,
              style: TextStyle(
                fontSize: 16,
                color: task.description.isEmpty ? Colors.grey[500] : null,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampsSection(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Task History',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            _buildTimestampRow(
              context,
              'Created',
              task.createdAt,
              Icons.add_circle_outline,
              Colors.green,
            ),
            const SizedBox(height: 8),
            _buildTimestampRow(
              context,
              'Last Updated',
              task.updatedAt,
              Icons.update,
              Colors.blue,
            ),
            if (task.isCompleted && task.completedAt != null) ...[
              const SizedBox(height: 8),
              _buildTimestampRow(
                context,
                'Completed',
                task.completedAt!,
                Icons.check_circle_outline,
                Colors.green,
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildTimestampRow(
    BuildContext context,
    String label,
    DateTime timestamp,
    IconData icon,
    Color color,
  ) {
    return Row(
      children: [
        Icon(icon, size: 16, color: color),
        const SizedBox(width: 8),
        Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        const Spacer(),
        Text(
          DateFormat('MMM dd, yyyy - h:mm a').format(timestamp),
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}