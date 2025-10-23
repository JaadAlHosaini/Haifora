import 'package:flutter/material.dart';
import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'dashboard_screen.dart';
import 'events_screen.dart';
import 'friends_screen.dart'; // 👈 new file you'll add next
import 'profile_screen.dart';

class MainNavScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const MainNavScreen({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    // 👇 Define main tabs
    final List<Widget> pages = [
      const DashboardScreen(),
      const EventsScreen(),
      const FriendsScreen(), // ✅ replaced Messages
      ProfilePage(
        onToggleTheme: widget.onToggleTheme,
        isDarkMode: widget.isDarkMode,
      ),
    ];

    // 👇 Navigation icons
    final items = <Widget>[
      const Icon(Icons.dashboard, size: 28),
      const Icon(Icons.event, size: 28),
      const Icon(Icons.people, size: 28), // 👈 replaced message icon
      const Icon(Icons.person, size: 28),
    ];

    final theme = Theme.of(context);

    return Scaffold(
      extendBody: true,
      body: pages[_selectedIndex],
      bottomNavigationBar: CurvedNavigationBar(
        index: _selectedIndex,
        items: items,
        height: 60,
        color: theme.colorScheme.primary,
        buttonBackgroundColor: theme.colorScheme.secondary,
        backgroundColor: Colors.transparent,
        animationDuration: const Duration(milliseconds: 300),
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
          });
        },
      ),
    );
  }
}
