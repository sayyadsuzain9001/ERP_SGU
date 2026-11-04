import 'package:flutter/material.dart';

import '../models/facility_booking.dart';
import '../theme/app_theme.dart';
import 'common.dart';

Color bookingStatusColor(FacilityBookingStatus status) => switch (status) {
      FacilityBookingStatus.pending => AppTheme.warning,
      FacilityBookingStatus.approved => AppTheme.success,
      FacilityBookingStatus.rejected => AppTheme.red,
      FacilityBookingStatus.cancelled => AppTheme.muted,
    };

class BookingStatusChip extends StatelessWidget {
  const BookingStatusChip(this.status, {super.key});
  final FacilityBookingStatus status;

  @override
  Widget build(BuildContext context) => StatusChip(status.label, color: bookingStatusColor(status));
}

/// Label/value rows grouped under a heading, used by the student request
/// details and the admin review sheet.
class BookingDetailSection extends StatelessWidget {
  const BookingDetailSection({super.key, required this.title, required this.rows});
  final String title;
  final List<(String, String)> rows;

  @override
  Widget build(BuildContext context) => Padding(
        padding: const EdgeInsets.only(bottom: 14),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title.toUpperCase(), style: const TextStyle(fontSize: 11, letterSpacing: 1.1, fontWeight: FontWeight.w800, color: AppTheme.red)),
          const SizedBox(height: 6),
          ...rows.map((row) => Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  SizedBox(width: 150, child: Text(row.$1, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600, fontSize: 13))),
                  Expanded(child: SelectableText(row.$2.trim().isEmpty ? '—' : row.$2, style: const TextStyle(fontSize: 13, color: AppTheme.ink))),
                ]),
              )),
        ]),
      );
}

/// Every section of a booking request, in form order.
List<Widget> bookingDetailSections(FacilityBookingRequest b) => [
      BookingDetailSection(title: 'Applicant', rows: [
        ('Name', b.applicantName),
        ('Student ID', b.studentId),
        ('Programme / Dept.', b.programme),
        ('Email', b.email),
        ('Phone', b.phone),
      ]),
      BookingDetailSection(title: 'Booking', rows: [
        ('Facility', b.facilityName),
        ('Date', BookingFormat.date(b.startAt)),
        ('Time', '${BookingFormat.time(b.startAt)} – ${BookingFormat.time(b.endAt)}'),
        ('Event / Activity', b.eventTitle),
        ('Activity type', b.activityType),
        ('Expected attendees', b.attendees > 0 ? '${b.attendees}' : ''),
        ('Faculty in-charge', b.coordinatorName),
        ('Purpose', b.purpose),
      ]),
      BookingDetailSection(title: 'Requirements', rows: [
        ('Equipment', b.equipment.join(', ')),
        ('Special requests', b.specialRequirements),
      ]),
      BookingDetailSection(title: 'Review', rows: [
        ('Status', b.status.label),
        ('Submitted', b.createdAt == null ? '' : BookingFormat.dateTime(b.createdAt!)),
        ('Reviewed by', b.reviewedBy),
        ('Reviewed on', b.reviewedAt == null ? '' : BookingFormat.dateTime(b.reviewedAt!)),
        ('Admin remarks', b.adminRemarks),
        if (b.confirmationNo.isNotEmpty) ('Confirmation no.', b.confirmationNo),
      ]),
    ];

/// Official-looking confirmation slip shown for approved bookings.
class BookingConfirmationSlip extends StatelessWidget {
  const BookingConfirmationSlip({super.key, required this.booking});
  final FacilityBookingRequest booking;

  @override
  Widget build(BuildContext context) {
    final b = booking;
    return Container(
      decoration: BoxDecoration(border: Border.all(color: AppTheme.success.withValues(alpha: .5), width: 1.5), borderRadius: BorderRadius.circular(16)),
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
        Row(children: [
          const Icon(Icons.verified, color: AppTheme.success, size: 30),
          const SizedBox(width: 10),
          const Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('SGU Campus Facilities',style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
            Text('Facility Booking Confirmation', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
          ])),
          StatusChip('CONFIRMED', color: AppTheme.success),
        ]),
        const Divider(height: 26),
        Text(b.confirmationNo.isEmpty ? 'Ref ${b.reference}' : b.confirmationNo,
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: .8, color: AppTheme.navy)),
        const SizedBox(height: 12),
        BookingDetailSection(title: 'Booking details', rows: [
          ('Facility', b.facilityName),
          ('Date', BookingFormat.date(b.startAt)),
          ('Time', '${BookingFormat.time(b.startAt)} – ${BookingFormat.time(b.endAt)}'),
          ('Event', b.eventTitle),
          ('Booked by', '${b.applicantName} (${b.studentId})'),
          ('Attendees', '${b.attendees}'),
          ('Approved by', b.reviewedBy),
          if (b.adminRemarks.isNotEmpty) ('Remarks', b.adminRemarks),
        ]),
        const Text(
          'Please carry this confirmation and your student ID card. Leave the facility clean and report any damage to the facility office. The booking may be withdrawn for university events.',
          style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.4),
        ),
      ]),
    );
  }
}
