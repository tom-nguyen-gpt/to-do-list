import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart' show AppAuthProvider;
import '../providers/task_provider.dart';
import '../widgets/task_list.dart';
import 'add_task_screen.dart';
import 'login_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // Set up the task provider with the current user ID
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = Provider.of<AppAuthProvider>(context, listen: false);
      final taskProvider = Provider.of<TaskProvider>(context, listen: false);
      
      if (authProvider.firebaseUser != null) {
        taskProvider.setUserId(authProvider.firebaseUser!.uid);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    final taskProvider = Provider.of<TaskProvider>(context, listen: false);
    
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Filter Tasks',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Status',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      FilterChip(
                        label: const Text('All'),
                        selected: taskProvider.filter == TaskFilter.all,
                        onSelected: (selected) {
                          taskProvider.filterTasks(TaskFilter.all);
                          setState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Completed'),
                        selected: taskProvider.filter == TaskFilter.completed,
                        onSelected: (selected) {
                          taskProvider.filterTasks(TaskFilter.completed);
                          setState(() {});
                        },
                      ),
                      FilterChip(
                        label: const Text('Pending'),
                        selected: taskProvider.filter == TaskFilter.pending,
                        onSelected: (selected) {
                          taskProvider.filterTasks(TaskFilter.pending);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Categories',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  SizedBox(
                    height: 50,
                    child: ListView(
                      scrollDirection: Axis.horizontal,
                      children: [
                        FilterChip(
                          label: const Text('All Categories'),
                          selected: taskProvider.categoryFilter == null,
                          onSelected: (selected) {
                            taskProvider.filterByCategory(null);
                            setState(() {});
                          },
                        ),
                        const SizedBox(width: 8),
                        ...taskProvider.categories.map(
                          (category) => Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: FilterChip(
                              label: Text(category),
                              selected:
                                  taskProvider.categoryFilter == category,
                              onSelected: (selected) {
                                taskProvider.filterByCategory(
                                    selected ? category : null);
                                setState(() {});
                              },
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Sort By',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    children: [
                      ChoiceChip(
                        label: const Text('Due Date'),
                        selected: taskProvider.sort == TaskSort.dueDate,
                        onSelected: (selected) {
                          taskProvider.sortTasks(TaskSort.dueDate);
                          setState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Priority'),
                        selected: taskProvider.sort == TaskSort.priority,
                        onSelected: (selected) {
                          taskProvider.sortTasks(TaskSort.priority);
                          setState(() {});
                        },
                      ),
                      ChoiceChip(
                        label: const Text('Creation Time'),
                        selected: taskProvider.sort == TaskSort.creationTime,
                        onSelected: (selected) {
                          taskProvider.sortTasks(TaskSort.creationTime);
                          setState(() {});
                        },
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    final taskProvider = Provider.of<TaskProvider>(context);
    
    // If not authenticated, show login screen
    if (!authProvider.isAuthenticated) {
      return const LoginScreen();
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('To-Do List'),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: TaskSearchDelegate(taskProvider),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Filter status indicator
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            color: Theme.of(context).colorScheme.surfaceVariant,
            child: Row(
              children: [
                Text(
                  'Filter: ${_getFilterText(taskProvider.filter)}',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                if (taskProvider.categoryFilter != null) ...[
                  const SizedBox(width: 16),
                  Text(
                    'Category: ${taskProvider.categoryFilter}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Sort: ${_getSortText(taskProvider.sort)}',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          
          // Task list
          Expanded(
            child: TaskList(tasks: taskProvider.tasks),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const AddTaskScreen(),
            ),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  String _getFilterText(TaskFilter filter) {
    switch (filter) {
      case TaskFilter.all:
        return 'All';
      case TaskFilter.completed:
        return 'Completed';
      case TaskFilter.pending:
        return 'Pending';
      case TaskFilter.byCategory:
        return 'By Category';
    }
  }

  String _getSortText(TaskSort sort) {
    switch (sort) {
      case TaskSort.dueDate:
        return 'Due Date';
      case TaskSort.priority:
        return 'Priority';
      case TaskSort.creationTime:
        return 'Creation Time';
    }
  }
}

class TaskSearchDelegate extends SearchDelegate {
  final TaskProvider _taskProvider;

  TaskSearchDelegate(this._taskProvider);

  @override
  List<Widget> buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      )
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    _taskProvider.searchTasks(query);
    return TaskList(tasks: _taskProvider.tasks);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    if (query.isEmpty) {
      return const Center(
        child: Text('Enter a task name to search'),
      );
    }
    
    _taskProvider.searchTasks(query);
    return TaskList(tasks: _taskProvider.tasks);
  }
}