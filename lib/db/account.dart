import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screen/welcome_screen.dart';

Future<User?> createAccount(String name, String email, String pass) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: pass))
        .user;

    if (user != null) {
      print("Accrount Creation Successful");
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
      print("Login failes");
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
    await _auth.signOut().then((value) => Navigator.push(context,
        MaterialPageRoute(builder: ((context) => const WelcomeScreen()))));
  } catch (e) {
    print(e);
  }
}
