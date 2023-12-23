import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_interview/core/const.dart';
import 'package:flutter_interview/core/notifiers.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Future getDocId() async {
    User? user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      String? email = user.email;
      try {
        DocumentSnapshot<Map<String, dynamic>> snapshot =
            await FirebaseFirestore.instance
                .collection('users')
                .doc(email)
                .get();
        if (snapshot.exists) {
          Map<String, dynamic> userData = snapshot.data()!;
          print('User data: $userData');
        } else {
          print('Document does not exist');
        }
      } catch (e) {
        print('Error fetching document: $e');
      }
    }
  }

  @override
  void initState() {
    getDocId();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Profile"),
        actions: [
          MaterialButton(
            onPressed: () {
              FirebaseAuth.instance.signOut();
            },
            color: Colors.deepPurple[200],
            child: const Text('Sign out'),
          ),
        ],
      ),
      body: const SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage:
                  AssetImage('${pathImageFolder}07bf79639e8237dc6e93.jpg'),
              radius: 90,
            ),
            SizedBox(height: kdouble20),
            ListTile(leading: Icon(Icons.person), title: Text("Full name")),
            ListTile(leading: Icon(Icons.email), title: Text("Email")),
            ListTile(leading: Icon(Icons.phone), title: Text("Phone number")),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          isDarkModeNotifier.value = !isDarkModeNotifier.value;
        },
        child: ValueListenableBuilder(
            valueListenable: isDarkModeNotifier,
            builder: (context, isDark, child) {
              if (isDark) return const Icon(Icons.dark_mode);
              return const Icon(Icons.light_mode);
            }),
      ),
    );
  }
}
