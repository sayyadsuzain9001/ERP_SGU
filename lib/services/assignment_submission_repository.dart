import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Assignment files are stored in Firebase Storage and submission metadata in Firestore.
class AssignmentSubmissionRepository {
  AssignmentSubmissionRepository({FirebaseAuth? auth, FirebaseFirestore? firestore, FirebaseStorage? storage})
      : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance,
        _storage = storage ?? FirebaseStorage.instance;

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final FirebaseStorage _storage;

  Future<User> _user() async {
    final user = _auth.currentUser;
    if (user != null) return user;
    final result = await _auth.signInAnonymously();
    final signedIn = result.user;
    if (signedIn == null) throw StateError('Firebase Authentication did not return a user.');
    return signedIn;
  }

  Future<String> submit({required String assignmentTitle, required String courseName, required String fileName, required Uint8List bytes, required String contentType}) async {
    final user = await _user();
    if (bytes.isEmpty) throw ArgumentError('The selected file is empty.');
    if (bytes.length > 10 * 1024 * 1024) throw ArgumentError('Please select a file smaller than 10 MB.');
    final ref = _storage.ref().child('assignmentSubmissions/${user.uid}/${DateTime.now().microsecondsSinceEpoch}_${_safeName(fileName)}');
    final task = await ref.putData(bytes, SettableMetadata(contentType: contentType, customMetadata: {'ownerUid': user.uid}));
    final downloadUrl = await task.ref.getDownloadURL();
    final doc = await _firestore.collection('assignmentSubmissions').add({
      'ownerUid': user.uid,
      'assignmentTitle': assignmentTitle,
      'courseName': courseName,
      'fileName': fileName,
      'storagePath': ref.fullPath,
      'downloadUrl': downloadUrl,
      'sizeBytes': bytes.length,
      'status': 'submitted',
      'submittedAt': FieldValue.serverTimestamp(),
      'createdAt': FieldValue.serverTimestamp(),
    });
    return doc.id;
  }

  String _safeName(String input) => input.replaceAll(RegExp(r'[^A-Za-z0-9._-]'), '_');
}
