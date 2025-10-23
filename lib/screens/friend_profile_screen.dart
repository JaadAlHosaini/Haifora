import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';

class FriendProfileScreen extends StatefulWidget {
  final String friendId;
  const FriendProfileScreen({super.key, required this.friendId});

  @override
  State<FriendProfileScreen> createState() => _FriendProfileScreenState();
}

class _FriendProfileScreenState extends State<FriendProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final FriendService _friendService = FriendService();

  Map<String, dynamic>? friendData;
  bool isFriend = false;
  bool requestSent = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    final friendDoc = await FirebaseFirestore.instance.collection('users').doc(widget.friendId).get();
    final userDoc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();

    final myFriends = List<String>.from(userDoc.data()?['friends'] ?? []);
    final reqSnap = await FirebaseFirestore.instance
        .collection('friend_requests')
        .where('from', isEqualTo: user.uid)
        .where('to', isEqualTo: widget.friendId)
        .limit(1)
        .get();

    setState(() {
      friendData = friendDoc.data();
      isFriend = myFriends.contains(widget.friendId);
      requestSent = reqSnap.docs.isNotEmpty;
      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final data = friendData ?? {};

    return Scaffold(
      appBar: AppBar(title: Text(data['username'] ?? 'Profile')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            CircleAvatar(
              radius: 50,
              backgroundColor: const Color(0xFFF18F01),
              backgroundImage: (data['photoUrl'] ?? '').toString().isNotEmpty
                  ? NetworkImage(data['photoUrl'])
                  : null,
              child: (data['photoUrl'] ?? '').toString().isEmpty
                  ? const Icon(Icons.person, size: 50, color: Colors.white)
                  : null,
            ),
            const SizedBox(height: 10),
            Text(data['name'] ?? 'User', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            Text('@${data['username'] ?? ''}', style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 16),

            if (isFriend)
              ElevatedButton.icon(
                onPressed: () async {
                  await _friendService.removeFriend(widget.friendId);
                  setState(() => isFriend = false);
                },
                icon: const Icon(Icons.person_remove),
                label: const Text('Remove Friend'),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
              )
            else if (requestSent)
              ElevatedButton.icon(
                onPressed: null,
                icon: const Icon(Icons.hourglass_empty),
                label: const Text('Request Sent'),
              )
            else
              ElevatedButton.icon(
                onPressed: () async {
                  await _friendService.sendFriendRequest(widget.friendId);
                  setState(() => requestSent = true);
                },
                icon: const Icon(Icons.person_add),
                label: const Text('Add Friend'),
                style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFF18F01)),
              ),
          ],
        ),
      ),
    );
  }
}
