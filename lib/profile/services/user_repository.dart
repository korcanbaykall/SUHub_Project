import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_profile.dart';

class UserRepository {
  final FirebaseFirestore _db;

  UserRepository({FirebaseFirestore? db})
      : _db = db ?? FirebaseFirestore.instance;

  Stream<UserProfile> streamProfile(String uid) {
    return _db.collection('users').doc(uid).snapshots().map((doc) {
      final data = doc.data() ?? {};
      return UserProfile.fromMap(data);
    });
  }

  Future<void> updateUsername(String uid, String newUsername) async {
    await _db.collection('users').doc(uid).update({
      'username': newUsername,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateProfilePhoto({
    required String uid,
    required String photoUrl,
    required double photoAlignX,
    required double photoAlignY,
  }) async {
    await _db.collection('users').doc(uid).update({
      'photoUrl': photoUrl,
      'photoAlignX': photoAlignX,
      'photoAlignY': photoAlignY,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

}
