import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FriendService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> sendFriendRequest(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) return;

    await _firestore.collection('friend_requests').add({
      'from': user.uid,
      'to': friendId,
      'timestamp': FieldValue.serverTimestamp(),
    });
  }

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
  }

  Future<void> declineFriendRequest(String requestId) async {
    await _firestore.collection('friend_requests').doc(requestId).delete();
  }

  Future<void> removeFriend(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) {
      print('❌ No logged-in user');
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

      print('✅ Friend successfully removed');
    } catch (e, st) {
      print('🔥 Firestore friend removal error: $e');
      print('📜 Stacktrace: $st');
    }
  }


}
