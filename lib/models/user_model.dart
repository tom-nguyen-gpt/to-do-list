import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String id;
  final String email;
  final String? displayName;
  final String? photoURL;
  final Map<String, dynamic> preferences;
  final DateTime createdAt;
  final DateTime lastActive;

  UserModel({
    required this.id,
    required this.email,
    this.displayName,
    this.photoURL,
    this.preferences = const {
      'theme': 'light',
      'notifications': true,
      'dailyReminder': false,
    },
    required this.createdAt,
    required this.lastActive,
  });

  UserModel copyWith({
    String? id,
    String? email,
    String? displayName,
    String? photoURL,
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoURL: photoURL ?? this.photoURL,
      preferences: preferences ?? this.preferences,
      createdAt: createdAt ?? this.createdAt,
      lastActive: lastActive ?? this.lastActive,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'displayName': displayName,
      'photoURL': photoURL,
      'preferences': preferences,
      'createdAt': Timestamp.fromDate(createdAt),
      'lastActive': Timestamp.fromDate(lastActive),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map) {
    return UserModel(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      displayName: map['displayName'],
      photoURL: map['photoURL'],
      preferences: Map<String, dynamic>.from(map['preferences'] ?? {}),
      createdAt: (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastActive: (map['lastActive'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  factory UserModel.fromFirestore(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data()!;
    return UserModel.fromMap({
      'id': doc.id,
      ...data,
    });
  }

  factory UserModel.fromFirebaseUser(
    dynamic firebaseUser, {
    Map<String, dynamic>? preferences,
    DateTime? createdAt,
    DateTime? lastActive,
  }) {
    return UserModel(
      id: firebaseUser.uid,
      email: firebaseUser.email ?? '',
      displayName: firebaseUser.displayName,
      photoURL: firebaseUser.photoURL,
      preferences: preferences ?? {
        'theme': 'light',
        'notifications': true,
        'dailyReminder': false,
      },
      createdAt: createdAt ?? DateTime.now(),
      lastActive: lastActive ?? DateTime.now(),
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, email: $email)';
  }
}