import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_interview/providers/theme_provider.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:flutter_interview/classes/user_class.dart';
import 'package:flutter_interview/core/const.dart';
import '../main.dart';

class ProfilePage extends HookConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userData = useState<UserData>(UserData(
      firstName: "",
      lastName: "",
      email: "",
      dob: DateTime.now(),
      privateImageUrl: "https://static.thenounproject.com/png/3322766-200.png",
    ));

    Future<void> getProfile() async {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final email = user.email;
        try {
          final snapshot = await FirebaseFirestore.instance
              .collection('users')
              .doc(email)
              .get();
          if (snapshot.exists) {
            final userDataMap = snapshot.data()!;
            userData.value = UserData.fromMap(userDataMap);
            print('User data: $userDataMap');
          } else {
            print('Document does not exist');
          }
        } catch (e) {
          print('Error fetching document: $e');
        }
      }
    }

    useEffect(() {
      getProfile();
      return () {}; // Cleanup function if needed
    }, []);

    final isDark = ref.watch(appThemeStateNotifier).isDarkModeEnabled;

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
      body: SingleChildScrollView(
        child: Column(
          children: [
            CircleAvatar(
              backgroundImage: NetworkImage(userData.value.privateImageUrl),
              radius: 90,
            ),
            const SizedBox(height: kdouble20),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text("Full name"),
              subtitle: Text(
                  "${userData.value.firstName} ${userData.value.lastName}"),
            ),
            ListTile(
              leading: const Icon(Icons.email),
              title: const Text("Email"),
              subtitle: Text(userData.value.email),
            ),
            ListTile(
              leading: const Icon(Icons.calendar_today),
              title: const Text("Birthday"),
              subtitle: Text(
                DateFormat('MM/dd/yyyy').format(userData.value.dob),
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          final appTheme = ref.read(appThemeStateNotifier);
          appTheme.isDarkModeEnabled = !isDark;
          if (isDark) {
            appTheme.setLightTheme();
          } else {
            appTheme.setDarkTheme();
          }
        },
        child: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
      ),
    );
  }
}
