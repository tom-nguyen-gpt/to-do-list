import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';
import 'auth_repository.dart';

class MockAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  
  // Mock user data for testing
  final Map<String, String> _mockUsers = {
    'test@example.com': 'password123',
    'user@test.com': 'testpass'
  };

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      // Check if this is a mock user
      if (_mockUsers.containsKey(email) && _mockUsers[email] == password) {
        // Use anonymous sign-in but store the email for display
        final userCredential = await _firebaseAuth.signInAnonymously();
        final user = userCredential.user;
        
        if (user != null) {
          // Update profile with the mock email
          await user.updateDisplayName(email.split('@')[0]);
          await user.updateEmail(email);
          
          // Save to Firestore
          await saveUserToFirestore(user);
        }
        
        return user;
      } else {
        // Try real Firebase auth
        final result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return result.user;
      }
    } catch (e) {
      print('Sign in with email failed: $e');
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // Add to mock users for testing
      _mockUsers[email] = password;
      
      // Use anonymous sign-in but store the email for display
      final userCredential = await _firebaseAuth.signInAnonymously();
      final user = userCredential.user;
      
      if (user != null) {
        // Update profile with the mock email
        await user.updateDisplayName(email.split('@')[0]);
        await user.updateEmail(email);
        
        // Save to Firestore
        await saveUserToFirestore(user);
      }
      
      return user;
    } catch (e) {
      print('Sign up with email failed: $e');
      rethrow;
    }
  }

  @override
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final result = await _firebaseAuth.signInWithCredential(credential);
      if (result.user != null) {
        await saveUserToFirestore(result.user!);
      }
      return result.user;
    } catch (e) {
      print('Sign in with Google failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await Future.wait([
        _firebaseAuth.signOut(),
        _googleSignIn.signOut(),
      ]);
    } catch (e) {
      print('Sign out failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> resetPassword(String email) async {
    try {
      if (_mockUsers.containsKey(email)) {
        // Mock reset - just print the password for testing
        print('Mock password reset for $email: ${_mockUsers[email]}');
      } else {
        await _firebaseAuth.sendPasswordResetEmail(email: email);
      }
    } catch (e) {
      print('Password reset failed: $e');
      rethrow;
    }
  }

  @override
  Future<void> saveUserToFirestore(User user) async {
    try {
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      
      if (!userDoc.exists) {
        final userModel = UserModel.fromFirebaseUser(
          user,
          createdAt: DateTime.now(),
          lastActive: DateTime.now(),
        );
        
        await _firestore.collection('users').doc(user.uid).set(userModel.toMap());
      } else {
        // Update last active timestamp
        await _firestore.collection('users').doc(user.uid).update({
          'lastActive': FieldValue.serverTimestamp(),
        });
      }
    } catch (e) {
      print('Error saving user to Firestore: $e');
      rethrow;
    }
  }
}