import 'package:flutter/material.dart';
import 'package:flutter_interview/core/notifiers.dart';
import 'package:flutter_interview/widget_tree.dart';
// import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:oktoast/oktoast.dart';

void main() async {
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
        valueListenable: isDarkModeNotifier,
        builder: (context, isDark, child) {
          return OKToast(
            child: MaterialApp(
              debugShowCheckedModeBanner: false,
              title: 'Interview OpenKnect',
              theme: ThemeData(
                brightness: isDark ? Brightness.dark : Brightness.light,
                primarySwatch: Colors.blue,
                useMaterial3: true,
              ),
              home: const WidgetTree(),
            ),
          );
        });
  }
}
