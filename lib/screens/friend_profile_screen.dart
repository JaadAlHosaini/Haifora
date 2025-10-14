import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/friend_service.dart';
import 'chat_room_screen.dart';

class FriendProfileScreen extends StatefulWidget {
  final String friendId;
  const FriendProfileScreen({super.key, required this.friendId});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final FriendService _friendService = FriendService();

  Map<String, dynamic>? friendData;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadFriendData();
  }

  Future<void> _loadFriendData() async {
    try {
      final doc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();

      setState(() {
        friendData = doc.data();
        isLoading = false;
      });
    } catch (e) {
      debugPrint('Error loading friend: $e');
    }
  }

  Future<void> _startChat() async {
    try {
      final chatId = await _chatService.createOrGetChatRoom(widget.friendId);
      if (!mounted) return;
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => ChatRoomScreen(
            chatId: chatId,
            friendId: widget.friendId,
            friendName: friendData?['name'] ?? 'User',
          ),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening chat: $e')),
      );
    }
  }

  Future<void> _removeFriend() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text(
            'Are you sure you want to remove ${friendData?['name'] ?? 'this user'}?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayRemove([widget.friendId])
      });
      await FirebaseFirestore.instance.collection('users').doc(widget.friendId).update({
        'friends': FieldValue.arrayRemove([user.uid])
      });

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend removed successfully')),
      );
      Navigator.pop(context);
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final photoUrl = friendData?['photoUrl'];
    final name = friendData?['name'] ?? 'Unknown';
    final faculty = friendData?['faculty'] ?? 'Not specified';
    final interests = List<String>.from(friendData?['interests'] ?? []);

    return Scaffold(
      appBar: AppBar(
        title: Text('$name’s Profile'),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: [
            CircleAvatar(
              radius: 60,
              backgroundColor: const Color(0xFFF18F01),
              backgroundImage: photoUrl != null && photoUrl.isNotEmpty
                  ? NetworkImage(photoUrl)
                  : null,
              child: photoUrl == null || photoUrl.isEmpty
                  ? const Icon(Icons.person, size: 60, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(faculty, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            const Divider(),

            // Interests Section
            if (interests.isNotEmpty)
              Wrap(
                spacing: 8,
                runSpacing: 6,
                children: interests
                    .map((interest) => Chip(
                  label: Text(interest),
                  backgroundColor: const Color(0xFFF6AE2D).withOpacity(0.3),
                ))
                    .toList(),
              )
            else
              const Text('No interests listed'),

            const Spacer(),

            // Buttons
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton.icon(
                  onPressed: _startChat,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF5CA4A9),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.chat),
                  label: const Text('Chat'),
                ),
                ElevatedButton.icon(
                  onPressed: _removeFriend,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF18F01),
                    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  icon: const Icon(Icons.person_remove),
                  label: const Text('Remove'),
                ),
              ],
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
