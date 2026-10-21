import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Streams and updates the signed-in user's profile in Cloud Firestore.
/// User identity comes from Firebase Authentication; role permissions come
/// only from trusted Firebase custom claims, never from editable profile fields.
class ProfileRepository {
  ProfileRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  User _requireUser() {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in to access your profile.');
    return user;
  }

  Stream<Map<String, dynamic>?> watchProfile() {
    final user = _requireUser();
    return _firestore.collection('users').doc(user.uid).snapshots().map((doc) {
      final data = doc.data();
      if (data == null) return null;
      return {...data, 'email': user.email ?? data['email'] ?? '', 'authDisplayName': user.displayName ?? ''};
    });
  }

  Future<void> saveProfile({
    required String name,
    required String studentId,
    required String programme,
    required String phone,
  }) async {
    final user = _requireUser();
    final ref = _firestore.collection('users').doc(user.uid);
    final snapshot = await ref.get();
    final current = snapshot.data() ?? <String, dynamic>{};
    await ref.set({
      'uid': user.uid,
      'name': name.trim(),
      'studentId': studentId.trim(),
      'programme': programme.trim(),
      'phone': phone.trim(),
      'email': user.email ?? '',
      'accountType': current['accountType'] ?? 'student',
      'requestedRole': current['requestedRole'] ?? 'student',
      'profileComplete': true,
      'updatedAt': FieldValue.serverTimestamp(),
      if (!snapshot.exists) 'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    await user.updateDisplayName(name.trim());
  }
}
