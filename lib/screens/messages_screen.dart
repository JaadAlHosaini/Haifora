import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/chat_service.dart';
import '../services/friend_service.dart';
import 'chat_room_screen.dart';
import 'notifications_screen.dart';
import 'friend_profile_screen.dart'; // 👈 new screen for viewing friend profiles

class MessagesScreen extends StatefulWidget {
  const MessagesScreen({super.key});

  @override
  State<MessagesScreen> createState() => _MessagesScreenState();
}

class _MessagesScreenState extends State<MessagesScreen> {
  final _auth = FirebaseAuth.instance;
  final ChatService _chatService = ChatService();
  final FriendService _friendService = FriendService();
  final TextEditingController _friendEmailController = TextEditingController();

  List<Map<String, dynamic>> _friends = [];

  @override
  void initState() {
    super.initState();
    _loadFriends();
  }

  Future<void> _loadFriends() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final userDoc =
    await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
    final friendsList = List<String>.from(userDoc.data()?['friends'] ?? []);

    if (friendsList.isEmpty) {
      setState(() => _friends = []);
      return;
    }

    final friendsData = await Future.wait(friendsList.map((uid) async {
      final friendDoc =
      await FirebaseFirestore.instance.collection('users').doc(uid).get();
      return {'uid': uid, ...?friendDoc.data()};
    }));

    setState(() => _friends = friendsData);
  }

  Future<void> _sendFriendRequest() async {
    final email = _friendEmailController.text.trim();
    if (email.isEmpty) return;

    try {
      await _friendService.sendFriendRequest(email);
      _friendEmailController.clear();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Friend request sent!')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  Future<void> _removeFriend(String friendId, String friendName) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Friend'),
        content: Text('Are you sure you want to remove $friendName?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Remove')),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'friends': FieldValue.arrayRemove([friendId])
      });

      await FirebaseFirestore.instance.collection('users').doc(friendId).set({
        'friends': FieldValue.arrayRemove([user.uid])
      }, SetOptions(merge: true));

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('$friendName removed successfully.')),
      );
      _loadFriends();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error removing friend: $e')),
      );
    }
  }

  Future<void> _openChat(String friendId, String friendName) async {
    final chatId = await _chatService.createOrGetChatRoom(friendId);
    if (!mounted) return;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ChatRoomScreen(
          chatId: chatId,
          friendId: friendId,
          friendName: friendName,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Messages'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const NotificationsScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Friend add input
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _friendEmailController,
                    decoration: InputDecoration(
                      hintText: 'Enter friend’s email',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                ElevatedButton(
                  onPressed: _sendFriendRequest,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF18F01),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('Add'),
                ),
              ],
            ),
          ),

          // Friends row
          if (_friends.isNotEmpty)
            SizedBox(
              height: 100,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: _friends.length,
                separatorBuilder: (_, __) => const SizedBox(width: 14),
                itemBuilder: (context, index) {
                  final friend = _friends[index];
                  final photoUrl = friend['photoUrl'] ?? '';
                  final name = friend['name'] ?? 'User';

                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => FriendProfileScreen(friendId: friend['uid']),
                        ),
                      );
                    },
                    onLongPress: () => _removeFriend(friend['uid'], name),
                    child: Column(
                      children: [
                        CircleAvatar(
                          radius: 28,
                          backgroundColor: const Color(0xFFF18F01),
                          backgroundImage:
                          photoUrl.isNotEmpty ? NetworkImage(photoUrl) : null,
                          child: photoUrl.isEmpty
                              ? const Icon(Icons.person, color: Colors.white)
                              : null,
                        ),
                        const SizedBox(height: 6),
                        SizedBox(
                          width: 60,
                          child: Text(
                            name.split(' ').first,
                            overflow: TextOverflow.ellipsis,
                            textAlign: TextAlign.center,
                            style: const TextStyle(fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            )
          else
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 40),
              child: Text(
                'No friends yet — send a request!',
                style: TextStyle(color: Colors.grey),
              ),
            ),

          const Divider(thickness: 1.2, height: 30),

          // Active Chats
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _chatService.getUserChats(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No active chats.'));
                }

                final chats = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: chats.length,
                  itemBuilder: (context, index) {
                    final chat = chats[index].data() as Map<String, dynamic>;
                    final participants =
                    List<String>.from(chat['participants']);
                    final friendId =
                    participants.firstWhere((id) => id != user.uid);

                    return FutureBuilder<DocumentSnapshot>(
                      future: FirebaseFirestore.instance
                          .collection('users')
                          .doc(friendId)
                          .get(),
                      builder: (context, friendSnap) {
                        if (!friendSnap.hasData) {
                          return const ListTile(title: Text('Loading...'));
                        }

                        final friendData =
                        friendSnap.data!.data() as Map<String, dynamic>;
                        final friendName = friendData['name'] ?? 'User';
                        final friendPhoto = friendData['photoUrl'];

                        return ListTile(
                          leading: CircleAvatar(
                            backgroundImage: friendPhoto != null
                                ? NetworkImage(friendPhoto)
                                : null,
                            child: friendPhoto == null
                                ? const Icon(Icons.person)
                                : null,
                          ),
                          title: Text(friendName),
                          subtitle:
                          Text(chat['lastMessage'] ?? '', maxLines: 1),
                          onTap: () => _openChat(friendId, friendName),
                        );
                      },
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
