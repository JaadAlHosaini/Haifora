import 'package:flutter/material.dart';

// Import all your screens here
import 'screens/welcome_screen.dart';
import 'signin_screen.dart';
import 'signup_screen.dart';
import 'profile_setup_screen.dart';
import 'screens/home_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dashboard_screen.dart'; // ✅ Dashboard
import 'screens/events_screen.dart';    // ✅ Events
import 'screens/messages_screen.dart';  // ✅ Added Messages
import 'screens/chat_room_screen.dart'; // ✅ Added Chat Room
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

  // 🏡 Home
    case '/home':
      return MaterialPageRoute(
        builder: (_) => HomeScreen(
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

  // ✏️ Edit Profile page
    case '/editProfile':
      return MaterialPageRoute(builder: (_) => const EditProfilePage());

  // 💬 Messages page
    case '/messages':
      return MaterialPageRoute(builder: (_) => const MessagesScreen());

  // 💭 Chat room (takes arguments)
    case '/chatRoom':
      final args = settings.arguments as Map<String, dynamic>? ?? {};
      final friendId = args['friendId'] as String? ?? '';
      final friendName = args['friendName'] as String? ?? 'Chat';
      return MaterialPageRoute(
        builder: (_) => ChatRoomScreen(friendId: friendId, friendName: friendName),
      );

  // 🚫 Default fallback
    default:
      return MaterialPageRoute(builder: (_) => const WelcomeScreen());
  }
}
