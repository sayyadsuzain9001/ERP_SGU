import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CampusRequestRepository {
  CampusRequestRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
    : _authOverride = auth,
      _firestoreOverride = firestore;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore =>
      _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _requests =>
      _firestore.collection('campusRequests');

  DocumentReference<Map<String, dynamic>> newRequestReference() =>
      _requests.doc();

  Future<User> _signedInUser() async {
    final currentUser = _auth.currentUser;
    if (currentUser != null) return currentUser;
    final credential = await _auth.signInAnonymously();
    final user = credential.user;
    if (user == null) throw StateError('Anonymous sign-in did not complete.');
    return user;
  }

  Future<void> submit({
    required DocumentReference<Map<String, dynamic>> reference,
    required String studentName,
    required String studentId,
    required String email,
    required String phone,
    required String serviceCategory,
    required String subject,
    required String description,
    required String urgency,
    required String preferredContact,
    required DateTime preferredDate,
  }) async {
    final user = await _signedInUser();
    await reference.set({
      'ownerUid': user.uid,
      'studentName': studentName.trim(),
      'studentId': studentId.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'serviceCategory': serviceCategory,
      'subject': subject.trim(),
      'description': description.trim(),
      'urgency': urgency,
      'preferredContact': preferredContact,
      // Store midnight in the campus timezone (Asia/Kolkata) as a Firestore timestamp.
      'preferredDate': Timestamp.fromDate(
        DateTime.utc(
          preferredDate.year,
          preferredDate.month,
          preferredDate.day,
        ).subtract(const Duration(hours: 5, minutes: 30)),
      ),
      'declaration': true,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  Future<Map<String, dynamic>?> fetchFromServer(String requestId) async {
    final user = await _signedInUser();
    final snapshot = await _requests
        .doc(requestId)
        .get(const GetOptions(source: Source.server));
    final data = snapshot.data();
    if (!snapshot.exists || data == null || data['ownerUid'] != user.uid) {
      return null;
    }
    return data;
  }
}
