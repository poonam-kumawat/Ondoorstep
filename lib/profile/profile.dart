import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyProfile extends StatelessWidget {
  final String fullName;
  final String email;

  const MyProfile({super.key, required this.fullName, required this.email});

  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');
    return Scaffold(
        appBar: AppBar(
          title: const Text('MyProfile'),
        ),
        body: Column(
          children: [
            TextField(
              onChanged: (value) {
                fullName = value;
              },
            ),
            ElevatedButton(
                onPressed: () async {
                  await users
                      .add({
                        'name': fullName,
                        'mail': email,
                      })
                      .then((value) => print("user Added"))
                      .catchError((error) => print("failed to add: $error"));
                },
                child: Text("submit"))
          ],
        ));
  }
}
