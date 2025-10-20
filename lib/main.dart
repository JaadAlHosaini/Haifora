import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:haifora/screens/main_nav_screen.dart';
import 'firebase_options.dart';
import 'theme.dart';
import 'router.dart';
import 'screens/welcome_screen.dart';
import 'profile_setup_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  // ✅ Toggle between light and dark themes
  void _toggleTheme() {
    setState(() {
      _themeMode =
      _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Haifora',
      theme: HaiforaTheme.lightTheme,
      darkTheme: HaiforaTheme.darkTheme,
      themeMode: _themeMode,
      debugShowCheckedModeBanner: false,
      onGenerateRoute: generateRoute,
      home: AuthWrapper(
        toggleTheme: _toggleTheme,
        isDarkMode: _themeMode == ThemeMode.dark,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  final VoidCallback toggleTheme;
  final bool isDarkMode;

  const AuthWrapper({
    super.key,
    required this.toggleTheme,
    required this.isDarkMode,
  });

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        // 🌀 While loading
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // 🔐 Not logged in → Welcome screen
        if (!snapshot.hasData) {
          return const WelcomeScreen();
        }

        // ✅ Logged in → Show navigation bar (Dashboard inside it)
        return MainNavScreen(
          onToggleTheme: toggleTheme,
          isDarkMode: isDarkMode,
        );
      },
    );
  }
}
