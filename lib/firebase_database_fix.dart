import 'package:firebase_database/firebase_database.dart';

class FirebaseDatabaseFix {
  static void initialize() {
    // Configure Firebase Database URL explicitly to use the correct region
    FirebaseDatabase.instance.databaseURL = 
      'https://todolist-12323-default-rtdb.asia-southeast1.firebasedatabase.app';
  }
}