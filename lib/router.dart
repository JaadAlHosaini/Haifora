import 'package:flutter/material.dart';

// Import all your screens here
import 'welcome_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart';
import 'home_screen.dart';
import 'profile_page.dart'; // 👈 Add this import

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

  // 👤 Profile Page (your screen)
    case '/profile':
      return MaterialPageRoute(builder: (_) => const ProfilePage());

  // Default → fallback to Welcome
    default:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }
}
