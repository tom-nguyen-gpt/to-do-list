import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'repositories/auth_repository.dart';
import 'repositories/auth_repository_hybrid.dart';
import 'repositories/task_repository.dart';
import 'repositories/task_repository_local.dart';
import 'providers/auth_provider.dart' show AppAuthProvider, AuthState;
import 'providers/task_provider.dart';
import 'providers/theme_provider.dart';
import 'screens/login_screen.dart';
import 'screens/home_screen.dart';
import 'services/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  try {
    await Firebase.initializeApp();
    
    // Configure Firebase Database URL
    FirebaseDatabase.instance.databaseURL = 
      'https://todolist-12323-default-rtdb.asia-southeast1.firebasedatabase.app';
    
    print('Firebase initialized successfully');
  } catch (e) {
    print('Firebase initialization error: $e');
    throw Exception('Failed to initialize Firebase: $e');
  }

  // Initialize notification service
  await NotificationService.instance.init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Repositories
        Provider<AuthRepository>(
          create: (_) => HybridAuthRepository(), // Using hybrid authentication (Firebase with local fallback)
        ),
        Provider<TaskRepository>(
          create: (_) => LocalTaskRepository(),
        ),
        
        // Providers
        ChangeNotifierProvider<AppAuthProvider>(
          create: (context) => AppAuthProvider(
            authRepository: context.read<AuthRepository>(),
          ),
        ),
        ChangeNotifierProvider<TaskProvider>(
          create: (context) => TaskProvider(
            taskRepository: context.read<TaskRepository>(),
          ),
        ),
        
        // Theme provider
        ChangeNotifierProvider<ThemeProvider>(
          create: (context) => ThemeProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, _) => MaterialApp(
          title: 'To-Do List',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          darkTheme: ThemeData(
            colorScheme: ColorScheme.fromSeed(
              seedColor: Colors.deepPurple,
              brightness: Brightness.dark,
            ),
            useMaterial3: true,
          ),
          themeMode: themeProvider.themeMode,
          home: const AuthWrapper(),
        ),
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AppAuthProvider>(context);
    print("Auth state: ${authProvider.state}");
    
    // Show splash screen while initializing
    if (authProvider.state == AuthState.initial) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Navigate based on authentication state
    if (authProvider.isAuthenticated) {
      return const HomeScreen();
    } else {
      return const LoginScreen();
    }
  }
}