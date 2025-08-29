import 'package:cloud_firestore/cloud_firestore.dart';

class TaskList {
  final String id;
  final String name;
  final String ownerId;
  final List<String> collaborators;
  final List<String> taskIds;
  final DateTime createdAt;
  final DateTime updatedAt;

  TaskList({
    required this.id,
    required this.name,
    required this.ownerId,
    this.collaborators = const [],
    this.taskIds = const [],
    required this.createdAt,
    required this.updatedAt,
  });

  TaskList copyWith({
    String? id,
    String? name,
    String? ownerId,
    List<String>? collaborators,
    List<String>? taskIds,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return TaskList(
      id: id ?? this.id,
      name: name ?? this.name,
      ownerId: ownerId ?? this.ownerId,
      collaborators: collaborators ?? this.collaborators,
      taskIds: taskIds ?? this.taskIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'ownerId': ownerId,
      'collaborators': collaborators,
      'taskIds': taskIds,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  factory TaskList.fromMap(Map<String, dynamic> map) {
    return TaskList(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      ownerId: map['ownerId'] ?? '',
      collaborators: List<String>.from(map['collaborators'] ?? []),
      taskIds: List<String>.from(map['taskIds'] ?? []),
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      updatedAt: (map['updatedAt'] as Timestamp).toDate(),
    );
  }

  factory TaskList.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return TaskList.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  TaskList addTask(String taskId) {
    if (taskIds.contains(taskId)) return this;
    
    final newTaskIds = List<String>.from(taskIds)..add(taskId);
    return copyWith(
      taskIds: newTaskIds,
      updatedAt: DateTime.now(),
    );
  }

  TaskList removeTask(String taskId) {
    final newTaskIds = List<String>.from(taskIds)..remove(taskId);
    return copyWith(
      taskIds: newTaskIds,
      updatedAt: DateTime.now(),
    );
  }

  TaskList addCollaborator(String userId) {
    if (collaborators.contains(userId)) return this;
    
    final newCollaborators = List<String>.from(collaborators)..add(userId);
    return copyWith(
      collaborators: newCollaborators,
      updatedAt: DateTime.now(),
    );
  }

  TaskList removeCollaborator(String userId) {
    final newCollaborators = List<String>.from(collaborators)..remove(userId);
    return copyWith(
      collaborators: newCollaborators,
      updatedAt: DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'TaskList(id: $id, name: $name)';
  }
}