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
  FriendStatus? _friendStatus;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  Future<void> _loadProfile() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      // Load friend profile data
      final friendDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.friendId)
          .get();

      // Get relationship status
      final status = await _friendService.getFriendStatus(widget.friendId);

      setState(() {
        friendData = friendDoc.data();
        _friendStatus = status;
        isLoading = false;
      });
    } catch (e) {
      debugPrint('🔥 Error loading profile: $e');
      setState(() => isLoading = false);
    }
  }

  Future<void> _refreshStatus() async {
    final status = await _friendService.getFriendStatus(widget.friendId);
    setState(() => _friendStatus = status);
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

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
            Text(
              data['name'] ?? 'User',
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(
              '@${data['username'] ?? ''}',
              style: const TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 16),
            _buildFriendButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildFriendButton() {
    if (_friendStatus == null) {
      return const SizedBox.shrink();
    }

    switch (_friendStatus!) {
      case FriendStatus.none:
        return ElevatedButton.icon(
          onPressed: () async {
            await _friendService.sendFriendRequest(widget.friendId);
            await _refreshStatus();
            _showSnackBar('✅ Friend request sent.');
          },
          icon: const Icon(Icons.person_add),
          label: const Text('Add Friend'),
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFF18F01),
          ),
        );

      case FriendStatus.requestSent:
        return OutlinedButton.icon(
          onPressed: () async {
            await _friendService.cancelFriendRequest(widget.friendId);
            await _refreshStatus();
            _showSnackBar('🚫 Friend request canceled.');
          },
          icon: const Icon(Icons.cancel_outlined),
          label: const Text('Cancel Request'),
        );

      case FriendStatus.requestReceived:
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton.icon(
              onPressed: () async {
                // Find request ID
                final requestSnap = await FirebaseFirestore.instance
                    .collection('friend_requests')
                    .where('from', isEqualTo: widget.friendId)
                    .where('to', isEqualTo: _auth.currentUser!.uid)
                    .limit(1)
                    .get();

                if (requestSnap.docs.isNotEmpty) {
                  final requestId = requestSnap.docs.first.id;
                  await _friendService.acceptFriendRequest(requestId, widget.friendId);
                  await _refreshStatus();
                  _showSnackBar('✅ Friend request accepted.');
                }
              },
              icon: const Icon(Icons.check),
              label: const Text('Accept'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
              ),
            ),
            const SizedBox(width: 10),
            OutlinedButton.icon(
              onPressed: () async {
                final requestSnap = await FirebaseFirestore.instance
                    .collection('friend_requests')
                    .where('from', isEqualTo: widget.friendId)
                    .where('to', isEqualTo: _auth.currentUser!.uid)
                    .limit(1)
                    .get();

                if (requestSnap.docs.isNotEmpty) {
                  final requestId = requestSnap.docs.first.id;
                  await _friendService.declineFriendRequest(requestId);
                  await _refreshStatus();
                  _showSnackBar('🚫 Friend request declined.');
                }
              },
              icon: const Icon(Icons.close),
              label: const Text('Decline'),
            ),
          ],
        );

      case FriendStatus.friends:
        return ElevatedButton.icon(
          onPressed: () async {
            await _friendService.removeFriend(widget.friendId);
            await _refreshStatus();
            _showSnackBar('👋 Friend removed.');
          },
          icon: const Icon(Icons.person_remove),
          label: const Text('Remove Friend'),
          style: ElevatedButton.styleFrom(backgroundColor: Colors.redAccent),
        );
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.black87,
      ),
    );
  }
}
