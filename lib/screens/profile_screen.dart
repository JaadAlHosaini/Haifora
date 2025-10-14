import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  final String? userId; // null = current user

  const ProfileScreen({super.key, this.userId});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic>? userData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUserData();
  }

  Future<void> fetchUserData() async {
    final currentUser = FirebaseAuth.instance.currentUser!;
    final docId = widget.userId ?? currentUser.uid;

    final doc =
    await FirebaseFirestore.instance.collection('users').doc(docId).get();

    if (mounted) {
      setState(() {
        userData = doc.data();
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isCurrentUser =
        widget.userId == null ||
            widget.userId == FirebaseAuth.instance.currentUser!.uid;

    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(isCurrentUser ? "My Profile" : "User Profile"),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : userData == null
          ? const Center(child: Text("User not found"))
          : Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 50,
              backgroundImage: userData!['photoUrl'] != null &&
                  userData!['photoUrl'].isNotEmpty
                  ? NetworkImage(userData!['photoUrl'])
                  : null,
              backgroundColor: Colors.orangeAccent,
              child: (userData!['photoUrl'] == null ||
                  userData!['photoUrl'].isEmpty)
                  ? Text(
                userData!['name']?[0].toUpperCase() ?? '?',
                style: const TextStyle(
                    fontSize: 32, color: Colors.white),
              )
                  : null,
            ),
            const SizedBox(height: 20),
            Text(
              userData!['name'] ?? 'Unknown User',
              style: theme.textTheme.headlineSmall
                  ?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              userData!['email'] ?? '',
              style: theme.textTheme.bodyMedium
                  ?.copyWith(color: Colors.grey[700]),
            ),
            const SizedBox(height: 16),
            if (userData!['faculty'] != null)
              Text(
                "Faculty: ${userData!['faculty']}",
                style: theme.textTheme.bodyLarge,
              ),
            if (userData!['year'] != null)
              Text(
                "Year: ${userData!['year']}",
                style: theme.textTheme.bodyLarge,
              ),
            const SizedBox(height: 20),
            if (userData!['interests'] != null)
              Wrap(
                spacing: 8,
                children: List<String>.from(userData!['interests'])
                    .map((interest) => Chip(
                  label: Text(interest),
                  backgroundColor: Colors.orange.shade100,
                ))
                    .toList(),
              ),
            const SizedBox(height: 24),
            if (isCurrentUser)
              ElevatedButton.icon(
                icon: const Icon(Icons.edit),
                label: const Text("Edit Profile"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFF18F01),
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  Navigator.pushNamed(context, '/editProfile');
                },
              ),
          ],
        ),
      ),
    );
  }
}
