import 'package:flutter/material.dart';

// Import all your screens
import 'screens/welcome_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'edit_profile_page.dart';
import 'screens/main_nav_screen.dart';

Route<dynamic> generateRoute(RouteSettings settings) {
  switch (settings.name) {
  // 🏠 Welcome
    case '/':
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());

  // 🔑 Authentication
    case '/signin':
      return MaterialPageRoute(builder: (_) => const SignInScreen());

    case '/signup':
      return MaterialPageRoute(builder: (_) => const SignUpScreen());

  // 👤 Profile setup after signup
    case '/profileSetup':
      return MaterialPageRoute(builder: (_) => const ProfileSetupScreen());

  // 🏡 Home (using MainNavScreen)
    case '/home':
      return MaterialPageRoute(
        builder: (_) => MainNavScreen(
          onToggleTheme: () {},
          isDarkMode: false,
        ),
      );

  // 👥 Profile page
    case '/profile':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      final onToggleTheme = args['onToggleTheme'] as VoidCallback? ?? () {};
      final isDarkMode = args['isDarkMode'] as bool? ?? false;

      return MaterialPageRoute(
        builder: (_) => ProfilePage(
          onToggleTheme: onToggleTheme,
          isDarkMode: isDarkMode,
        ),
      );

  // ✏️ Edit Profile
    case '/editProfile':
      return MaterialPageRoute(builder: (_) => const EditProfilePage());

  // 🚫 Default fallback (handles ALL unknown routes)
    default:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }
}
