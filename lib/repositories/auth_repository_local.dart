import 'dart:async';
import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

// Custom mock user class that implements Firebase User
class MockUser implements User {
  final String _uid;
  String _email;
  String? _displayName;
  
  MockUser(this._uid, this._email, [this._displayName]) {
    _displayName ??= _email.split('@')[0];
  }
  
  @override
  String get uid => _uid;
  
  @override
  String get email => _email;
  
  @override
  String? get displayName => _displayName;

  @override
  bool get emailVerified => true;

  @override
  bool get isAnonymous => false;

  @override
  Future<void> delete() async {}
  
  @override
  Future<String?> getIdToken([bool forceRefresh = false]) async {
    return 'mock-token-$_uid';
  }
  
  // Implement other methods with default/empty implementations
  @override
  dynamic noSuchMethod(Invocation invocation) {
    return super.noSuchMethod(invocation);
  }
}

class LocalAuthRepository implements AuthRepository {
  MockUser? _currentUser;
  Map<String, String> _users = {
    'test@example.com': 'password123',
    'user@test.com': 'testpass'
  };
  
  final _authStateController = StreamController<User?>.broadcast();
  
  static const String _usersKey = 'local_users';
  static const String _currentUserKey = 'current_user';
  
  LocalAuthRepository() {
    // Load saved users and restore current user
    _loadUsersFromStorage();
  }
  
  @override
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  @override
  Future<User?> signInWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_users.containsKey(email) && _users[email] == password) {
      _currentUser = MockUser('uid-${DateTime.now().millisecondsSinceEpoch}', email);
      _authStateController.add(_currentUser);
      
      // Save current user to storage
      await _saveCurrentUserToStorage(_currentUser!);
      
      return _currentUser;
    } else {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email or password is incorrect.',
      );
    }
  }
  
  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'email-already-in-use',
        message: 'The email address is already in use by another account.',
      );
    }
    
    _users[email] = password;
    _currentUser = MockUser('uid-${DateTime.now().millisecondsSinceEpoch}', email);
    _authStateController.add(_currentUser);
    
    // Save the updated users and current user
    await _saveUsersToStorage();
    await _saveCurrentUserToStorage(_currentUser!);
    
    return _currentUser;
  }
  
  @override
  Future<User?> signInWithGoogle() async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    const email = 'google-user@gmail.com';
    _currentUser = MockUser(
      'google-uid-${DateTime.now().millisecondsSinceEpoch}', 
      email,
      'Google User'
    );
    _authStateController.add(_currentUser);
    
    // Save current user to storage
    await _saveCurrentUserToStorage(_currentUser!);
    
    return _currentUser;
  }
  
  @override
  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 300)); // Simulate delay
    _currentUser = null;
    _authStateController.add(null);
    
    // Remove current user from storage
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_currentUserKey);
  }
  
  @override
  Future<void> resetPassword(String email) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (!_users.containsKey(email)) {
      throw FirebaseAuthException(
        code: 'user-not-found',
        message: 'No user found with this email.',
      );
    }
    
    // Just print the password for testing
    print('Password reset requested for $email. Current password: ${_users[email]}');
  }
  
  @override
  Future<void> saveUserToFirestore(User user) async {
    // No need to implement this for local mock
    await Future.delayed(const Duration(milliseconds: 300));
    print('Mock: Saved user ${user.email} to Firestore');
  }
  
  // Persistence methods
  Future<void> _loadUsersFromStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load users
      final usersJson = prefs.getString(_usersKey);
      if (usersJson != null) {
        final usersMap = jsonDecode(usersJson) as Map<String, dynamic>;
        _users = Map.fromEntries(
          usersMap.entries.map((e) => MapEntry(e.key, e.value.toString()))
        );
      }
      
      // Load current user if exists
      final currentUserJson = prefs.getString(_currentUserKey);
      if (currentUserJson != null) {
        final userMap = jsonDecode(currentUserJson) as Map<String, dynamic>;
        _currentUser = MockUser(
          userMap['uid'], 
          userMap['email'],
          userMap['displayName']
        );
        _authStateController.add(_currentUser);
      } else {
        // Start with no user if none saved
        _authStateController.add(null);
      }
    } catch (e) {
      print('Error loading users from storage: $e');
      // Fallback to default state
      _authStateController.add(null);
    }
  }
  
  Future<void> _saveUsersToStorage() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_usersKey, jsonEncode(_users));
    } catch (e) {
      print('Error saving users to storage: $e');
    }
  }
  
  Future<void> _saveCurrentUserToStorage(MockUser user) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_currentUserKey, jsonEncode({
        'uid': user.uid,
        'email': user.email,
        'displayName': user.displayName,
      }));
    } catch (e) {
      print('Error saving current user to storage: $e');
    }
  }
  
  // Clean up method
  void dispose() {
    _authStateController.close();
  }
}