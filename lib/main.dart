import 'package:flutter/material.dart';
import 'theme.dart';
import 'home_screen.dart';

void main() {
  runApp(const HaiforaApp());
}

class HaiforaApp extends StatelessWidget {
  const HaiforaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haifora',
      debugShowCheckedModeBanner: false,
      theme: HaiforaTheme.lightTheme,
      darkTheme: HaiforaTheme.darkTheme,
      themeMode: ThemeMode.system, // Automatically switches based on system mode
      home: const HomeScreen(),
    );
  }
}
