import 'package:flutter/material.dart';
import 'package:flutter_interview/app_theme.dart';
import 'package:flutter_interview/core/notifiers.dart';
import 'package:flutter_interview/providers/theme_provider.dart';
import 'package:flutter_interview/widget_tree.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:hooks_riverpod/hooks_riverpod.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const ProviderScope(child: MyApp()));
}

final isDarkProvider = StateProvider<bool>((ref) => false);

class MyApp extends HookConsumerWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final appThemeState = ref.watch(appThemeStateNotifier);

    return ValueListenableBuilder(
      valueListenable: isDarkModeNotifier,
      builder: (context, isDark, child) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Interview OpenKnect',
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: appThemeState.isDarkModeEnabled
              ? ThemeMode.dark
              : ThemeMode.light,
          home: const WidgetTree(),
        );
      },
    );
  }
}
