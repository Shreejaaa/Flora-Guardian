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
    // Pre-validate email and password
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email)) {
      return "Please enter a valid email address.";
    }

    if (password.isEmpty || password.length < 6) {
      return "Password must be at least 6 characters long.";
    }

    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      return null; // Success
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        return 'User not found. Please check your email.';
      } else if (e.code == 'wrong-password') {
        return 'Incorrect password. Please try again.';
      } else if (e.code == 'invalid-credential') {
        return 'Invalid email or password. Please check your credentials.';
      }
      return 'Login failed: ${e.message}';
    } catch (e) {
      return 'An unexpected error occurred. Please try again.';
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
      debugPrint(e.toString());
      return null;
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