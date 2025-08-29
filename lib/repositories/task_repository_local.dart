import 'dart:async';
import '../models/task.dart';
import 'task_repository.dart';

class LocalTaskRepository implements TaskRepository {
  final Map<String, List<Task>> _userTasks = {};
  final Map<String, StreamController<List<Task>>> _taskControllers = {};
  
  // Helper to get or create a controller for a user
  StreamController<List<Task>> _getController(String userId) {
    if (!_taskControllers.containsKey(userId)) {
      _taskControllers[userId] = StreamController<List<Task>>.broadcast();
      _userTasks[userId] = [];
    }
    return _taskControllers[userId]!;
  }
  
  // Helper to notify listeners of changes
  void _notifyListeners(String userId) {
    if (_taskControllers.containsKey(userId)) {
      _taskControllers[userId]!.add(List.from(_userTasks[userId] ?? []));
    }
  }
  
  @override
  Stream<List<Task>> getTasks(String userId) {
    final controller = _getController(userId);
    
    // Add initial data
    if (!_userTasks.containsKey(userId)) {
      _userTasks[userId] = _generateSampleTasks(userId);
    }
    
    // Add data to stream
    Future.microtask(() {
      controller.add(List.from(_userTasks[userId] ?? []));
    });
    
    return controller.stream;
  }
  
  @override
  Future<void> addTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    final userId = task.userId;
    if (!_userTasks.containsKey(userId)) {
      _userTasks[userId] = [];
    }
    
    _userTasks[userId]!.add(task);
    _notifyListeners(userId);
  }
  
  @override
  Future<void> updateTask(Task task) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    final userId = task.userId;
    if (!_userTasks.containsKey(userId)) return;
    
    final index = _userTasks[userId]!.indexWhere((t) => t.id == task.id);
    if (index != -1) {
      _userTasks[userId]![index] = task;
      _notifyListeners(userId);
    }
  }
  
  @override
  Future<void> deleteTask(String taskId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    for (final userId in _userTasks.keys) {
      final tasks = _userTasks[userId]!;
      final index = tasks.indexWhere((t) => t.id == taskId);
      if (index != -1) {
        tasks.removeAt(index);
        _notifyListeners(userId);
        break;
      }
    }
  }
  
  @override
  Future<List<Task>> searchTasks(String query, String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    if (!_userTasks.containsKey(userId)) return [];
    
    final lowerQuery = query.toLowerCase();
    return _userTasks[userId]!
        .where((task) => 
            task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery))
        .toList();
  }
  
  @override
  Stream<List<Task>> getSharedTasks(String userId) {
    // For simplicity, return empty list for shared tasks in mock
    return Stream.value([]);
  }
  
  @override
  Future<List<Task>> getTasksOnce(String userId) async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate network delay
    
    if (!_userTasks.containsKey(userId)) {
      _userTasks[userId] = _generateSampleTasks(userId);
    }
    
    return List.from(_userTasks[userId] ?? []);
  }
  
  // Generate some sample tasks for testing
  List<Task> _generateSampleTasks(String userId) {
    final now = DateTime.now();
    
    return [
      Task(
        id: 'task-1',
        title: 'Buy groceries',
        description: 'Milk, eggs, bread, and fruits',
        priority: Priority.medium,
        category: 'Shopping',
        userId: userId,
        createdAt: now.subtract(const Duration(days: 1)),
        updatedAt: now.subtract(const Duration(days: 1)),
        dueDate: now.add(const Duration(days: 1)),
      ),
      Task(
        id: 'task-2',
        title: 'Complete project report',
        description: 'Finish the quarterly report for the management',
        priority: Priority.high,
        category: 'Work',
        userId: userId,
        createdAt: now.subtract(const Duration(days: 3)),
        updatedAt: now.subtract(const Duration(days: 2)),
        dueDate: now.add(const Duration(days: 2)),
      ),
      Task(
        id: 'task-3',
        title: 'Go for a run',
        description: 'Morning jog in the park',
        priority: Priority.low,
        category: 'Health',
        isCompleted: true,
        userId: userId,
        createdAt: now.subtract(const Duration(days: 5)),
        updatedAt: now.subtract(const Duration(hours: 12)),
        completedAt: now.subtract(const Duration(hours: 12)),
      ),
    ];
  }
  
  // Clean up method
  void dispose() {
    for (final controller in _taskControllers.values) {
      controller.close();
    }
    _taskControllers.clear();
  }
}