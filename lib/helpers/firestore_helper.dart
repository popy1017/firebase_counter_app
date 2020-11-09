import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreHelper {
  FirestoreHelper._internal();

  static final FirestoreHelper _instance = FirestoreHelper._internal();

  static final CollectionReference _counters =
      FirebaseFirestore.instance.collection('counters');

  static FirestoreHelper get instance => _instance;

  Stream<DocumentSnapshot> getStream(String userId) =>
      _counters.doc(userId).snapshots();

  Future<bool> _hasCounter(String userId) async {
    final DocumentSnapshot snapshot = await fetchCounter(userId);
    if (snapshot == null ||
        snapshot.data() == null ||
        snapshot.data()['count'] == null) {
      return false;
    }
    return true;
  }

  Future<DocumentSnapshot> fetchCounter(String userId) async {
    return await _counters.doc(userId).get();
  }

  Future<bool> createCounter(String userId) async {
    try {
      // 既にカウンターがある場合は何もしないで終了
      if (await _hasCounter(userId)) {
        return true;
      }
      await _counters.doc(userId).set({'count': 0});
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }

  Future<bool> updateCounter(String userId, int count) async {
    try {
      await _counters.doc(userId).update({'count': count});
    } catch (error) {
      print(error);
      return false;
    }
    return true;
  }
}
