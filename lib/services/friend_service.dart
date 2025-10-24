import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

enum FriendStatus {
  none,        // no connection
  friends,     // both are friends
  requestSent, // current user sent a request
  requestReceived, // current user received a request
}

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// 🚀 Send a friend request
  Future<void> sendFriendRequest(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    if (friendId == user.uid) {
      debugPrint('❌ You cannot send a friend request to yourself.');
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final friendRef = _firestore.collection('users').doc(friendId);

    final userSnap = await userRef.get();
    final friendSnap = await friendRef.get();

    if (!userSnap.exists || !friendSnap.exists) {
      debugPrint('❌ One of the users does not exist.');
      return;
    }

    final userFriends = List<String>.from(userSnap.data()?['friends'] ?? []);
    if (userFriends.contains(friendId)) {
      debugPrint('⚠️ Already friends.');
      return;
    }

    final existingRequests = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: user.uid)
        .where('to', isEqualTo: friendId)
        .get();

    final reverseRequests = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: friendId)
        .where('to', isEqualTo: user.uid)
        .get();

    if (existingRequests.docs.isNotEmpty || reverseRequests.docs.isNotEmpty) {
      debugPrint('⚠️ Friend request already sent or pending.');
      return;
    }

    await _firestore.collection('friend_requests').add({
      'from': user.uid,
      'to': friendId,
      'timestamp': FieldValue.serverTimestamp(),
    });

    debugPrint('✅ Friend request sent successfully.');
  }

  /// 🔙 Cancel a sent friend request
  Future<void> cancelFriendRequest(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final snapshot = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: user.uid)
        .where('to', isEqualTo: friendId)
        .get();

    if (snapshot.docs.isEmpty) {
      debugPrint('⚠️ No sent friend request found to cancel.');
      return;
    }

    for (final doc in snapshot.docs) {
      await _firestore.collection('friend_requests').doc(doc.id).delete();
    }

    debugPrint('🚫 Friend request canceled.');
  }

  /// 🤝 Accept a friend request
  Future<void> acceptFriendRequest(String requestId, String fromId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    final batch = _firestore.batch();
    final userRef = _firestore.collection('users').doc(user.uid);
    final fromRef = _firestore.collection('users').doc(fromId);

    batch.update(userRef, {'friends': FieldValue.arrayUnion([fromId])});
    batch.update(fromRef, {'friends': FieldValue.arrayUnion([user.uid])});
    batch.delete(_firestore.collection('friend_requests').doc(requestId));

    await batch.commit();
    debugPrint('✅ Friend request accepted.');
  }

  /// 🚫 Decline a friend request
  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
    debugPrint('🚫 Friend request declined.');
  }

  /// 🧹 Remove an existing friend (both sides)
  Future<void> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) {
      debugPrint('❌ No logged-in user');
      return;
    }

    final userRef = _firestore.collection('users').doc(user.uid);
    final friendRef = _firestore.collection('users').doc(friendId);

    try {
      await _firestore.runTransaction((txn) async {
        final userDoc = await txn.get(userRef);
        final friendDoc = await txn.get(friendRef);

        if (!userDoc.exists) throw Exception("❌ Current user document not found");
        if (!friendDoc.exists) throw Exception("❌ Friend document not found");

        final userFriends = List<String>.from(userDoc.data()?['friends'] ?? []);
        final friendFriends = List<String>.from(friendDoc.data()?['friends'] ?? []);

        userFriends.remove(friendId);
        friendFriends.remove(user.uid);

        txn.update(userRef, {'friends': userFriends});
        txn.update(friendRef, {'friends': friendFriends});
      });

      debugPrint('✅ Friend successfully removed');
    } catch (e, st) {
      debugPrint('🔥 Firestore friend removal error: $e');
      debugPrint('📜 Stacktrace: $st');
    }
  }

  /// 🧭 Check friendship / request status between current user and another user
  Future<FriendStatus> getFriendStatus(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return FriendStatus.none;

    final userRef = _firestore.collection('users').doc(user.uid);
    final userSnap = await userRef.get();

    if (!userSnap.exists) return FriendStatus.none;

    // 1️⃣ Check if already friends
    final friends = List<String>.from(userSnap.data()?['friends'] ?? []);
    if (friends.contains(friendId)) {
      return FriendStatus.friends;
    }

    // 2️⃣ Check for outgoing (sent) request
    final sentRequest = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: user.uid)
        .where('to', isEqualTo: friendId)
        .limit(1)
        .get();

    if (sentRequest.docs.isNotEmpty) {
      return FriendStatus.requestSent;
    }

    // 3️⃣ Check for incoming (received) request
    final receivedRequest = await _firestore
        .collection('friend_requests')
        .where('from', isEqualTo: friendId)
        .where('to', isEqualTo: user.uid)
        .limit(1)
        .get();

    if (receivedRequest.docs.isNotEmpty) {
      return FriendStatus.requestReceived;
    }

    // 4️⃣ No relationship
    return FriendStatus.none;
  }
}
