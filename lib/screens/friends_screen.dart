import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import 'friend_profile_screen.dart';

class FriendsScreen extends StatefulWidget {
  const FriendsScreen({super.key});

  @override
  State<FriendsScreen> createState() => _FriendsScreenState();
}

class _FriendsScreenState extends State<FriendsScreen> {
  final _auth = FirebaseAuth.instance;
  final FriendService _friendService = FriendService();
  final TextEditingController _searchController = TextEditingController();

  String searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Center(child: Text('Please log in.'));
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Friends'),
        centerTitle: true,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance.collection('users').doc(user.uid).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) return const Center(child: CircularProgressIndicator());
          final userData = snapshot.data!.data() as Map<String, dynamic>? ?? {};
          final List<String> friends = List<String>.from(userData['friends'] ?? []);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    labelText: 'Search by username',
                    suffixIcon: IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: () {
                        setState(() {
                          searchQuery = _searchController.text.trim();
                        });
                      },
                    ),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                ),
                const SizedBox(height: 20),

                // Friend requests
                _buildFriendRequests(),

                const SizedBox(height: 25),

                // Friends list
                Text('Your Friends',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),

                if (friends.isEmpty)
                  const Text('You have no friends yet.')
                else
                  FutureBuilder<List<DocumentSnapshot>>(
                    future: Future.wait(friends
                        .map((id) => FirebaseFirestore.instance.collection('users').doc(id).get())),
                    builder: (context, snap) {
                      if (!snap.hasData) return const Center(child: CircularProgressIndicator());
                      final docs = snap.data!;
                      return Column(
                        children: docs.map((doc) {
                          final friend = doc.data() as Map<String, dynamic>? ?? {};
                          return ListTile(
                            leading: CircleAvatar(
                              backgroundImage: (friend['photoUrl'] ?? '').toString().isNotEmpty
                                  ? NetworkImage(friend['photoUrl'])
                                  : null,
                              child: (friend['photoUrl'] ?? '').toString().isEmpty
                                  ? const Icon(Icons.person, color: Colors.white)
                                  : null,
                            ),
                            title: Text(friend['username'] ?? 'User'),
                            subtitle: Text(friend['faculty'] ?? ''),
                            trailing: IconButton(
                              icon: const Icon(Icons.person_remove, color: Colors.redAccent),
                              onPressed: () async {
                                await _friendService.removeFriend(doc.id);
                              },
                            ),
                            onTap: () => Navigator.push(
                              context,
                              MaterialPageRoute(builder: (_) => FriendProfileScreen(friendId: doc.id)),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                const SizedBox(height: 25),

                // Search results
                if (searchQuery.isNotEmpty) _buildSearchResults(),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFriendRequests() {
    final user = _auth.currentUser;
    if (user == null) return const SizedBox();

    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('friend_requests')
          .where('to', isEqualTo: user.uid)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final requests = snapshot.data!.docs;
        if (requests.isEmpty) return const SizedBox();

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Friend Requests',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
            const SizedBox(height: 10),
            ...requests.map((req) {
              final data = req.data() as Map<String, dynamic>;
              return FutureBuilder<DocumentSnapshot>(
                future: FirebaseFirestore.instance.collection('users').doc(data['from']).get(),
                builder: (context, snap) {
                  if (!snap.hasData) return const SizedBox();
                  final fromUser = snap.data!.data() as Map<String, dynamic>? ?? {};
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundImage: (fromUser['photoUrl'] ?? '').toString().isNotEmpty
                          ? NetworkImage(fromUser['photoUrl'])
                          : null,
                      child: (fromUser['photoUrl'] ?? '').toString().isEmpty
                          ? const Icon(Icons.person, color: Colors.white)
                          : null,
                    ),
                    title: Text(fromUser['username'] ?? 'User'),
                    subtitle: const Text('sent you a friend request'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.check_circle, color: Colors.green),
                          onPressed: () async => await _friendService.acceptFriendRequest(req.id, data['from']),
                        ),
                        IconButton(
                          icon: const Icon(Icons.cancel, color: Colors.redAccent),
                          onPressed: () async => await _friendService.declineFriendRequest(req.id),
                        ),
                      ],
                    ),
                  );
                },
              );
            }),
          ],
        );
      },
    );
  }

  Widget _buildSearchResults() {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance
          .collection('users')
          .where('username', isEqualTo: searchQuery)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) return const SizedBox();
        final results = snapshot.data!.docs;
        if (results.isEmpty) return const Text('No user found.');

        return Column(
          children: results.map((doc) {
            final user = doc.data() as Map<String, dynamic>? ?? {};
            return ListTile(
              leading: CircleAvatar(
                backgroundImage: (user['photoUrl'] ?? '').toString().isNotEmpty
                    ? NetworkImage(user['photoUrl'])
                    : null,
                child: (user['photoUrl'] ?? '').toString().isEmpty
                    ? const Icon(Icons.person, color: Colors.white)
                    : null,
              ),
              title: Text(user['username'] ?? 'User'),
              subtitle: Text(user['faculty'] ?? ''),
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => FriendProfileScreen(friendId: doc.id)),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}
