import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/task.dart';

abstract class TaskRepository {
  Stream<List<Task>> getTasks(String userId);
  Future<List<Task>> getTasksOnce(String userId);
  Future<void> addTask(Task task);
  Future<void> updateTask(Task task);
  Future<void> deleteTask(String taskId);
  Future<List<Task>> searchTasks(String query, String userId);
  Stream<List<Task>> getSharedTasks(String userId);
}

class FirestoreTaskRepository implements TaskRepository {
  final FirebaseFirestore _firestore;

  FirestoreTaskRepository({FirebaseFirestore? firestore})
      : _firestore = firestore ?? FirebaseFirestore.instance;

  @override
  Stream<List<Task>> getTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('userId', isEqualTo: userId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<void> addTask(Task task) async {
    try {
      final docRef = _firestore.collection('tasks').doc();
      final newTask = task.copyWith(id: docRef.id);
      await docRef.set(newTask.toMap());
    } catch (e) {
      print('Error adding task: $e');
      rethrow;
    }
  }

  @override
  Future<void> updateTask(Task task) async {
    try {
      await _firestore
          .collection('tasks')
          .doc(task.id)
          .update(task.toMap());
    } catch (e) {
      print('Error updating task: $e');
      rethrow;
    }
  }

  @override
  Future<void> deleteTask(String taskId) async {
    try {
      await _firestore.collection('tasks').doc(taskId).delete();
    } catch (e) {
      print('Error deleting task: $e');
      rethrow;
    }
  }

  @override
  Future<List<Task>> searchTasks(String query, String userId) async {
    try {
      // Firestore doesn't support direct text search, so we'll fetch all tasks
      // for the user and filter them locally
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .get();

      final tasks = querySnapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();

      final lowerQuery = query.toLowerCase();
      return tasks.where((task) {
        return task.title.toLowerCase().contains(lowerQuery) ||
            task.description.toLowerCase().contains(lowerQuery);
      }).toList();
    } catch (e) {
      print('Error searching tasks: $e');
      rethrow;
    }
  }

  @override
  Stream<List<Task>> getSharedTasks(String userId) {
    return _firestore
        .collection('tasks')
        .where('collaborators', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
    });
  }

  @override
  Future<List<Task>> getTasksOnce(String userId) async {
    try {
      final querySnapshot = await _firestore
          .collection('tasks')
          .where('userId', isEqualTo: userId)
          .orderBy('createdAt', descending: true)
          .get();

      return querySnapshot.docs
          .map((doc) => Task.fromFirestore(doc))
          .toList();
    } catch (e) {
      print('Error getting tasks: $e');
      return [];
    }
  }
}