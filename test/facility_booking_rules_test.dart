import 'package:flutter_test/flutter_test.dart';
import 'package:sgu_student_campus/models/facility_booking.dart';

/// Boundary tests from "Facility Booking and Confirmation", Task 5.
void main() {
  // Fixed clock: 4 Nov 2026, 14:00.
  final now = DateTime(2026, 11, 4, 14, 0);
  final today = DateTime(2026, 11, 4);
  final future = DateTime(2026, 11, 10);

  String? check({
    String facilityId = 'library',
    required DateTime day,
    required int hour,
    int minute = 0,
    required int duration,
    List<BookingSlot> existing = const [],
  }) =>
      validateBookingSlot(
        facilityId: facilityId,
        day: day,
        startHour: hour,
        startMinute: minute,
        durationMinutes: duration,
        existing: existing,
        now: now,
      );

  final existing10to11 = <BookingSlot>[
    (facilityId: 'library', start: DateTime(2026, 11, 10, 10), end: DateTime(2026, 11, 10, 11)),
  ];

  test('1. Today with a start time already past is rejected as past', () {
    expect(check(day: today, hour: 9, duration: 60), startsWith('Time has passed'));
  });

  test('2. 21:30 start with 60 minutes is rejected (ends after 22:00)', () {
    expect(check(day: future, hour: 21, minute: 30, duration: 60), startsWith('Outside 08:00–22:00'));
  });

  test('3. Future date, 21:00 start, 60 minutes is accepted', () {
    expect(check(day: future, hour: 21, duration: 60), isNull);
  });

  test('4. Overlap 10:30–11:30 against 10:00–11:00 is rejected', () {
    expect(check(day: future, hour: 10, minute: 30, duration: 60, existing: existing10to11), startsWith('Facility already booked'));
  });

  test('5. Touching 11:00–12:00 after 10:00–11:00 is allowed (half-open)', () {
    expect(check(day: future, hour: 11, duration: 60, existing: existing10to11), isNull);
  });

  test('Conflicts are facility-specific', () {
    expect(check(facilityId: 'sports', day: future, hour: 10, minute: 30, duration: 60, existing: existing10to11), isNull);
  });

  test('Missing fields and out-of-range dates give distinct messages', () {
    expect(
      validateBookingSlot(facilityId: 'library', day: future, startHour: 10, startMinute: 0, durationMinutes: null, existing: const [], now: now),
      startsWith('Missing field'),
    );
    expect(check(day: today.add(const Duration(days: 31)), hour: 10, duration: 30), startsWith('Outside booking window'));
    expect(check(day: today.add(const Duration(days: 30)), hour: 10, duration: 30), isNull);
    expect(check(day: future, hour: 7, minute: 59, duration: 30), startsWith('Outside 08:00–22:00'));
    expect(check(day: future, hour: 8, duration: 30), isNull);
  });

  test('Start exactly now is allowed', () {
    expect(check(day: today, hour: 14, duration: 30), isNull);
  });

  test('hasConflict uses half-open intervals', () {
    final s = DateTime(2026, 11, 10, 10), e = DateTime(2026, 11, 10, 11);
    expect(hasConflict('library', e, e.add(const Duration(hours: 1)), [(facilityId: 'library', start: s, end: e)]), isFalse);
    expect(hasConflict('library', s.subtract(const Duration(minutes: 30)), s.add(const Duration(minutes: 1)), [(facilityId: 'library', start: s, end: e)]), isTrue);
  });
}
