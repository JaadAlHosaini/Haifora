import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

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
      // Get current user
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) {
        setState(() => isLoading = false);
        return;
      }

      // Get user document from Firestore
      final docSnapshot = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .get();

      if (docSnapshot.exists) {
        setState(() {
          userData = docSnapshot.data();
          isLoading = false;
        });
      } else {
        setState(() {
          userData = null;
          isLoading = false;
        });
      }
    } catch (e) {
      print('Error fetching user data: $e');
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    if (userData == null) {
      return const Scaffold(
        body: Center(child: Text('No profile data found.')),
      );
    }

    final name = userData!['name'] ?? 'No Name';
    final email = userData!['email'] ?? 'No Email';
    final faculty = userData!['faculty'] ?? 'No Faculty';
    final interests = List<String>.from(userData!['interests'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Profile'),
        backgroundColor: Colors.deepPurple,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: fetchUserData, // Reload data manually
          ),
          IconButton(
            icon: const Icon(Icons.logout),
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
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Profile picture placeholder
            const CircleAvatar(
              radius: 60,
              backgroundImage:
              AssetImage('assets/images/default_profile.png'),
            ),
            const SizedBox(height: 16),

            // Name and email
            Text(
              name,
              style:
              const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              email,
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 20),

            // Faculty card
            Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
              child: ListTile(
                leading: const Icon(Icons.school, color: Colors.deepPurple),
                title: Text(faculty),
                subtitle: const Text("Faculty"),
              ),
            ),
            const SizedBox(height: 16),

            // Interests
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Interests",
                style: TextStyle(
                  fontSize: 18,
                  color: Colors.deepPurple.shade700,
                ),
              ),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8,
              children: interests.isNotEmpty
                  ? interests
                  .map(
                    (interest) => Chip(
                  label: Text(interest),
                  backgroundColor: Colors.deepPurple.shade100,
                ),
              )
                  .toList()
                  : [const Text('No interests added')],
            ),
            const SizedBox(height: 20),

            // Edit Profile Button (for later)
            ElevatedButton.icon(
              onPressed: () {
                // TODO: Navigate to Edit Profile screen later
              },
              icon: const Icon(Icons.edit),
              label: const Text("Edit Profile"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.deepPurple,
                padding: const EdgeInsets.symmetric(
                    horizontal: 30, vertical: 12),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
