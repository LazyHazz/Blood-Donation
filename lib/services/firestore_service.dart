import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> addUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(uid).set(userData);
  }

  Future<void> updateUser(String uid, Map<String, dynamic> userData) async {
    await _db.collection('users').doc(uid).update(userData);
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    return await _db.collection('users').doc(uid).get();
  }

  Stream<QuerySnapshot> getUsersStream() {
    return _db.collection('users').snapshots();
  }

  Future<void> addBloodRequest(Map<String, dynamic> requestData) async {
    await _db.collection('blood_requests').add(requestData);
  }

  Stream<QuerySnapshot> getBloodRequestsStream() {
    return _db.collection('blood_requests').snapshots();
  }

  Future<void> addMessage(Map<String, dynamic> messageData) async {
    await _db.collection('messages').add(messageData);
  }

  Stream<QuerySnapshot> getMessagesStream() {
    return _db.collection('messages').snapshots();
  }
}
