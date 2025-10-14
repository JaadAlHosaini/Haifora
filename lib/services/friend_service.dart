import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final _db = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;

  /// Send a friend request
  Future<void> sendFriendRequest(String friendEmail) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // find user by email
    final friendQuery = await _db.collection('users')
        .where('email', isEqualTo: friendEmail)
        .limit(1)
        .get();

    if (friendQuery.docs.isEmpty) {
      throw Exception('No user found with that email.');
    }

    final friendId = friendQuery.docs.first.id;
    if (friendId == user.uid) throw Exception('Cannot add yourself.');

    // create a request in the friend's collection
    await _db.collection('users').doc(friendId)
        .collection('friend_requests')
        .doc(user.uid)
        .set({
      'fromId': user.uid,
      'fromName': user.displayName ?? 'Unknown User',
      'timestamp': FieldValue.serverTimestamp(),
    });

    // add notification for the friend
    await _db.collection('users').doc(friendId)
        .collection('notifications')
        .add({
      'type': 'friend_request',
      'fromId': user.uid,
      'fromName': user.displayName ?? 'Unknown User',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Accept a friend request
  Future<void> acceptFriendRequest(String fromId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    // add each other to friends list
    await _db.collection('users').doc(user.uid).update({
      'friends': FieldValue.arrayUnion([fromId])
    });

    await _db.collection('users').doc(fromId).update({
      'friends': FieldValue.arrayUnion([user.uid])
    });

    // delete the friend request
    await _db.collection('users').doc(user.uid)
        .collection('friend_requests').doc(fromId).delete();

    // create notification for sender
    await _db.collection('users').doc(fromId)
        .collection('notifications')
        .add({
      'type': 'friend_accept',
      'fromId': user.uid,
      'fromName': user.displayName ?? 'Unknown User',
      'timestamp': FieldValue.serverTimestamp(),
      'isRead': false,
    });
  }

  /// Decline friend request
  Future<void> declineFriendRequest(String fromId) async {
    final user = _auth.currentUser;
    if (user == null) return;
    await _db.collection('users').doc(user.uid)
        .collection('friend_requests').doc(fromId).delete();
  }
}
