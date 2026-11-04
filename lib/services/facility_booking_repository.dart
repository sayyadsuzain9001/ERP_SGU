import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../models/facility_booking.dart';

/// Firestore access for the Facility Booking & Confirmation workflow.
///
/// * `facilityBookings` holds the full request (personal details included) and
///   is readable only by its owner and admins.
/// * `facilityAvailability` holds only facility id + time window for every
///   active (pending or approved) booking, keyed by booking id, so any
///   signed-in student can check for clashes without seeing other students'
///   personal data. It is written in the same batch as the booking change.
class FacilityBookingRepository {
  FacilityBookingRepository({FirebaseAuth? auth, FirebaseFirestore? firestore})
      : _authOverride = auth,
        _firestoreOverride = firestore;

  final FirebaseAuth? _authOverride;
  final FirebaseFirestore? _firestoreOverride;

  FirebaseAuth get _auth => _authOverride ?? FirebaseAuth.instance;
  FirebaseFirestore get _firestore => _firestoreOverride ?? FirebaseFirestore.instance;

  CollectionReference<Map<String, dynamic>> get _bookings => _firestore.collection('facilityBookings');
  CollectionReference<Map<String, dynamic>> get _availability => _firestore.collection('facilityAvailability');

  User get _user {
    final user = _auth.currentUser;
    if (user == null) throw StateError('Please sign in to continue.');
    return user;
  }

  static List<FacilityBookingRequest> _sorted(QuerySnapshot<Map<String, dynamic>> snapshot, {bool newestFirst = true}) {
    final list = snapshot.docs.map(FacilityBookingRequest.fromDoc).toList();
    list.sort((a, b) {
      final ac = a.createdAt ?? a.startAt;
      final bc = b.createdAt ?? b.startAt;
      return newestFirst ? bc.compareTo(ac) : ac.compareTo(bc);
    });
    return list;
  }

  /// The signed-in student's own requests, newest first.
  Stream<List<FacilityBookingRequest>> watchMyBookings() {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return Stream.value(const []);
    return _bookings.where('ownerUid', isEqualTo: uid).snapshots().map(_sorted);
  }

  /// Every request (admin only; enforced by Firestore rules).
  Stream<List<FacilityBookingRequest>> watchAllBookings() =>
      _bookings.snapshots().map(_sorted);

  static List<BookingSlot> _slots(QuerySnapshot<Map<String, dynamic>> snapshot, {String? excludeId}) => snapshot.docs
      .where((doc) => doc.id != excludeId)
      .map((doc) => doc.data())
      .where((d) => d['startAt'] is Timestamp && d['endAt'] is Timestamp)
      .map((d) => (
            facilityId: (d['facilityId'] ?? '').toString(),
            start: (d['startAt'] as Timestamp).toDate(),
            end: (d['endAt'] as Timestamp).toDate(),
          ))
      .toList()
    ..sort((a, b) => a.start.compareTo(b.start));

  /// Booked (pending or approved) time windows for every facility.
  Stream<List<BookingSlot>> watchBookedSlots() => _availability.snapshots().map(_slots);

  /// Booked windows for [facilityId], always read from the server so the final
  /// check before saving sees bookings made on other devices.
  Future<List<BookingSlot>> fetchBookedSlots(String facilityId, {String? excludeBookingId}) async {
    final snapshot = await _availability
        .where('facilityId', isEqualTo: facilityId)
        .get(const GetOptions(source: Source.server));
    return _slots(snapshot, excludeId: excludeBookingId);
  }

  Map<String, dynamic> _slotDoc(String ownerUid, String facilityId, DateTime start, DateTime end) => {
        'ownerUid': ownerUid,
        'facilityId': facilityId,
        'startAt': Timestamp.fromDate(start),
        'endAt': Timestamp.fromDate(end),
        'updatedAt': FieldValue.serverTimestamp(),
      };

  Future<String> submit({
    required String applicantName,
    required String studentId,
    required String programme,
    required String email,
    required String phone,
    required Facility facility,
    required String eventTitle,
    required String activityType,
    required String purpose,
    required DateTime startAt,
    required DateTime endAt,
    required int attendees,
    required String coordinatorName,
    required List<String> equipment,
    required String specialRequirements,
  }) async {
    final user = _user;
    if (hasConflict(facility.id, startAt, endAt, await fetchBookedSlots(facility.id))) {
      throw StateError('Facility already booked: ${facility.name} was just booked by someone else. Please choose another time.');
    }
    final ref = _bookings.doc();
    final batch = _firestore.batch();
    batch.set(ref, {
      'ownerUid': user.uid,
      'applicantName': applicantName.trim(),
      'studentId': studentId.trim(),
      'programme': programme.trim(),
      'email': email.trim(),
      'phone': phone.trim(),
      'facilityId': facility.id,
      'facilityName': facility.name,
      'eventTitle': eventTitle.trim(),
      'activityType': activityType,
      'purpose': purpose.trim(),
      'startAt': Timestamp.fromDate(startAt),
      'endAt': Timestamp.fromDate(endAt),
      'attendees': attendees,
      'coordinatorName': coordinatorName.trim(),
      'equipment': equipment,
      'specialRequirements': specialRequirements.trim(),
      'declaration': true,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_availability.doc(ref.id), _slotDoc(user.uid, facility.id, startAt, endAt));
    await batch.commit();
    // Read back from the server before telling the student it succeeded.
    final verified = await ref.get(const GetOptions(source: Source.server));
    if (!verified.exists) throw StateError('The booking could not be verified. Reference: ${ref.id}');
    return ref.id;
  }

  /// Student withdraws their own pending request.
  Future<void> cancel(FacilityBookingRequest booking) async {
    if (booking.ownerUid != _user.uid) throw StateError('You can only cancel your own requests.');
    if (booking.status != FacilityBookingStatus.pending) {
      throw StateError('Only pending requests can be cancelled.');
    }
    final batch = _firestore.batch();
    batch.update(_bookings.doc(booking.id), {'status': 'cancelled', 'updatedAt': FieldValue.serverTimestamp()});
    batch.delete(_availability.doc(booking.id));
    await batch.commit();
  }

  static String confirmationNumberFor(FacilityBookingRequest booking) {
    final s = booking.startAt;
    final date = '${s.year}${s.month.toString().padLeft(2, '0')}${s.day.toString().padLeft(2, '0')}';
    return 'SGU-FB-$date-${booking.reference.substring(0, booking.reference.length.clamp(0, 5))}';
  }

  String get _reviewer {
    final user = _user;
    final name = user.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    return user.email ?? user.uid;
  }

  /// Admin approves: issues a confirmation number and reserves the slot.
  Future<String> approve(FacilityBookingRequest booking, {String remarks = ''}) async {
    final others = await fetchBookedSlots(booking.facilityId, excludeBookingId: booking.id);
    if (hasConflict(booking.facilityId, booking.startAt, booking.endAt, others)) {
      throw StateError('Another active booking already holds ${booking.facilityName} during this time. Reject one of them first.');
    }
    final confirmationNo = confirmationNumberFor(booking);
    final batch = _firestore.batch();
    batch.update(_bookings.doc(booking.id), {
      'status': 'approved',
      'adminRemarks': remarks.trim(),
      'reviewedBy': _reviewer,
      'reviewedAt': FieldValue.serverTimestamp(),
      'confirmationNo': confirmationNo,
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.set(_availability.doc(booking.id), _slotDoc(booking.ownerUid, booking.facilityId, booking.startAt, booking.endAt));
    await batch.commit();
    return confirmationNo;
  }

  /// Admin rejects (or revokes an approval). Remarks are required.
  Future<void> reject(FacilityBookingRequest booking, {required String remarks}) async {
    if (remarks.trim().length < 5) throw StateError('Please give the student a reason (at least 5 characters).');
    final batch = _firestore.batch();
    batch.update(_bookings.doc(booking.id), {
      'status': 'rejected',
      'adminRemarks': remarks.trim(),
      'reviewedBy': _reviewer,
      'reviewedAt': FieldValue.serverTimestamp(),
      'confirmationNo': '',
      'updatedAt': FieldValue.serverTimestamp(),
    });
    batch.delete(_availability.doc(booking.id));
    await batch.commit();
  }
}
