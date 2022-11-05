import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screen/welcome_screen.dart';

Future<User?> createAccount(String name, String email, String pass) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: pass))
        .user;

    if (user != null) {
      print("Account Creation Successful");

      user.updateDisplayName(name);
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Online",
        "uid": _auth.currentUser!.uid
      });
    } else {
      print("Account creation failed");
    }
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future<User?> login(String email, String password) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      print("Login Successful");
    } else {
      print("Login failed");
    }
    return user;
  } catch (e) {
    print(e);
    return null;
  }
}

Future logout(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    await _auth.signOut().then((value) => Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => const WelcomeScreen()))));
  } catch (e) {
    print(e);
  }
}
