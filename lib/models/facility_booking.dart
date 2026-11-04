import 'package:cloud_firestore/cloud_firestore.dart';

/// Lifecycle of a facility booking request.
///
/// Students submit requests as [pending]; an admin reviews them and either
/// [approved] (booking confirmed) or [rejected]. Students may [cancelled] a
/// request while it is still pending.
enum FacilityBookingStatus { pending, approved, rejected, cancelled }

extension FacilityBookingStatusX on FacilityBookingStatus {
  String get label => switch (this) {
        FacilityBookingStatus.pending => 'Pending review',
        FacilityBookingStatus.approved => 'Approved',
        FacilityBookingStatus.rejected => 'Rejected',
        FacilityBookingStatus.cancelled => 'Cancelled',
      };

  static FacilityBookingStatus parse(Object? value) => switch (value?.toString()) {
        'approved' || 'confirmed' => FacilityBookingStatus.approved,
        'rejected' => FacilityBookingStatus.rejected,
        'cancelled' => FacilityBookingStatus.cancelled,
        _ => FacilityBookingStatus.pending,
      };
}

/// A bookable campus facility. Keep [FacilityCatalog.all] in sync with the
/// `facilityId in [...]` list in firestore.rules.
class Facility {
  const Facility({
    required this.id,
    required this.name,
    required this.location,
    required this.capacity,
    required this.imageUrl,
  });

  final String id;
  final String name;
  final String location;
  final int capacity;
  final String imageUrl;
}

class FacilityCatalog {
  /// Bookable campus facilities. The first four are the ones named in the lab
  /// specification; the rest are the other main campus facilities.
  static const all = <Facility>[
    Facility(id: 'library', name: 'Library Discussion Room', location: 'Central Library, 1st floor', capacity: 12, imageUrl: 'https://images.unsplash.com/photo-1507842217343-583bb7270b66?w=900&q=80'),
    Facility(id: 'sports', name: 'Sports Hall', location: 'Sports Complex', capacity: 200, imageUrl: 'https://images.unsplash.com/photo-1461896836934-ffe607ba8211?w=900&q=80'),
    Facility(id: 'seminar', name: 'Seminar Room', location: 'Academic Block A', capacity: 80, imageUrl: 'https://images.unsplash.com/photo-1497366754035-f200968a6e72?w=900&q=80'),
    Facility(id: 'music', name: 'Music Practice Room', location: 'Student Centre', capacity: 10, imageUrl: 'https://images.unsplash.com/photo-1516280440614-37939bbacd81?w=900&q=80'),
    Facility(id: 'auditorium', name: 'Main Auditorium', location: 'Central Building', capacity: 400, imageUrl: 'https://images.unsplash.com/photo-1505373877841-8d25f7d46678?w=900&q=80'),
    Facility(id: 'ground', name: 'Sports Ground (Cricket / Football)', location: 'Sports Complex', capacity: 300, imageUrl: 'https://images.unsplash.com/photo-1531415074968-036ba1b575da?w=900&q=80'),
    Facility(id: 'badminton', name: 'Indoor Badminton Court', location: 'Sports Complex', capacity: 20, imageUrl: 'https://images.unsplash.com/photo-1626224583764-f87db24ac4ea?w=900&q=80'),
    Facility(id: 'gym', name: 'Gymnasium', location: 'Sports Complex', capacity: 40, imageUrl: 'https://images.unsplash.com/photo-1534438327276-14e5300c3a48?w=900&q=80'),
    Facility(id: 'lab', name: 'Computer Lab', location: 'IT Block', capacity: 60, imageUrl: 'https://images.unsplash.com/photo-1517694712202-14dd9538aa97?w=900&q=80'),
    Facility(id: 'conference', name: 'Conference Room', location: 'Admin Block', capacity: 25, imageUrl: 'https://images.unsplash.com/photo-1497366811353-6870744d04b2?w=900&q=80'),
  ];

  static Facility? byId(String id) {
    for (final facility in all) {
      if (facility.id == id) return facility;
    }
    return null;
  }

  static const activityTypes = <String>[
    'Academic / Lecture',
    'Club activity',
    'Cultural event',
    'Sports / Practice',
    'Workshop / Seminar',
    'Meeting / Group study',
    'Other',
  ];

  static const equipment = <String>[
    'Projector / Screen',
    'Microphone / PA system',
    'Whiteboard',
    'Extra chairs / tables',
    'Air conditioning',
    'Wi-Fi access',
    'Sports equipment',
  ];

  /// Daily operating hours for all bookable facilities.
  static const openingHour = 8;
  static const closingHour = 22;
  static const maxAdvanceDays = 30;
  static const durations = <int>[30, 60, 90];
}

/// A reserved time window for one facility (no personal data).
typedef BookingSlot = ({String facilityId, DateTime start, DateTime end});

/// True when [start, end) overlaps an existing booking for the same facility.
/// Intervals are half-open, so a booking ending at 11:00 and one starting at
/// 11:00 do not overlap.
bool hasConflict(String facilityId, DateTime start, DateTime end, Iterable<BookingSlot> bookings) =>
    bookings.any((b) => b.facilityId == facilityId && start.isBefore(b.end) && end.isAfter(b.start));

/// Validates a requested slot against the booking business rules.
///
/// Returns null when the slot is valid, otherwise one of the distinct messages
/// required by the specification (missing field, time has passed, outside
/// 08:00–22:00, facility already booked). Pure, so it is unit-testable.
String? validateBookingSlot({
  required String? facilityId,
  required DateTime? day,
  required int? startHour,
  required int? startMinute,
  required int? durationMinutes,
  required Iterable<BookingSlot> existing,
  required DateTime now,
}) {
  if (facilityId == null || day == null || startHour == null || startMinute == null || durationMinutes == null) {
    return 'Missing field: choose a facility, date, start time and duration.';
  }
  final start = DateTime(day.year, day.month, day.day, startHour, startMinute);
  final end = start.add(Duration(minutes: durationMinutes));
  if (start.isBefore(now)) return 'Time has passed: choose a start time from now onwards.';
  final today = DateTime(now.year, now.month, now.day);
  final chosenDay = DateTime(day.year, day.month, day.day);
  if (chosenDay.isBefore(today) || chosenDay.isAfter(today.add(const Duration(days: FacilityCatalog.maxAdvanceDays)))) {
    return 'Outside booking window: choose a date from today through the next ${FacilityCatalog.maxAdvanceDays} days.';
  }
  final open = DateTime(day.year, day.month, day.day, FacilityCatalog.openingHour);
  final close = DateTime(day.year, day.month, day.day, FacilityCatalog.closingHour);
  if (start.isBefore(open) || end.isAfter(close)) {
    return 'Outside 08:00–22:00: the booking must start at 08:00 or later and end by 22:00.';
  }
  if (hasConflict(facilityId, start, end, existing)) {
    final name = FacilityCatalog.byId(facilityId)?.name ?? 'This facility';
    return 'Facility already booked: $name is already booked during this time.';
  }
  return null;
}

/// A facility booking request document in the `facilityBookings` collection.
class FacilityBookingRequest {
  const FacilityBookingRequest({
    required this.id,
    required this.ownerUid,
    required this.applicantName,
    required this.studentId,
    required this.programme,
    required this.email,
    required this.phone,
    required this.facilityId,
    required this.facilityName,
    required this.eventTitle,
    required this.activityType,
    required this.purpose,
    required this.startAt,
    required this.endAt,
    required this.attendees,
    required this.coordinatorName,
    required this.equipment,
    required this.specialRequirements,
    required this.status,
    this.createdAt,
    this.adminRemarks = '',
    this.reviewedBy = '',
    this.reviewedAt,
    this.confirmationNo = '',
  });

  final String id;
  final String ownerUid;
  final String applicantName;
  final String studentId;
  final String programme;
  final String email;
  final String phone;
  final String facilityId;
  final String facilityName;
  final String eventTitle;
  final String activityType;
  final String purpose;
  final DateTime startAt;
  final DateTime endAt;
  final int attendees;
  final String coordinatorName;
  final List<String> equipment;
  final String specialRequirements;
  final FacilityBookingStatus status;
  final DateTime? createdAt;
  final String adminRemarks;
  final String reviewedBy;
  final DateTime? reviewedAt;
  final String confirmationNo;

  bool overlaps(DateTime start, DateTime end) =>
      start.isBefore(endAt) && end.isAfter(startAt);

  /// Pending and approved requests hold their slot; others free it.
  bool get isActive => status == FacilityBookingStatus.pending || status == FacilityBookingStatus.approved;

  BookingSlot get slot => (facilityId: facilityId, start: startAt, end: endAt);

  /// Short human-friendly reference shown on the confirmation slip.
  String get reference => id.length <= 8 ? id.toUpperCase() : id.substring(0, 8).toUpperCase();

  static DateTime? _date(Object? value) => value is Timestamp ? value.toDate() : null;
  static String _str(Object? value) => (value ?? '').toString();

  factory FacilityBookingRequest.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final d = doc.data() ?? const <String, dynamic>{};
    final facilityId = _str(d['facilityId']);
    final start = _date(d['startAt']) ?? DateTime.fromMillisecondsSinceEpoch(0);
    return FacilityBookingRequest(
      id: doc.id,
      ownerUid: _str(d['ownerUid']),
      applicantName: _str(d['applicantName']),
      studentId: _str(d['studentId']),
      programme: _str(d['programme']),
      email: _str(d['email']),
      phone: _str(d['phone']),
      facilityId: facilityId,
      facilityName: _str(d['facilityName']).isNotEmpty
          ? _str(d['facilityName'])
          : (FacilityCatalog.byId(facilityId)?.name ?? 'Campus facility'),
      // Older records only stored `purpose`; use it as the title fallback.
      eventTitle: _str(d['eventTitle']).isNotEmpty ? _str(d['eventTitle']) : _str(d['purpose']),
      activityType: _str(d['activityType']),
      purpose: _str(d['purpose']),
      startAt: start,
      endAt: _date(d['endAt']) ?? start,
      attendees: d['attendees'] is num ? (d['attendees'] as num).toInt() : 0,
      coordinatorName: _str(d['coordinatorName']),
      equipment: d['equipment'] is List
          ? (d['equipment'] as List).map((e) => e.toString()).toList()
          : const [],
      specialRequirements: _str(d['specialRequirements']),
      status: FacilityBookingStatusX.parse(d['status']),
      createdAt: _date(d['createdAt']),
      adminRemarks: _str(d['adminRemarks']),
      reviewedBy: _str(d['reviewedBy']),
      reviewedAt: _date(d['reviewedAt']),
      confirmationNo: _str(d['confirmationNo']),
    );
  }
}

/// Shared date/time formatting for booking screens.
class BookingFormat {
  static const _months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
  static const _days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

  static String date(DateTime v) => '${_days[v.weekday - 1]}, ${v.day} ${_months[v.month - 1]} ${v.year}';

  static String time(DateTime v) {
    final hour = v.hour % 12 == 0 ? 12 : v.hour % 12;
    return '$hour:${v.minute.toString().padLeft(2, '0')} ${v.hour >= 12 ? 'PM' : 'AM'}';
  }

  static String slot(DateTime start, DateTime end) => '${date(start)} • ${time(start)} – ${time(end)}';

  static String dateTime(DateTime v) => '${date(v)}, ${time(v)}';
}
