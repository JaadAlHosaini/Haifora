import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/friend_service.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final _auth = FirebaseAuth.instance;
  final _friendService = FriendService();

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const Scaffold(body: Center(child: Text('Not logged in.')));
    }

    final requestsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('friend_requests')
        .snapshots();

    final notificationsStream = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('notifications')
        .snapshots();

    return Scaffold(
      appBar: AppBar(title: const Text('Notifications')),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: requestsStream,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return const CircularProgressIndicator();
                final requests = snapshot.data!.docs;

                return ListView(
                  children: [
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Friend Requests',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    ...requests.map((req) {
                      final data = req.data();
                      final fromId = req.id;
                      final fromName = data['fromName'] ?? 'Someone';
                      return ListTile(
                        title: Text('$fromName sent you a friend request'),
                        trailing: Wrap(
                          children: [
                            IconButton(
                              icon: const Icon(Icons.check, color: Colors.green),
                              onPressed: () => _friendService.acceptFriendRequest(fromId),
                            ),
                            IconButton(
                              icon: const Icon(Icons.close, color: Colors.red),
                              onPressed: () => _friendService.declineFriendRequest(fromId),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const Divider(),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text('Other Notifications',
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ),
                    StreamBuilder(
                      stream: notificationsStream,
                      builder: (context, noteSnap) {
                        if (!noteSnap.hasData) return const SizedBox();
                        final notes = noteSnap.data!.docs;
                        return Column(
                          children: notes.map((note) {
                            final data = note.data() as Map<String, dynamic>;
                            final type = data['type'] ?? 'other';
                            final fromName = data['fromName'] ?? 'User';
                            String message;
                            if (type == 'message') {
                              message = 'New message from $fromName';
                            } else if (type == 'friend_accept') {
                              message = '$fromName accepted your request';
                            } else {
                              message = '$fromName sent something';
                            }
                            return ListTile(
                              leading: const Icon(Icons.notifications),
                              title: Text(message),
                            );
                          }).toList(),
                        );
                      },
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
