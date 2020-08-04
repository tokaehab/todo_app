import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class User {
  final String id;
  final String email;
  String username;
  User({
    @required this.id,
    @required this.email,
    @required this.username,
  });
}

class UserProvider with ChangeNotifier {
  User currentUser;

  void setUser(String id, String email, String username) {
    currentUser = User(id: id, email: email, username: username);
  }

  Future<void> editUser(
      String newUsername, String newPass, bool editPassword) async {
    try {
      await Firestore.instance
          .collection('users')
          .document(currentUser.id)
          .setData({
        'username': newUsername,
      }, merge: true);
      if (editPassword)
        await (await FirebaseAuth.instance.currentUser())
            .updatePassword(newPass);
      currentUser.username = newUsername;
      notifyListeners();
    } catch (error) {
      print(error);
    }
  }
}
