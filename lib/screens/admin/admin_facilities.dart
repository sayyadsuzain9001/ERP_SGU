import 'package:flutter/material.dart';

import '../../models/facility_booking.dart';
import '../../services/facility_booking_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/facility_booking_widgets.dart';

/// Admin portal: review every Facility Booking & Confirmation request in real
/// time, then approve (issues a confirmation number) or reject with remarks.
class AdminFacilitiesPage extends StatefulWidget {
  const AdminFacilitiesPage({super.key});

  @override
  State<AdminFacilitiesPage> createState() => _AdminFacilitiesPageState();
}

class _AdminFacilitiesPageState extends State<AdminFacilitiesPage> {
  final _repository = FacilityBookingRepository();
  final _search = TextEditingController();
  late final Stream<List<FacilityBookingRequest>> _stream = _repository.watchAllBookings();

  FacilityBookingStatus? _status = FacilityBookingStatus.pending;
  String _facilityId = 'all';
  bool _upcomingFirst = true;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  /// Other active (pending/approved) requests for the same facility and time.
  List<FacilityBookingRequest> _clashes(FacilityBookingRequest b, List<FacilityBookingRequest> all) => all
      .where((o) =>
          o.id != b.id &&
          o.facilityId == b.facilityId &&
          (o.status == FacilityBookingStatus.pending || o.status == FacilityBookingStatus.approved) &&
          o.overlaps(b.startAt, b.endAt))
      .toList();

  List<FacilityBookingRequest> _filtered(List<FacilityBookingRequest> all) {
    final q = _search.text.trim().toLowerCase();
    final list = all.where((b) {
      if (_status != null && b.status != _status) return false;
      if (_facilityId != 'all' && b.facilityId != _facilityId) return false;
      if (q.isEmpty) return true;
      return [b.applicantName, b.studentId, b.eventTitle, b.email, b.reference, b.confirmationNo, b.facilityName]
          .any((v) => v.toLowerCase().contains(q));
    }).toList();
    if (_upcomingFirst) list.sort((a, b) => a.startAt.compareTo(b.startAt));
    return list;
  }

  @override
  Widget build(BuildContext context) => PageContainer(
        title: 'Facility Bookings',
        subtitle: 'Review student facility booking requests and issue confirmations. Updates live from Firebase.',
        child: StreamBuilder<List<FacilityBookingRequest>>(
          stream: _stream,
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _message(Icons.cloud_off_outlined,
                  'Could not load facility bookings. Make sure you are signed in with the admin role and the latest firestore.rules are deployed.');
            }
            if (!snapshot.hasData) {
              return const Center(child: Padding(padding: EdgeInsets.all(32), child: CircularProgressIndicator()));
            }
            final all = snapshot.data!;
            final shown = _filtered(all);
            return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _stats(all),
              const SizedBox(height: 14),
              _filters(),
              const SizedBox(height: 14),
              Text('${shown.length} ${shown.length == 1 ? 'request' : 'requests'}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
              const SizedBox(height: 8),
              if (shown.isEmpty)
                _message(Icons.event_busy_outlined,
                    all.isEmpty ? 'No booking requests yet. Requests submitted from the student portal appear here automatically.' : 'No requests match these filters.')
              else
                ...shown.map((b) => _bookingCard(b, _clashes(b, all), all)),
            ]);
          },
        ),
      );

  Widget _stats(List<FacilityBookingRequest> all) {
    int count(FacilityBookingStatus s) => all.where((b) => b.status == s).length;
    final tiles = <(String, int, Color, IconData, FacilityBookingStatus?)>[
      ('All requests', all.length, AppTheme.navy, Icons.inbox_outlined, null),
      ('Pending review', count(FacilityBookingStatus.pending), AppTheme.warning, Icons.hourglass_top, FacilityBookingStatus.pending),
      ('Approved', count(FacilityBookingStatus.approved), AppTheme.success, Icons.verified_outlined, FacilityBookingStatus.approved),
      ('Rejected', count(FacilityBookingStatus.rejected), AppTheme.red, Icons.block, FacilityBookingStatus.rejected),
      ('Cancelled', count(FacilityBookingStatus.cancelled), AppTheme.muted, Icons.cancel_outlined, FacilityBookingStatus.cancelled),
    ];
    return LayoutBuilder(builder: (context, box) {
      final perRow = box.maxWidth >= 1000 ? 5 : box.maxWidth >= 600 ? 3 : 2;
      final width = (box.maxWidth - 12 * (perRow - 1)) / perRow;
      return Wrap(spacing: 12, runSpacing: 12, children: tiles.map((t) {
        final selected = _status == t.$5;
        return SizedBox(
          width: width,
          child: Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18), side: BorderSide(color: selected ? t.$3 : AppTheme.border, width: selected ? 2 : 1)),
            child: InkWell(
              borderRadius: BorderRadius.circular(18),
              onTap: () => setState(() => _status = t.$5),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(children: [
                  Icon(t.$4, color: t.$3),
                  const SizedBox(width: 10),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Text('${t.$2}', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: t.$3)),
                    Text(t.$1, style: const TextStyle(fontSize: 12, color: AppTheme.muted), overflow: TextOverflow.ellipsis),
                  ])),
                ]),
              ),
            ),
          ),
        );
      }).toList());
    });
  }

  Widget _filters() => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: LayoutBuilder(builder: (context, box) {
            final wide = box.maxWidth >= 760;
            final searchField = TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: InputDecoration(
                labelText: 'Search',
                hintText: 'Student name, ID, event, reference…',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _search.text.isEmpty ? null : IconButton(icon: const Icon(Icons.clear), onPressed: () => setState(_search.clear)),
              ),
            );
            final facility = DropdownButtonFormField<String>(
              initialValue: _facilityId,
              decoration: const InputDecoration(labelText: 'Facility', prefixIcon: Icon(Icons.meeting_room_outlined)),
              items: [
                const DropdownMenuItem(value: 'all', child: Text('All facilities')),
                ...FacilityCatalog.all.map((f) => DropdownMenuItem(value: f.id, child: Text(f.name))),
              ],
              onChanged: (v) => setState(() => _facilityId = v ?? 'all'),
            );
            final sort = SegmentedButton<bool>(
              segments: const [
                ButtonSegment(value: true, label: Text('By date')),
                ButtonSegment(value: false, label: Text('Newest')),
              ],
              selected: {_upcomingFirst},
              onSelectionChanged: (s) => setState(() => _upcomingFirst = s.first),
            );
            if (!wide) {
              return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [searchField, const SizedBox(height: 12), facility, const SizedBox(height: 12), sort]);
            }
            return Row(children: [
              Expanded(flex: 3, child: searchField),
              const SizedBox(width: 12),
              Expanded(flex: 2, child: facility),
              const SizedBox(width: 12),
              sort,
            ]);
          }),
        ),
      );

  Widget _bookingCard(FacilityBookingRequest b, List<FacilityBookingRequest> clashes, List<FacilityBookingRequest> all) {
    final past = b.endAt.isBefore(DateTime.now());
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () => _openReview(b, all),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              CircleAvatar(backgroundColor: bookingStatusColor(b.status).withValues(alpha: .12), child: Icon(Icons.meeting_room_outlined, color: bookingStatusColor(b.status))),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(b.eventTitle.isEmpty ? b.facilityName : b.eventTitle, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: AppTheme.navy)),
                const SizedBox(height: 2),
                Text('${b.facilityName} • ${BookingFormat.slot(b.startAt, b.endAt)}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                const SizedBox(height: 2),
                Text(
                  [
                    if (b.applicantName.isNotEmpty) b.applicantName,
                    if (b.studentId.isNotEmpty) b.studentId,
                    if (b.attendees > 0) '${b.attendees} attendees',
                    'Ref ${b.reference}',
                  ].join(' • '),
                  style: const TextStyle(fontSize: 12),
                ),
              ])),
              const SizedBox(width: 8),
              BookingStatusChip(b.status),
            ]),
            if (clashes.isNotEmpty || past) ...[
              const SizedBox(height: 10),
              Wrap(spacing: 8, runSpacing: 6, children: [
                if (clashes.isNotEmpty) StatusChip('⚠ Clashes with ${clashes.length} other request${clashes.length == 1 ? '' : 's'}', color: AppTheme.red),
                if (past) const StatusChip('Date passed', color: AppTheme.muted),
              ]),
            ],
            const SizedBox(height: 6),
            Align(
              alignment: Alignment.centerRight,
              child: TextButton.icon(
                onPressed: () => _openReview(b, all),
                icon: Icon(b.status == FacilityBookingStatus.pending ? Icons.rate_review_outlined : Icons.visibility_outlined, size: 18),
                label: Text(b.status == FacilityBookingStatus.pending ? 'Review' : 'View'),
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _openReview(FacilityBookingRequest b, List<FacilityBookingRequest> all) async {
    final result = await showDialog<String>(
      context: context,
      builder: (_) => _ReviewDialog(booking: b, clashes: _clashes(b, all), repository: _repository),
    );
    if (result != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(result)));
    }
  }

  Widget _message(IconData icon, String text) => Card(
        child: Padding(
          padding: const EdgeInsets.all(28),
          child: Column(children: [
            Icon(icon, size: 40, color: AppTheme.muted),
            const SizedBox(height: 10),
            Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted)),
          ]),
        ),
      );
}

class _ReviewDialog extends StatefulWidget {
  const _ReviewDialog({required this.booking, required this.clashes, required this.repository});
  final FacilityBookingRequest booking;
  final List<FacilityBookingRequest> clashes;
  final FacilityBookingRepository repository;

  @override
  State<_ReviewDialog> createState() => _ReviewDialogState();
}

class _ReviewDialogState extends State<_ReviewDialog> {
  late final _remarks = TextEditingController(text: widget.booking.adminRemarks);
  bool _busy = false;
  String? _error;

  @override
  void dispose() {
    _remarks.dispose();
    super.dispose();
  }

  Future<void> _run(Future<String> Function() action) async {
    setState(() { _busy = true; _error = null; });
    try {
      final message = await action();
      if (mounted) Navigator.pop(context, message);
    } catch (e) {
      if (mounted) setState(() { _busy = false; _error = e is StateError ? e.message : '$e'; });
    }
  }

  void _approve() => _run(() async {
        final no = await widget.repository.approve(widget.booking, remarks: _remarks.text);
        return 'Approved. Confirmation $no issued to ${widget.booking.applicantName.isEmpty ? 'the student' : widget.booking.applicantName}.';
      });

  void _reject() {
    if (_remarks.text.trim().length < 5) {
      setState(() => _error = 'Add a reason in the remarks so the student knows why (at least 5 characters).');
      return;
    }
    _run(() async {
      await widget.repository.reject(widget.booking, remarks: _remarks.text);
      return widget.booking.status == FacilityBookingStatus.approved ? 'Approval revoked.' : 'Request rejected.';
    });
  }

  @override
  Widget build(BuildContext context) {
    final b = widget.booking;
    final reviewable = b.status == FacilityBookingStatus.pending || b.status == FacilityBookingStatus.approved || b.status == FacilityBookingStatus.rejected;
    final approvedClash = widget.clashes.isNotEmpty;
    return Dialog(
      insetPadding: const EdgeInsets.all(16),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 680),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, mainAxisSize: MainAxisSize.min, children: [
            Row(children: [
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('FACILITY BOOKING REQUEST', style: TextStyle(fontSize: 11, letterSpacing: 1.2, fontWeight: FontWeight.w800, color: AppTheme.muted)),
                const SizedBox(height: 4),
                Text(b.eventTitle.isEmpty ? b.facilityName : b.eventTitle, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.navy)),
                Text('Ref ${b.reference}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
              ])),
              BookingStatusChip(b.status),
            ]),
            const SizedBox(height: 16),
            if (widget.clashes.isNotEmpty) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .07), borderRadius: BorderRadius.circular(12)),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Schedule clash', style: TextStyle(fontWeight: FontWeight.w800, color: AppTheme.red)),
                  const SizedBox(height: 4),
                  ...widget.clashes.map((c) => Text('• ${c.status.label}: ${c.eventTitle} (${c.applicantName.isEmpty ? c.reference : c.applicantName}) ${BookingFormat.time(c.startAt)} – ${BookingFormat.time(c.endAt)}',
                      style: const TextStyle(fontSize: 12))),
                  if (approvedClash) const Padding(padding: EdgeInsets.only(top: 4), child: Text('Another active booking holds this slot. Reject one of the clashing requests before approving.', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
                ]),
              ),
              const SizedBox(height: 16),
            ],
            if (b.status == FacilityBookingStatus.approved) ...[
              BookingConfirmationSlip(booking: b),
              const SizedBox(height: 16),
            ],
            ...bookingDetailSections(b),
            if (reviewable) ...[
              const Divider(height: 24),
              TextField(
                controller: _remarks,
                enabled: !_busy,
                maxLines: 3,
                maxLength: 500,
                decoration: const InputDecoration(labelText: 'Admin remarks', hintText: 'Required when rejecting. Shown to the student.', alignLabelWithHint: true),
              ),
            ],
            if (_error != null) Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: AppTheme.red, fontWeight: FontWeight.w600))),
            Wrap(alignment: WrapAlignment.end, spacing: 10, runSpacing: 10, children: [
              TextButton(onPressed: _busy ? null : () => Navigator.pop(context), child: const Text('Close')),
              if (b.status == FacilityBookingStatus.pending || b.status == FacilityBookingStatus.approved)
                OutlinedButton.icon(
                  onPressed: _busy ? null : _reject,
                  style: OutlinedButton.styleFrom(foregroundColor: AppTheme.red),
                  icon: const Icon(Icons.close),
                  label: Text(b.status == FacilityBookingStatus.approved ? 'Revoke approval' : 'Reject'),
                ),
              if (b.status == FacilityBookingStatus.pending || b.status == FacilityBookingStatus.rejected)
                FilledButton.icon(
                  onPressed: _busy || approvedClash ? null : _approve,
                  style: FilledButton.styleFrom(backgroundColor: AppTheme.success),
                  icon: _busy ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.check),
                  label: Text(b.status == FacilityBookingStatus.rejected ? 'Approve instead' : 'Approve & confirm'),
                ),
            ]),
          ]),
        ),
      ),
    );
  }
}
