import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'home_screen.dart';

class AppRouter {
  static Route<dynamic> generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        return MaterialPageRoute(builder: (_) => const WelcomeScreen());
      case '/signin':
        return MaterialPageRoute(builder: (_) => const SignInScreen());
      case '/signup':
        return MaterialPageRoute(builder: (_) => const SignUpScreen());
      case '/home':
        return MaterialPageRoute(
          builder: (_) => HomeScreen(
            onToggleTheme: () {}, // temporary empty function
            isDarkMode: false,    // default theme state
          ),
        );
      default:
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(
              child: Text('404 — Page Not Found'),
            ),
          ),
        );
    }
  }
}
