import 'package:flutter/material.dart';
import 'welcome_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
    case '/signin':
      return MaterialPageRoute(builder: (_) => const SignInScreen());
    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignUpScreen());
    case '/profileSetup':
      return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());
    case '/home':
      return MaterialPageRoute(
        builder: (_) => HomeScreen(
          onToggleTheme: () {},
          isDarkMode: false,
        ),
      );
    default:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }
}
