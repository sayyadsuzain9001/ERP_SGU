import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Shared persistence layer for form submissions across the SGU ERP.
/// Each screen stores its data in one collection with a module discriminator.
class FormSubmissionRepository {
  FormSubmissionRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _authOverride = auth,
        _firestoreOverride = firestore;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _collection =>
      _firestore.collection('formSubmissions');

  Future<User> _ensureUser() async {
    final existing = _auth.currentUser;
    if (existing != null) return existing;
    final result = await _auth.signInAnonymously();
    final user = result.user;
    if (user == null) throw StateError('Firebase sign-in did not return a user.');
    return user;
  }

  Future<String> submit({
    required String module,
    required String title,
    required String description,
    required Map<String, dynamic> fields,
  }) async {
    final user = await _ensureUser();
    final claims = (await user.getIdTokenResult()).claims ?? const <String, dynamic>{};
    final trustedRole = claims['role'];
    final ref = _collection.doc();
    await ref.set({
      'ownerUid': user.uid,
      'module': module,
      // Never trust the UI-selected role for stored identity metadata.
      'role': trustedRole == 'admin' || trustedRole == 'teacher' ? trustedRole : 'student',
      'title': title.trim(),
      'description': description.trim(),
      'fields': fields,
      'status': 'submitted',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
      'schemaVersion': 1,
    });

    // Do not report success until the server confirms that the document exists.
    // This works the same when the Flutter Web app is hosted on GitHub Pages.
    final verified = await ref.get(const GetOptions(source: Source.server));
    if (!verified.exists || verified.data()?['ownerUid'] != user.uid) {
      throw StateError('The submission was saved but could not be verified from Firestore.');
    }
    return ref.id;
  }

  Future<void> update({required String id, required Map<String, dynamic> changes}) async {
    final user = await _ensureUser();
    final ref = _collection.doc(id);
    final snap = await ref.get();
    final claims = (await user.getIdTokenResult()).claims ?? const <String, dynamic>{};
    final staff = claims['role'] == 'admin' || claims['role'] == 'teacher';
    if (!snap.exists || (snap.data()?['ownerUid'] != user.uid && !staff)) {
      throw StateError('You do not have permission to edit this submission.');
    }
    await ref.update({...changes, 'updatedAt': FieldValue.serverTimestamp()});
  }

  Future<void> delete({required String id}) async {
    final user = await _ensureUser();
    final ref = _collection.doc(id);
    final snap = await ref.get();
    final claims = (await user.getIdTokenResult()).claims ?? const <String, dynamic>{};
    final staff = claims['role'] == 'admin';
    if (!snap.exists || (snap.data()?['ownerUid'] != user.uid && !staff)) {
      throw StateError('You do not have permission to delete this submission.');
    }
    await ref.delete();
  }

  Stream<QuerySnapshot<Map<String, dynamic>>> watchMine({String? module}) async* {
    final user = await _ensureUser();
    final claims = (await user.getIdTokenResult()).claims ?? const <String, dynamic>{};
    final role = claims['role'];
    final staff = role == 'admin' || role == 'teacher';

    // Query Firestore itself (not a local mock list). Module filtering happens
    // on the server, and students are restricted to their own UID. snapshots()
    // keeps this list live when documents change in Firebase Console or another client.
    Query<Map<String, dynamic>> query = _collection;
    if (module != null && module.isNotEmpty) {
      query = query.where('module', isEqualTo: module);
    }
    if (!staff) {
      query = query.where('ownerUid', isEqualTo: user.uid);
    }
    yield* query.snapshots();
  }
}
