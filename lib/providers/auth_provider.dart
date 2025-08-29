import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../repositories/auth_repository.dart';

enum AuthState {
  initial,
  authenticated,
  unauthenticated,
  loading,
  error,
}

class AppAuthProvider extends ChangeNotifier {
  final AuthRepository _authRepository;
  
  User? _firebaseUser;
  UserModel? _user;
  AuthState _state = AuthState.initial;
  String _errorMessage = '';
  
  AppAuthProvider({required AuthRepository authRepository}) 
      : _authRepository = authRepository {
    _init();
  }
  
  // Getters
  User? get firebaseUser => _firebaseUser;
  UserModel? get user => _user;
  AuthState get state => _state;
  String get errorMessage => _errorMessage;
  bool get isAuthenticated => _state == AuthState.authenticated;
  bool get isLoading => _state == AuthState.loading;
  
  // Initialize auth state
  void _init() {
    _firebaseUser = null;
    _state = AuthState.unauthenticated;
    
    // Listen for changes to the auth state
    _authRepository.authStateChanges.listen((user) {
      _firebaseUser = user;
      if (user != null) {
        _state = AuthState.authenticated;
      } else {
        _state = AuthState.unauthenticated;
        _user = null;
      }
      notifyListeners();
    });
    
    // Notify listeners right away to ensure UI updates
    notifyListeners();
  }
  
  // Sign in with email and password
  Future<void> signInWithEmail(String email, String password) async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      
      await _authRepository.signInWithEmail(email, password);
      _errorMessage = '';
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _state = AuthState.error;
    }
    notifyListeners();
  }
  
  // Sign up with email and password
  Future<void> signUpWithEmail(String email, String password) async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      
      await _authRepository.signUpWithEmail(email, password);
      _errorMessage = '';
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _state = AuthState.error;
    }
    notifyListeners();
  }
  
  // Sign in with Google
  Future<void> signInWithGoogle() async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      
      await _authRepository.signInWithGoogle();
      _errorMessage = '';
      _state = AuthState.authenticated;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _state = AuthState.error;
    }
    notifyListeners();
  }
  
  // Sign out
  Future<void> signOut() async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      
      await _authRepository.signOut();
      _state = AuthState.unauthenticated;
      _user = null;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _state = AuthState.error;
    }
    notifyListeners();
  }
  
  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      _state = AuthState.loading;
      notifyListeners();
      
      await _authRepository.resetPassword(email);
      _errorMessage = '';
      _state = AuthState.unauthenticated;
    } catch (e) {
      _errorMessage = _handleAuthError(e);
      _state = AuthState.error;
    }
    notifyListeners();
  }
  
  // Helper to handle auth errors
  String _handleAuthError(dynamic error) {
    if (error is FirebaseAuthException) {
      switch (error.code) {
        case 'user-not-found':
          return 'No user found with this email.';
        case 'wrong-password':
          return 'Wrong password provided.';
        case 'email-already-in-use':
          return 'The email address is already in use.';
        case 'invalid-email':
          return 'The email address is invalid.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'operation-not-allowed':
          return 'This operation is not allowed.';
        case 'user-disabled':
          return 'This user has been disabled.';
        default:
          return 'An error occurred. Please try again.';
      }
    }
    return 'An unknown error occurred.';
  }
  
  // Clear any error messages
  void clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}