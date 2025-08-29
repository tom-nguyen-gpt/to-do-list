import 'package:flutter/material.dart';
import '../models/task.dart';
import '../repositories/task_repository.dart';
import '../services/notification_service.dart';

enum TaskFilter { all, completed, pending, byCategory }
enum TaskSort { dueDate, priority, creationTime }

class TaskProvider extends ChangeNotifier {
  final TaskRepository _taskRepository;
  
  List<Task> _allTasks = [];
  List<Task> _filteredTasks = [];
  TaskFilter _filter = TaskFilter.all;
  TaskSort _sort = TaskSort.dueDate;
  String _searchQuery = '';
  String? _categoryFilter;
  bool _isLoading = false;
  String _errorMessage = '';
  String? _userId;
  
  TaskProvider({required TaskRepository taskRepository})
      : _taskRepository = taskRepository;
  
  // Getters
  List<Task> get tasks => _filteredTasks;
  TaskFilter get filter => _filter;
  TaskSort get sort => _sort;
  String get searchQuery => _searchQuery;
  String? get categoryFilter => _categoryFilter;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  String? get userId => _userId;
  
  // Set the current user ID and start listening to tasks
  void setUserId(String userId) {
    if (_userId == userId) return;
    
    _userId = userId;
    _listenToTasks();
    _scheduleNotificationsForTasks();
  }
  
  // Schedule notifications for all tasks with due dates
  Future<void> _scheduleNotificationsForTasks() async {
    if (_userId == null) return;
    
    try {
      final tasks = await _taskRepository.getTasksOnce(_userId!);
      for (final task in tasks) {
        if (!task.isCompleted && task.dueDate != null) {
          await NotificationService.instance.scheduleTaskReminder(task);
        }
      }
    } catch (e) {
      print('Failed to schedule notifications for tasks: $e');
    }
  }
  
  // Public method to reschedule all task notifications
  // Called when notification settings change
  Future<void> rescheduleAllTaskNotifications() async {
    await NotificationService.instance.cancelTaskReminders();
    await _scheduleNotificationsForTasks();
  }
  
  // Listen to task updates from Firestore
  void _listenToTasks() {
    if (_userId == null) return;
    
    _isLoading = true;
    notifyListeners();
    
    _taskRepository.getTasks(_userId!).listen(
      (tasks) {
        _allTasks = tasks;
        _applyFiltersAndSort();
        _isLoading = false;
        notifyListeners();
      },
      onError: (error) {
        _errorMessage = 'Failed to load tasks: $error';
        _isLoading = false;
        notifyListeners();
      },
    );
  }
  
  // Add a new task
  Future<void> addTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _taskRepository.addTask(task);
      _errorMessage = '';
      
      // Schedule notification if task has a due date
      if (task.dueDate != null) {
        await NotificationService.instance.scheduleTaskReminder(task);
      }
    } catch (e) {
      _errorMessage = 'Failed to add task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Update an existing task
  Future<void> updateTask(Task task) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _taskRepository.updateTask(task);
      _errorMessage = '';
      
      // Cancel existing notification
      await NotificationService.instance.cancelTaskReminder(task.id);
      
      // Schedule a new notification if the task is not completed and has a due date
      if (!task.isCompleted && task.dueDate != null) {
        await NotificationService.instance.scheduleTaskReminder(task);
      }
    } catch (e) {
      _errorMessage = 'Failed to update task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Delete a task
  Future<void> deleteTask(String taskId) async {
    try {
      _isLoading = true;
      notifyListeners();
      
      await _taskRepository.deleteTask(taskId);
      
      // Cancel any scheduled notifications for this task
      await NotificationService.instance.cancelTaskReminder(taskId);
      
      _errorMessage = '';
    } catch (e) {
      _errorMessage = 'Failed to delete task: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Mark a task as completed or incomplete
  Future<void> toggleTaskCompletion(Task task) async {
    final bool wasCompleted = task.isCompleted;
    
    final updatedTask = wasCompleted
        ? task.markAsIncomplete()
        : task.markAsCompleted();
    
    await updateTask(updatedTask);
    
    // Show notification when a task is completed
    if (!wasCompleted && updatedTask.isCompleted) {
      await NotificationService.instance.showInstantNotification(
        'Task Completed',
        'You completed "${task.title}"',
      );
    }
  }
  
  // Apply filter to tasks
  void filterTasks(TaskFilter filter) {
    _filter = filter;
    _applyFiltersAndSort();
    notifyListeners();
  }
  
  // Apply category filter
  void filterByCategory(String? category) {
    _categoryFilter = category;
    if (category != null) {
      _filter = TaskFilter.byCategory;
    }
    _applyFiltersAndSort();
    notifyListeners();
  }
  
  // Sort tasks
  void sortTasks(TaskSort sort) {
    _sort = sort;
    _applyFiltersAndSort();
    notifyListeners();
  }
  
  // Search tasks
  Future<void> searchTasks(String query) async {
    _searchQuery = query;
    
    if (query.isEmpty) {
      _applyFiltersAndSort();
      notifyListeners();
      return;
    }
    
    try {
      _isLoading = true;
      notifyListeners();
      
      if (_userId != null) {
        final results = await _taskRepository.searchTasks(query, _userId!);
        _allTasks = results;
        _applyFiltersAndSort();
      }
    } catch (e) {
      _errorMessage = 'Search failed: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
  
  // Apply filters and sort to all tasks
  void _applyFiltersAndSort() {
    // Start with all tasks
    List<Task> result = List.from(_allTasks);
    
    // Apply filters
    switch (_filter) {
      case TaskFilter.all:
        // No filtering needed
        break;
      case TaskFilter.completed:
        result = result.where((task) => task.isCompleted).toList();
        break;
      case TaskFilter.pending:
        result = result.where((task) => !task.isCompleted).toList();
        break;
      case TaskFilter.byCategory:
        if (_categoryFilter != null) {
          result = result.where((task) => task.category == _categoryFilter).toList();
        }
        break;
    }
    
    // Apply search if query is not empty
    if (_searchQuery.isNotEmpty) {
      final lowerQuery = _searchQuery.toLowerCase();
      result = result.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery);
      }).toList();
    }
    
    // Apply sorting
    switch (_sort) {
      case TaskSort.dueDate:
        result.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
        break;
      case TaskSort.priority:
        result.sort((a, b) => b.priority.index.compareTo(a.priority.index));
        break;
      case TaskSort.creationTime:
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
    }
    
    _filteredTasks = result;
  }
  
  // Get all unique categories
  List<String> get categories {
    return _allTasks
        .map((task) => task.category)
        .toSet()
        .toList();
  }
  
  // Clear any error messages
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}