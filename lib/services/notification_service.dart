import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationService {
  static final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  static final FirebaseAuth _auth = FirebaseAuth.instance;

  static Future<void> addNotification({
    required String message,
    required String type,
    String? buttonText,
    Map<String, dynamic>? extraData,
  }) async {
    final User? currentUser = _auth.currentUser;
    if (currentUser == null) return;

    try {
      await _firestore.collection('notifications').add({
        'userId': currentUser.uid,
        'message': message,
        'type': type,
        'buttonText': buttonText ?? 'View',
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
        ...?extraData,
      });
    } catch (e) {
      print('Error adding notification: $e');
    }
  }
}
