import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// 🔹 Get all chats where the current user is a participant
  Stream<QuerySnapshot> getUserChats() {
    final user = _auth.currentUser;
    if (user == null) return const Stream.empty();

    return _firestore
        .collection('chats')
        .where('participants', arrayContains: user.uid)
        .orderBy('lastUpdated', descending: true)
        .snapshots();
  }

  /// 🔹 Create or return existing chat room
  Future<String> createOrGetChatRoom(String friendId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final chatId = [user.uid, friendId]..sort();
    final chatDocId = chatId.join('_');

    final chatRef = _firestore.collection('chats').doc(chatDocId);
    final chatDoc = await chatRef.get();

    if (!chatDoc.exists) {
      await chatRef.set({
        'participants': [user.uid, friendId],
        'lastMessage': '',
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    }

    return chatDocId;
  }

  /// 🔹 Send a message
  Future<void> sendMessage(String chatId, String text, String receiverId) async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User not authenticated');

    final messageData = {
      'text': text,
      'senderId': user.uid,
      'receiverId': receiverId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(messageData);

    await _firestore.collection('chats').doc(chatId).set({
      'lastMessage': text,
      'lastUpdated': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// 🔹 Stream messages for a given chat
  Stream<QuerySnapshot> getMessages(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots();
  }
}
