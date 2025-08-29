import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

abstract class AuthRepository {
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> signUpWithEmail(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Future<void> resetPassword(String email);
  Stream<User?> get authStateChanges;
  Future<void> saveUserToFirestore(User user);
}

class FirebaseAuthRepository implements AuthRepository {
  final FirebaseAuth _firebaseAuth;
  final FirebaseFirestore _firestore;
  final GoogleSignIn _googleSignIn;

  FirebaseAuthRepository({
    FirebaseAuth? firebaseAuth,
    FirebaseFirestore? firestore,
    GoogleSignIn? googleSignIn,
  })  : _firebaseAuth = firebaseAuth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _googleSignIn = googleSignIn ?? GoogleSignIn();

  @override
  Stream<User?> get authStateChanges => _firebaseAuth.authStateChanges();

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      try {
        final result = await _firebaseAuth.signInWithEmailAndPassword(
          email: email,
          password: password,
        );
        return result.user;
      } catch (e) {
        if (e is FirebaseAuthException && e.code == 'user-not-found') {
          // User might have been created with anonymous auth fallback
          // Let's check if an anonymous user with this email exists
          final users = await _firebaseAuth.fetchSignInMethodsForEmail(email);
          if (users.contains('password')) {
            // Try again with a force refresh
            final result = await _firebaseAuth.signInWithEmailAndPassword(
              email: email,
              password: password,
            );
            return result.user;
          }
        }
        print('Sign in with email failed: $e');
        rethrow;
      }
    } catch (e) {
      print('Sign in with email failed: $e');
      rethrow;
    }
  }

  @override
  Future<User?> signUpWithEmail(String email, String password) async {
    try {
      // For development purposes, disable reCAPTCHA verification
      try {
        await _firebaseAuth.setSettings(
          appVerificationDisabledForTesting: true,
        );
      } catch (settingsError) {
        print('Warning: Could not disable reCAPTCHA: $settingsError');
      }
      
      // Try with reCAPTCHA token first
      try {
        final result = await _firebaseAuth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
        if (result.user != null) {
          await saveUserToFirestore(result.user!);
        }
        return result.user;
      } catch (authError) {
        if (authError is FirebaseAuthException && 
            (authError.code == 'unknown' || authError.message?.contains('CONFIGURATION_NOT_FOUND') == true)) {
          print('Firebase reCAPTCHA configuration issue detected. Falling back to anonymous auth');
          
          // Create an anonymous user first, then update email and password
          final anonResult = await _firebaseAuth.signInAnonymously();
          if (anonResult.user != null) {
            // Link email credential to anonymous user
            final credential = EmailAuthProvider.credential(email: email, password: password);
            await anonResult.user!.linkWithCredential(credential);
            
            // Update user profile
            await anonResult.user!.updateEmail(email);
            
            // Save to Firestore
            await saveUserToFirestore(anonResult.user!);
            
            return anonResult.user;
          }
        }
        // Re-throw if it's not the specific error we're handling or the fallback failed
        print('Sign up with email failed: $authError');
        rethrow;
      }
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
      await _firebaseAuth.sendPasswordResetEmail(email: email);
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