import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flora_guardian/models/user_model.dart';
import 'package:flutter/widgets.dart';

class UserController {
  final _auth = FirebaseAuth.instance;
  final _db = FirebaseFirestore.instance;

  String getCurrentUser() {
    return _auth.currentUser!.uid.toString();
  }

  Future<String?> login(String email, String password) async {
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found';
      } else if (e.code == 'wrong-password') {
        return 'Wrong password';
      }
      return 'Login failed: ${e.message}';
    }
  }

  Future saveUseToDb(UserModel user) async {
    try {
      await _db.collection("users").doc(getCurrentUser()).set(user.toJson());
    } catch (e) {
      debugPrint("Failed to add user to db: ${e.toString()}");
    }
  }

  Future logOut() async {
    try {
      await _auth.signOut();
    } on FirebaseAuthException catch (e) {
      debugPrint("Cannot logout ${e.toString()}");
    }
  }

  Future<User?> signup(String email, String password) async {
  try {
    UserCredential userCredential = await _auth
        .createUserWithEmailAndPassword(email: email, password: password);
    return userCredential.user;
  } on FirebaseAuthException catch (e) {
    debugPrint(e.toString()); // Keep this for console logging
    rethrow; // Changed from "return null" to "rethrow" to propagate the exception
  }
}
  Future<bool> isUsernameTaken(String username) async {
  try {
    final query = await _db.collection("users")
        .where("userName", isEqualTo: username)
        .get();
    return query.docs.isNotEmpty;
  } catch (e) {
    debugPrint("Error checking username: $e");
    return false;
  }
}

  Future<UserModel?> getUserData() async {
    try {
      DocumentSnapshot doc =
          await _db.collection("users").doc(getCurrentUser()).get();
      if (doc.exists && doc.data() != null) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        return UserModel.fromJson(data);
      }
      return null;
    } catch (e) {
      debugPrint("Error fetching user data: ${e.toString()}");
      return null;
    }
  }

  Future<bool> updateUser(UserModel user) async {
    try {
      await _db.collection("users").doc(getCurrentUser()).update(user.toJson());
      return true;
    } catch (e) {
      debugPrint("Error updating user data: ${e.toString()}");
      return false;
    }
  }

  Future<bool> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
      return true;
    } on FirebaseAuthException catch (e) {
      debugPrint("Password reset error: ${e.toString()}");
      return false;
    }
  }
}