import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import '../../models/facility_booking.dart';
import '../../services/facility_booking_repository.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/facility_booking_widgets.dart';

/// Student portal: Facility Booking & Confirmation form plus a live tracker of
/// the student's own requests and their admin review outcome.
class FacilityBookingScreen extends StatefulWidget {
  const FacilityBookingScreen({super.key});

  @override
  State<FacilityBookingScreen> createState() => _FacilityBookingScreenState();
}

class _FacilityBookingScreenState extends State<FacilityBookingScreen> {
  final _repository = FacilityBookingRepository();
  final _formKey = GlobalKey<FormState>();

  final _name = TextEditingController();
  final _studentId = TextEditingController();
  final _programme = TextEditingController();
  final _email = TextEditingController();
  final _phone = TextEditingController();
  final _eventTitle = TextEditingController();
  final _purpose = TextEditingController();
  final _attendees = TextEditingController();
  final _coordinator = TextEditingController();
  final _special = TextEditingController();

  int _tab = 0; // 0 = new request, 1 = my requests
  String? _facilityId;
  String? _activityType;
  DateTime? _date;
  TimeOfDay? _startTime;
  int? _duration;
  final Set<String> _equipment = {};
  bool _declaration = false;
  bool _submitting = false;
  bool _attemptedSubmit = false;

  List<FacilityBookingRequest> _myBookings = const [];
  List<BookingSlot> _bookedSlots = const [];
  StreamSubscription<List<FacilityBookingRequest>>? _mySub;
  StreamSubscription<List<BookingSlot>>? _slotSub;
  Object? _myError;

  @override
  void initState() {
    super.initState();
    _prefill();
    _mySub = _repository.watchMyBookings().listen(
      (list) => mounted ? setState(() { _myBookings = list; _myError = null; }) : null,
      onError: (Object e) => mounted ? setState(() => _myError = e) : null,
    );
    _slotSub = _repository.watchBookedSlots().listen(
      (slots) => mounted ? setState(() => _bookedSlots = slots) : null,
      onError: (_) {}, // Live availability is a convenience; the server is rechecked before saving.
    );
  }

  Facility? get _facility => _facilityId == null ? null : FacilityCatalog.byId(_facilityId!);

  Future<void> _prefill() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    _email.text = user.email ?? '';
    _name.text = user.displayName ?? '';
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      final d = doc.data();
      if (!mounted || d == null) return;
      void fill(TextEditingController c, Object? v, {bool overwrite = false}) {
        final text = (v ?? '').toString().trim();
        if (text.isEmpty) return;
        if (overwrite || c.text.trim().isEmpty) c.text = text;
      }
      setState(() {
        fill(_name, d['name'], overwrite: true);
        fill(_studentId, d['studentId']);
        fill(_programme, d['programme']);
        fill(_email, d['email']);
        fill(_phone, d['phone']);
      });
    } on FirebaseException {
      // Profile not readable yet; the student can type the details.
    }
  }

  @override
  void dispose() {
    _mySub?.cancel();
    _slotSub?.cancel();
    for (final c in [_name, _studentId, _programme, _email, _phone, _eventTitle, _purpose, _attendees, _coordinator, _special]) {
      c.dispose();
    }
    super.dispose();
  }

  // ---------------------------------------------------------------- helpers

  DateTime get _today {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day);
  }

  DateTime? get _start => _date == null || _startTime == null
      ? null
      : DateTime(_date!.year, _date!.month, _date!.day, _startTime!.hour, _startTime!.minute);

  DateTime? get _end => _start == null || _duration == null ? null : _start!.add(Duration(minutes: _duration!));

  /// Every active slot we know about: live availability plus the student's own
  /// requests (covers the moment between submit and the availability update).
  List<BookingSlot> get _knownSlots => [
        ..._bookedSlots,
        ..._myBookings.where((b) => b.isActive).map((b) => b.slot),
      ];

  /// Business-rule check (see [validateBookingSlot]); null when valid.
  String? get _slotIssue => validateBookingSlot(
        facilityId: _facilityId,
        day: _date,
        startHour: _startTime?.hour,
        startMinute: _startTime?.minute,
        durationMinutes: _duration,
        existing: _knownSlots,
        now: DateTime.now(),
      );


  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      firstDate: _today,
      lastDate: _today.add(const Duration(days: FacilityCatalog.maxAdvanceDays)),
      initialDate: _date ?? _today,
      helpText: 'Select booking date',
    );
    if (picked != null && mounted) setState(() => _date = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _startTime ?? const TimeOfDay(hour: 10, minute: 0),
      helpText: 'Select start time',
    );
    // A dismissed picker returns null: keep the previously selected value.
    if (picked != null && mounted) setState(() => _startTime = picked);
  }

  void _snack(String text) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  // ----------------------------------------------------------------- submit

  Future<void> _submit() async {
    if (_submitting) return;
    setState(() => _attemptedSubmit = true);
    final fieldsOk = _formKey.currentState?.validate() ?? false;
    final slotIssue = _slotIssue;
    if (!fieldsOk || slotIssue != null || !_declaration) {
      _snack(slotIssue ?? (!fieldsOk ? 'Missing field: please complete the highlighted fields.' : 'Missing field: please accept the undertaking.'));
      return;
    }
    final facility = _facility!;
    final start = _start!, end = _end!;
    final summary = 'Facility: ${facility.name}\n'
        'Date: ${BookingFormat.date(start)}\n'
        'Start: ${BookingFormat.time(start)}\n'
        'End: ${BookingFormat.time(end)} ($_duration min)\n'
        'Purpose: ${_purpose.text.trim()}\n\n'
        'After you confirm, the slot is held for you and the facility office reviews the request.';
    // Cancel returns false; tapping outside returns null. Only true saves.
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Confirm facility booking'),
        content: Text(summary),
        actions: [
          TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.pop(dialogContext, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (!mounted || accepted != true) return;
    // Validate again: time may have passed while the dialog was open.
    final finalIssue = _slotIssue;
    if (finalIssue != null) {
      _snack(finalIssue);
      return;
    }
    setState(() => _submitting = true);
    try {
      final id = await _repository.submit(
        applicantName: _name.text,
        studentId: _studentId.text,
        programme: _programme.text,
        email: _email.text,
        phone: _phone.text,
        facility: facility,
        eventTitle: _eventTitle.text,
        activityType: _activityType!,
        purpose: _purpose.text,
        startAt: start,
        endAt: end,
        attendees: int.parse(_attendees.text.trim()),
        coordinatorName: _coordinator.text,
        equipment: FacilityCatalog.equipment.where(_equipment.contains).toList(),
        specialRequirements: _special.text,
      );
      if (!mounted) return;
      _resetBookingFields();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Booking confirmed for ${facility.name}, ${BookingFormat.slot(start, end)}. Ref ${id.substring(0, 8).toUpperCase()} is pending admin approval.'),
        action: SnackBarAction(label: 'VIEW', onPressed: () => mounted ? setState(() => _tab = 1) : null),
      ));
    } on FirebaseException catch (e) {
      if (mounted) {
        _snack(e.code == 'permission-denied'
            ? 'Firebase rejected the booking. Check your details and that the latest firestore.rules are deployed.'
            : 'Could not save booking: ${e.message ?? e.code}');
      }
    } catch (e) {
      if (mounted) _snack(e is StateError ? e.message : 'Could not save booking: $e');
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  void _resetBookingFields() {
    _formKey.currentState?.reset();
    for (final c in [_eventTitle, _purpose, _attendees, _coordinator, _special]) {
      c.clear();
    }
    setState(() {
      _activityType = null;
      _facilityId = null;
      _date = null;
      _startTime = null;
      _duration = null;
      _equipment.clear();
      _declaration = false;
      _attemptedSubmit = false;
    });
  }

  Future<void> _cancel(FacilityBookingRequest b) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Cancel this request?'),
        content: Text('${b.facilityName}\n${BookingFormat.slot(b.startAt, b.endAt)}'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Keep')),
          FilledButton(style: FilledButton.styleFrom(backgroundColor: AppTheme.red), onPressed: () => Navigator.pop(ctx, true), child: const Text('Cancel request')),
        ],
      ),
    );
    if (ok != true || !mounted) return;
    try {
      await _repository.cancel(b);
      if (mounted) _snack('Request cancelled.');
    } catch (e) {
      if (mounted) _snack('Could not cancel: ${e is StateError ? e.message : e}');
    }
  }

  void _showDetails(FacilityBookingRequest b) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        insetPadding: const EdgeInsets.all(16),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: [
              Row(children: [
                Expanded(child: Text(b.eventTitle, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy))),
                BookingStatusChip(b.status),
              ]),
              const SizedBox(height: 16),
              if (b.status == FacilityBookingStatus.approved) ...[
                BookingConfirmationSlip(booking: b),
                const SizedBox(height: 18),
              ],
              ...bookingDetailSections(b),
              Align(alignment: Alignment.centerRight, child: TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Close'))),
            ]),
          ),
        ),
      ),
    );
  }

  // ------------------------------------------------------------------ build

  @override
  Widget build(BuildContext context) {
    final pending = _myBookings.where((b) => b.status == FacilityBookingStatus.pending).length;
    return PageContainer(
      title: 'Facility Booking & Confirmation',
      subtitle: 'Request a campus facility. The facility office reviews every request and issues a confirmation once approved.',
      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        SegmentedButton<int>(
          segments: [
            const ButtonSegment(value: 0, icon: Icon(Icons.edit_calendar_outlined), label: Text('New request')),
            ButtonSegment(value: 1, icon: const Icon(Icons.list_alt_outlined), label: Text(pending > 0 ? 'My requests ($pending pending)' : 'My requests (${_myBookings.length})')),
          ],
          selected: {_tab},
          onSelectionChanged: (s) => setState(() => _tab = s.first),
        ),
        const SizedBox(height: 18),
        if (_tab == 0) _formView() else _myRequestsView(),
      ]),
    );
  }

  Widget _formView() => LayoutBuilder(builder: (context, box) {
        final desktop = box.maxWidth >= 980;
        final form = Form(
          key: _formKey,
          autovalidateMode: _attemptedSubmit ? AutovalidateMode.onUserInteraction : AutovalidateMode.disabled,
          child: AbsorbPointer(
            absorbing: _submitting,
            child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
              _section('1. Applicant details', Icons.person_outline, _applicantFields()),
              const SizedBox(height: 14),
              _section('2. Facility', Icons.meeting_room_outlined, _facilityPicker()),
              const SizedBox(height: 14),
              _section('3. Date, time & duration', Icons.schedule_outlined, _scheduleFields()),
              const SizedBox(height: 14),
              _section('4. Event details', Icons.event_note_outlined, _eventFields()),
              const SizedBox(height: 14),
              _section('5. Requirements', Icons.handyman_outlined, _requirementFields()),
              const SizedBox(height: 14),
              _section('6. Undertaking', Icons.verified_user_outlined, _undertaking()),
              const SizedBox(height: 18),
              Wrap(spacing: 10, runSpacing: 10, children: [
                FilledButton.icon(
                  onPressed: _submitting ? null : _submit,
                  icon: _submitting
                      ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                      : const Icon(Icons.send_outlined),
                  label: Text(_submitting ? 'SAVING…' : 'REVIEW & CONFIRM BOOKING'),
                ),
                OutlinedButton.icon(onPressed: _submitting ? null : _resetBookingFields, icon: const Icon(Icons.refresh), label: const Text('RESET')),
              ]),
            ]),
          ),
        );
        final summary = ListenableBuilder(
          listenable: Listenable.merge([_name, _studentId, _phone, _eventTitle, _attendees]),
          builder: (context, _) => _summaryCard(),
        );
        if (!desktop) return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [form, const SizedBox(height: 14), summary]);
        return Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Expanded(child: form),
          const SizedBox(width: 18),
          SizedBox(width: 320, child: summary),
        ]);
      });

  Widget _section(String title, IconData icon, Widget child) => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Row(children: [
              Container(
                width: 36, height: 36,
                decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .08), borderRadius: BorderRadius.circular(9)),
                child: Icon(icon, color: AppTheme.red, size: 19),
              ),
              const SizedBox(width: 10),
              Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
            ]),
            const SizedBox(height: 16),
            child,
          ]),
        ),
      );

  Widget _twoColumn(List<Widget> children) => LayoutBuilder(builder: (context, box) {
        final width = box.maxWidth >= 620 ? (box.maxWidth - 12) / 2 : box.maxWidth;
        return Wrap(spacing: 12, runSpacing: 12, children: children.map((c) => SizedBox(width: width, child: c)).toList());
      });

  Widget _field(TextEditingController c, String label, IconData icon, String? Function(String) validator,
          {String? hint, TextInputType? keyboard, int maxLines = 1, int? maxLength}) =>
      TextFormField(
        controller: c,
        keyboardType: keyboard,
        maxLines: maxLines,
        maxLength: maxLength,
        textInputAction: maxLines > 1 ? TextInputAction.newline : TextInputAction.next,
        decoration: InputDecoration(labelText: label, hintText: hint, prefixIcon: Icon(icon), alignLabelWithHint: maxLines > 1),
        validator: (v) => validator(v?.trim() ?? ''),
      );

  Widget _applicantFields() => _twoColumn([
        _field(_name, 'Full name *', Icons.badge_outlined, (v) => v.length < 3 ? 'Enter your full name.' : null),
        _field(_studentId, 'Student ID / PRN *', Icons.numbers, (v) => v.length < 4 ? 'Enter your student ID.' : null),
        _field(_programme, 'Programme / Department *', Icons.school_outlined, (v) => v.length < 2 ? 'Enter your programme or department.' : null, hint: 'e.g. B.Tech CSE, 3rd year'),
        _field(_email, 'Email *', Icons.email_outlined,
            (v) => RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(v) ? null : 'Enter a valid email address.',
            keyboard: TextInputType.emailAddress),
        _field(_phone, 'Mobile number *', Icons.phone_outlined,
            (v) => RegExp(r'^\+?[0-9 ]{8,15}$').hasMatch(v) ? null : 'Enter a valid mobile number.',
            keyboard: TextInputType.phone, hint: '+91 98xxxxxxx'),
      ]);

  Widget _facilityPicker() {
    final f = _facility;
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      DropdownButtonFormField<String>(
        initialValue: _facilityId,
        decoration: const InputDecoration(labelText: 'Facility *', prefixIcon: Icon(Icons.meeting_room_outlined)),
        items: FacilityCatalog.all
            .map((f) => DropdownMenuItem(value: f.id, child: Text('${f.name}  (up to ${f.capacity})')))
            .toList(),
        onChanged: (v) => setState(() => _facilityId = v),
        validator: (v) => v == null ? 'Missing field: choose a facility.' : null,
      ),
      if (f != null) ...[
        const SizedBox(height: 12),
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: SizedBox(
            height: 110,
            child: Stack(fit: StackFit.expand, children: [
              Image.network(f.imageUrl, fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Container(color: AppTheme.paleRed, child: const Icon(Icons.business, size: 36, color: AppTheme.red))),
              Container(color: Colors.black.withValues(alpha: .5)),
              Positioned(left: 14, right: 14, bottom: 12, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(f.name, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
                Text('${f.location} • capacity ${f.capacity}', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              ])),
            ]),
          ),
        ),
      ],
    ]);
  }

  Widget _scheduleFields() {
    final touched = _facilityId != null || _date != null || _startTime != null || _duration != null;
    final issue = touched || _attemptedSubmit ? _slotIssue : null;
    final start = _start, end = _end;
    final daySlots = _date == null || _facilityId == null
        ? <BookingSlot>[]
        : _knownSlots
            .where((s) => s.facilityId == _facilityId && s.start.year == _date!.year && s.start.month == _date!.month && s.start.day == _date!.day)
            .toList()
      ..sort((a, b) => a.start.compareTo(b.start));
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Wrap(spacing: 10, runSpacing: 10, children: [
        OutlinedButton.icon(onPressed: _pickDate, icon: const Icon(Icons.calendar_month), label: Text(_date == null ? 'Booking date *' : BookingFormat.date(_date!))),
        OutlinedButton.icon(onPressed: _pickTime, icon: const Icon(Icons.schedule), label: Text(_startTime == null ? 'Start time *' : 'Starts ${_startTime!.format(context)}')),
      ]),
      const SizedBox(height: 14),
      const Text('Duration *', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
      const SizedBox(height: 8),
      Wrap(spacing: 8, runSpacing: 8, children: FacilityCatalog.durations
          .map((m) => ChoiceChip(label: Text('$m minutes'), selected: _duration == m, onSelected: (_) => setState(() => _duration = m)))
          .toList()),
      const SizedBox(height: 12),
      Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: .06), borderRadius: BorderRadius.circular(12)),
        child: Text(
          start != null && end != null
              ? 'Start: ${BookingFormat.dateTime(start)}\nEnd:   ${BookingFormat.dateTime(end)}'
              : 'Pick a date, start time and duration to see the start and end time.',
          style: const TextStyle(fontSize: 13, height: 1.5, fontWeight: FontWeight.w600),
        ),
      ),
      const SizedBox(height: 8),
      Text('Open daily 08:00 – 22:00. Book from today through the next ${FacilityCatalog.maxAdvanceDays} days.',
          style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
      if (issue != null) ...[
        const SizedBox(height: 8),
        Row(children: [const Icon(Icons.error_outline, size: 16, color: AppTheme.red), const SizedBox(width: 6), Expanded(child: Text(issue, style: const TextStyle(color: AppTheme.red, fontSize: 12)))]),
      ],
      if (_date != null && _facility != null) ...[
        const SizedBox(height: 12),
        Text('${_facility!.name} on ${BookingFormat.date(_date!)}', style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 13)),
        const SizedBox(height: 6),
        if (daySlots.isEmpty)
          const Text('No bookings yet. The whole day is open.', style: TextStyle(fontSize: 12, color: AppTheme.success))
        else
          Wrap(spacing: 8, runSpacing: 8, children: daySlots
              .map((s) => Chip(avatar: const Icon(Icons.block, size: 16), label: Text('Booked ${BookingFormat.time(s.start)} – ${BookingFormat.time(s.end)}'), visualDensity: VisualDensity.compact))
              .toList()),
      ],
    ]);
  }

  Widget _eventFields() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        _twoColumn([
          _field(_eventTitle, 'Event / activity name *', Icons.title, (v) => v.length < 3 ? 'Enter the event or activity name.' : null),
          DropdownButtonFormField<String>(
            initialValue: _activityType,
            decoration: const InputDecoration(labelText: 'Activity type *', prefixIcon: Icon(Icons.category_outlined)),
            items: FacilityCatalog.activityTypes.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
            onChanged: (v) => setState(() => _activityType = v),
            validator: (v) => v == null ? 'Select the activity type.' : null,
          ),
          _field(_attendees, 'Expected attendees *', Icons.groups_outlined, (v) {
            final n = int.tryParse(v);
            if (n == null || n < 1) return 'Enter the number of attendees.';
            final f = _facility;
            if (f != null && n > f.capacity) return '${f.name} holds up to ${f.capacity}.';
            return null;
          }, keyboard: TextInputType.number),
          _field(_coordinator, 'Faculty in-charge / coordinator', Icons.supervisor_account_outlined, (_) => null, hint: 'Required for club and cultural events'),
        ]),
        const SizedBox(height: 12),
        _field(_purpose, 'Purpose / description *', Icons.notes_outlined,
            (v) => v.length < 20 ? 'Describe the purpose in at least 20 characters.' : null,
            maxLines: 4, maxLength: 1000, hint: 'What will the facility be used for?'),
      ]);

  Widget _requirementFields() => Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
        const Text('Equipment needed', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
        const SizedBox(height: 8),
        Wrap(spacing: 8, runSpacing: 8, children: FacilityCatalog.equipment
            .map((e) => FilterChip(
                  label: Text(e),
                  selected: _equipment.contains(e),
                  onSelected: (on) => setState(() => on ? _equipment.add(e) : _equipment.remove(e)),
                ))
            .toList()),
        const SizedBox(height: 14),
        _field(_special, 'Special requirements (optional)', Icons.info_outline, (_) => null, maxLines: 2, maxLength: 500,
            hint: 'Seating layout, cleaning, security, catering permission…'),
      ]);

  Widget _undertaking() => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text(
          '• I will use the facility only for the purpose stated above.\n'
          '• I am responsible for the conduct of attendees and for any damage to university property.\n'
          '• I will leave the facility clean and vacate it on time.\n'
          '• I understand the booking is valid only after approval and may be withdrawn for university events.',
          style: TextStyle(fontSize: 13, height: 1.5),
        ),
        CheckboxListTile(
          value: _declaration,
          onChanged: (v) => setState(() => _declaration = v ?? false),
          contentPadding: EdgeInsets.zero,
          controlAffinity: ListTileControlAffinity.leading,
          title: const Text('I agree to the terms above and confirm the details are correct. *'),
        ),
        if (_attemptedSubmit && !_declaration)
          const Text('Please accept the undertaking before submitting.', style: TextStyle(color: AppTheme.red, fontSize: 12)),
      ]);

  Widget _summaryCard() {
    final start = _start, end = _end;
    Widget row(String label, bool done) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Row(children: [
            Icon(done ? Icons.check_circle : Icons.radio_button_unchecked, size: 18, color: done ? AppTheme.success : AppTheme.muted),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
          ]),
        );
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Text('Booking summary', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          const SizedBox(height: 12),
          Text(_facility?.name ?? 'No facility selected', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
          if (_facility != null) Text('${_facility!.location} • capacity ${_facility!.capacity}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          const SizedBox(height: 8),
          Text(start != null && end != null ? '${BookingFormat.date(start)}\n${BookingFormat.time(start)} – ${BookingFormat.time(end)}' : 'Date and time not selected', style: const TextStyle(fontSize: 13)),
          const Divider(height: 26),
          row('Applicant details', _name.text.trim().isNotEmpty && _studentId.text.trim().isNotEmpty && _phone.text.trim().isNotEmpty),
          row('Facility, date & time', start != null && end != null && _slotIssue == null),
          row('Event details', _eventTitle.text.trim().isNotEmpty && _activityType != null && _attendees.text.trim().isNotEmpty),
          row('Undertaking', _declaration),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(color: AppTheme.info.withValues(alpha: .06), borderRadius: BorderRadius.circular(10)),
            child: const Text('After you submit, the request shows as "Pending review". Once the facility office approves it, a confirmation number and slip appear under My requests.',
                style: TextStyle(fontSize: 11, color: AppTheme.muted, height: 1.4)),
          ),
        ]),
      ),
    );
  }

  Widget _myRequestsView() {
    if (_myError != null) {
      return _empty(Icons.cloud_off_outlined, 'Could not load your requests. Check your connection and that the latest firestore.rules are deployed.');
    }
    if (_myBookings.isEmpty) {
      return _empty(Icons.event_available_outlined, 'No booking requests yet. Use "New request" to book a facility.');
    }
    return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: _myBookings.map((b) {
      final color = bookingStatusColor(b.status);
      return Card(
        margin: const EdgeInsets.only(bottom: 10),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: () => _showDetails(b),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                CircleAvatar(backgroundColor: color.withValues(alpha: .12), child: Icon(Icons.meeting_room_outlined, color: color)),
                const SizedBox(width: 12),
                Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(b.eventTitle, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
                  Text('${b.facilityName} • ${BookingFormat.slot(b.startAt, b.endAt)}', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
                ])),
                BookingStatusChip(b.status),
              ]),
              if (b.confirmationNo.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text('Confirmation no. ${b.confirmationNo}', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.success)),
              ],
              if (b.adminRemarks.isNotEmpty) ...[
                const SizedBox(height: 8),
                Text('Admin remarks: ${b.adminRemarks}', style: const TextStyle(fontSize: 12)),
              ],
              const SizedBox(height: 8),
              Wrap(spacing: 8, children: [
                TextButton.icon(onPressed: () => _showDetails(b), icon: Icon(b.status == FacilityBookingStatus.approved ? Icons.receipt_long_outlined : Icons.visibility_outlined, size: 18),
                    label: Text(b.status == FacilityBookingStatus.approved ? 'View confirmation' : 'View details')),
                if (b.status == FacilityBookingStatus.pending)
                  TextButton.icon(onPressed: () => _cancel(b), icon: const Icon(Icons.cancel_outlined, size: 18), label: const Text('Cancel request'), style: TextButton.styleFrom(foregroundColor: AppTheme.red)),
              ]),
            ]),
          ),
        ),
      );
    }).toList());
  }

  Widget _empty(IconData icon, String text) => Card(
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
