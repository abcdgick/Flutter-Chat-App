import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_chat_app/screen/welcome_screen.dart';

Future<User?> createAccount(
    String name, String email, String pass, BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseFirestore _firestore = FirebaseFirestore.instance;

  try {
    User? user = (await _auth.createUserWithEmailAndPassword(
            email: email, password: pass))
        .user;

    if (user != null) {
      user.updateDisplayName(name);
      await _firestore.collection('users').doc(_auth.currentUser!.uid).set({
        "name": name,
        "email": email,
        "status": "Online",
        "uid": _auth.currentUser!.uid
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("Welcome ${user.displayName}!"),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Account Creation Failed"),
        ),
      );
    }
    return user;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message!),
      ),
    );
    return null;
  }
}

Future<User?> login(String email, String password, BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    User? user = (await _auth.signInWithEmailAndPassword(
            email: email, password: password))
        .user;

    if (user != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Welcome Back ${user.displayName}!'),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Login Failed'),
        ),
      );
    }
    return user;
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message!),
      ),
    );
    return null;
  }
}

Future logout(BuildContext context) async {
  FirebaseAuth _auth = FirebaseAuth.instance;

  try {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Come Again!'),
      ),
    );
    await _auth.signOut().then((value) => Navigator.pushReplacement(context,
        MaterialPageRoute(builder: ((context) => const WelcomeScreen()))));
  } on FirebaseAuthException catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(e.message!),
      ),
    );
  }
}
