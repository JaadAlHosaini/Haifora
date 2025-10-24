import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';
import 'chat_room_screen.dart';
import 'friend_profile_screen.dart';

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _auth = FirebaseAuth.instance;
  final FriendService _friendService = FriendService();

  List<Map<String, dynamic>> _friends = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  /// 🔹 Load all friends for the current user
  Future<void> _loadFriends() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final friendIds = List<String>.from(userDoc.data()?['friends'] ?? []);

      if (friendIds.isEmpty) {
        setState(() {
          _friends = [];
          _isLoading = false;
        });
        return;
      }

      // Fetch friend user data
      final friendDocs = await FirebaseFirestore.instance
          .collection('users')
          .where(FieldPath.documentId, whereIn: friendIds)
          .get();

      setState(() {
        _friends = friendDocs.docs.map((doc) {
          final data = doc.data();
          data['uid'] = doc.id;
          return data;
        }).toList();
        _isLoading = false;
      });
    } catch (e) {
      debugPrint('🔥 Error loading friends: $e');
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadFriends,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _friends.isEmpty
          ? const Center(
        child: Text('No friends yet — add some to start chatting!'),
      )
          : ListView.builder(
        itemCount: _friends.length,
        itemBuilder: (context, index) {
          final friend = _friends[index];
          return ListTile(
            leading: CircleAvatar(
              radius: 25,
              backgroundColor: const Color(0xFFF18F01),
              backgroundImage: (friend['photoUrl'] ?? '').toString().isNotEmpty
                  ? NetworkImage(friend['photoUrl'])
                  : null,
              child: (friend['photoUrl'] ?? '').toString().isEmpty
                  ? const Icon(Icons.person, color: Colors.white)
                  : null,
            ),
            title: Text(friend['name'] ?? 'User'),
            subtitle: Text('@${friend['username'] ?? ''}'),
            trailing: ElevatedButton.icon(
              icon: const Icon(Icons.chat_bubble_outline, size: 18),
              label: const Text('Chat'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFF18F01),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              ),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => ChatRoomScreen(
                      friendId: friend['uid'],
                      friendName: friend['name'] ?? 'User',
                    ),
                  ),
                );
              },
            ),
          );

        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          // Placeholder: later can open "Find Friends" or "Start Chat"
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Friend search coming soon!')),
          );
        },
        backgroundColor: const Color(0xFFF18F01),
        child: const Icon(Icons.message, color: Colors.white),
      ),
    );
  }
}
