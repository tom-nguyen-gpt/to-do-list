import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';
import 'auth_repository_local.dart';

/// A hybrid authentication repository that tries to use Firebase first,
/// but falls back to local authentication if Firebase is not available or encounters errors.
class HybridAuthRepository implements AuthRepository {
  final FirebaseAuthRepository _firebaseAuthRepository;
  final LocalAuthRepository _localAuthRepository;
  bool _useFirebase = true;
  
  final _authStateController = StreamController<User?>.broadcast();
  
  HybridAuthRepository({
    FirebaseAuthRepository? firebaseAuthRepository,
    LocalAuthRepository? localAuthRepository,
  })  : _firebaseAuthRepository = firebaseAuthRepository ?? FirebaseAuthRepository(),
        _localAuthRepository = localAuthRepository ?? LocalAuthRepository() {
    // Load saved preference for Firebase vs local auth
    _loadFallbackStatus().then((_) {
      // Try to initialize Firebase and setup auth state listener
      _initializeAuthState();
    });
  }
  
  void _initializeAuthState() {
    // Start by listening to Firebase auth state changes
    try {
      _firebaseAuthRepository.authStateChanges.listen((user) {
        if (_useFirebase) {
          _authStateController.add(user);
        }
      });
    } catch (e) {
      print('Could not initialize Firebase auth state: $e');
      _useFirebase = false;
    }
    
    // Also listen to local auth state changes if Firebase fails
    _localAuthRepository.authStateChanges.listen((user) {
      if (!_useFirebase) {
        _authStateController.add(user);
      }
    });
  }
  
  @override
  Stream<User?> get authStateChanges => _authStateController.stream;
  
  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      if (_useFirebase) {
        return await _firebaseAuthRepository.signInWithEmail(email, password);
      }
    } catch (e) {
      print('Firebase sign in failed, falling back to local: $e');
      _useFirebase = false;
      await _saveFallbackStatus();
    }
    
    // Fallback to local auth
    return await _localAuthRepository.signInWithEmail(email, password);
  }
  
  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      if (_useFirebase) {
        return await _firebaseAuthRepository.signUpWithEmail(email, password);
      }
    } catch (e) {
      print('Firebase sign up failed, falling back to local: $e');
      _useFirebase = false;
      await _saveFallbackStatus();
    }
    
    // Fallback to local auth
    return await _localAuthRepository.signUpWithEmail(email, password);
  }
  
  @override
  Future<User?> signInWithGoogle() async {
    try {
      if (_useFirebase) {
        return await _firebaseAuthRepository.signInWithGoogle();
      }
    } catch (e) {
      print('Firebase Google sign in failed, falling back to local: $e');
      _useFirebase = false;
      await _saveFallbackStatus();
    }
    
    // Fallback to local auth
    return await _localAuthRepository.signInWithGoogle();
  }
  
  @override
  Future<void> signOut() async {
    if (_useFirebase) {
      try {
        await _firebaseAuthRepository.signOut();
        return;
      } catch (e) {
        print('Firebase sign out failed, falling back to local: $e');
        _useFirebase = false;
        await _saveFallbackStatus();
      }
    }
    
    await _localAuthRepository.signOut();
  }
  
  @override
  Future<void> resetPassword(String email) async {
    if (_useFirebase) {
      try {
        await _firebaseAuthRepository.resetPassword(email);
        return;
      } catch (e) {
        print('Firebase reset password failed, falling back to local: $e');
        _useFirebase = false;
        await _saveFallbackStatus();
      }
    }
    
    await _localAuthRepository.resetPassword(email);
  }
  
  @override
  Future<void> saveUserToFirestore(User user) async {
    if (_useFirebase) {
      try {
        await _firebaseAuthRepository.saveUserToFirestore(user);
        return;
      } catch (e) {
        print('Firebase save user to Firestore failed: $e');
        // Don't fall back - this operation is optional
      }
    }
    // No equivalent in local repository
  }
  
  // Save whether we're using Firebase or local auth
  Future<void> _saveFallbackStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('use_firebase_auth', _useFirebase);
    } catch (e) {
      print('Failed to save auth fallback status: $e');
    }
  }
  
  // Check if we're using Firebase or local auth
  Future<void> _loadFallbackStatus() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _useFirebase = prefs.getBool('use_firebase_auth') ?? true;
    } catch (e) {
      print('Failed to load auth fallback status: $e');
      _useFirebase = true;
    }
  }
  
  // Clean up method
  void dispose() {
    _authStateController.close();
  }
}