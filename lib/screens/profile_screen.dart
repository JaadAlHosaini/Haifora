import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AppColors {
  static const Color darkNavy = Color(0xFF2C3A47);
  static const Color tealBlue = Color(0xFF5CA4A9);
  static const Color coral = Color(0xFFF18F01);
  static const Color warmYellow = Color(0xFFF6AE2D);
  static const Color beigeBackground = Color(0xFFFAF3E0);
  static const Color darkBackground = Color(0xFF1E1B16);
}

class ProfilePage extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final bool isDarkMode;

  const ProfilePage({
    super.key,
    required this.onToggleTheme,
    required this.isDarkMode,
  });

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      final doc =
      await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

      if (doc.exists) {
        setState(() {
          userData = doc.data();
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text("No profile data found.")),
      );
    }

    final name = userData!['name'] ?? 'No Name';
    final email = userData!['email'] ?? 'No Email';
    final faculty = userData!['faculty'] ?? 'No Faculty';
    final bio = userData!['bio'] ?? 'Write something about yourself...';
    final year = userData!['year'] ?? 'Not specified';
    final interests = List<String>.from(userData!['interests'] ?? []);
    final postsCount = userData!['posts'] ?? 0;
    final eventsCount = userData!['events'] ?? 0;
    final friendsCount = userData!['friends'] ?? 0;

    return Scaffold(
      backgroundColor:
      isDark ? AppColors.darkBackground : AppColors.beigeBackground,
      appBar: AppBar(
        backgroundColor:
        isDark ? AppColors.tealBlue.withOpacity(0.8) : AppColors.coral,
        elevation: 0,
        title: Text(
          "My Profile",
          style: TextStyle(
            color: isDark ? Colors.white : Colors.white,
          ),
        ),
        actions: [
          // 🌗 Theme toggle icon
          IconButton(
            icon: Icon(
              widget.isDarkMode ? Icons.wb_sunny : Icons.nights_stay,
              color: Colors.white,
            ),
            onPressed: widget.onToggleTheme,
            tooltip: widget.isDarkMode
                ? 'Switch to Light Mode'
                : 'Switch to Dark Mode',
          ),
          IconButton(
            icon: const Icon(Icons.refresh, color: Colors.white),
            onPressed: fetchUserData,
          ),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              if (mounted) {
                Navigator.pushReplacementNamed(context, '/signin');
              }
            },
          ),
        ],
      ),

      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔶 Banner with overlapping profile picture
            Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Container(
                  height: 140,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: isDark
                          ? [AppColors.tealBlue, Colors.black54]
                          : [AppColors.coral, AppColors.warmYellow],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -50,
                  child: CircleAvatar(
                    radius: 55,
                    backgroundColor:
                    isDark ? AppColors.darkBackground : Colors.white,
                    child: const CircleAvatar(
                      radius: 50,
                      backgroundImage:
                      AssetImage('assets/images/default_profile.png'),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 60),

            // 🧾 Name, Email, Faculty
            Text(
              name,
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppColors.darkNavy,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(height: 8),
            Text(
              faculty,
              style: TextStyle(
                color: isDark ? AppColors.warmYellow : AppColors.tealBlue,
              ),
            ),

            const SizedBox(height: 16),

            // 📊 Stats
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _buildStat("Posts", postsCount, isDark),
                  _buildStat("Events", eventsCount, isDark),
                  _buildStat("Friends", friendsCount, isDark),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // 💬 Bio
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Card(
                color: isDark ? Colors.grey[900] : Colors.white,
                elevation: 3,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "About Me",
                        style: TextStyle(
                          color:
                          isDark ? AppColors.warmYellow : AppColors.darkNavy,
                          fontSize: 18,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        bio,
                        style: TextStyle(
                          color: isDark ? Colors.white70 : Colors.black87,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        "Year of Study: $year",
                        style: TextStyle(
                          color: isDark ? Colors.grey[400] : Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // 🎯 Interests
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  "Interests",
                  style: TextStyle(
                    fontSize: 18,
                    color: isDark
                        ? AppColors.warmYellow
                        : AppColors.darkNavy.withOpacity(0.9),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              runSpacing: 4,
              children: interests.isNotEmpty
                  ? interests
                  .map(
                    (i) => Chip(
                  label: Text(i),
                  backgroundColor: isDark
                      ? AppColors.tealBlue.withOpacity(0.25)
                      : AppColors.tealBlue.withOpacity(0.15),
                  labelStyle: const TextStyle(color: AppColors.tealBlue),
                ),
              )
                  .toList()
                  : [
                Text(
                  "No interests added",
                  style: TextStyle(
                      color:
                      isDark ? Colors.grey[400] : Colors.grey[800]),
                )
              ],
            ),
            const SizedBox(height: 30),

            // ✏️ Edit Profile Button
            ElevatedButton.icon(
              onPressed: () async {
                final updated =
                await Navigator.pushNamed(context, '/editProfile');
                if (updated == true) {
                  fetchUserData(); // Refresh profile after editing
                }
              },
              icon: const Icon(Icons.edit, color: Colors.white),
              label: const Text(
                "Edit Profile",
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                isDark ? AppColors.tealBlue.withOpacity(0.8) : AppColors.tealBlue,
                padding:
                const EdgeInsets.symmetric(horizontal: 40, vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25)),
              ),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String label, int value, bool isDark) {
    return Column(
      children: [
        Text(
          value.toString(),
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppColors.darkNavy,
            fontSize: 18,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: isDark ? Colors.grey[400] : Colors.grey),
        ),
      ],
    );
  }
}
