import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../models/models.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

class EventDetailScreen extends StatefulWidget {
  final CampusEventItem event;
  const EventDetailScreen({super.key, required this.event});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  bool _saving = false;

  Future<void> _registerForEvent() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please sign in before registering.')));
      return;
    }
    final profile = <String, dynamic>{};
    try {
      final snap = await FirebaseFirestore.instance.collection('users').doc(user.uid).get();
      profile.addAll(snap.data() ?? {});
    } catch (_) {
      // Authentication details can still prefill the form if profile rules are not deployed yet.
    }
    // The profile read above is asynchronous. Do not use this State's context
    // if the user navigated away while the read was in progress.
    if (!mounted) return;

    final name = TextEditingController(text: (profile['name'] ?? user.displayName ?? '').toString());
    final studentId = TextEditingController(text: (profile['studentId'] ?? '').toString());
    final email = TextEditingController(text: user.email ?? (profile['email'] ?? '').toString());
    final phone = TextEditingController(text: (profile['phone'] ?? '').toString());
    final key = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Event registration'),
      content: SizedBox(width: 460, child: SingleChildScrollView(child: Form(key: key, child: Column(mainAxisSize: MainAxisSize.min, children: [
        Align(alignment: Alignment.centerLeft, child: Text(widget.event.title, style: const TextStyle(fontWeight: FontWeight.w800))),
        const SizedBox(height: 8),
        const Align(alignment: Alignment.centerLeft, child: Text('Your account details are filled in automatically. Please check them before confirming.', style: TextStyle(fontSize: 12, color: Colors.blueGrey))),
        const SizedBox(height: 14),
        TextFormField(controller: name, decoration: const InputDecoration(labelText: 'Full name'), validator: (v) => (v?.trim().length ?? 0) < 3 ? 'Enter your full name.' : null),
        const SizedBox(height: 10),
        TextFormField(controller: studentId, decoration: const InputDecoration(labelText: 'Student ID'), validator: (v) => (v?.trim().isEmpty ?? true) ? 'Enter your student ID.' : null),
        const SizedBox(height: 10),
        TextFormField(controller: email, keyboardType: TextInputType.emailAddress, decoration: const InputDecoration(labelText: 'Email'), validator: (v) => (v?.contains('@') ?? false) ? null : 'Enter a valid email.'),
        const SizedBox(height: 10),
        TextFormField(controller: phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone (optional)')),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton.icon(onPressed: () { if (key.currentState?.validate() ?? false) Navigator.pop(dialogContext, true); }, icon: const Icon(Icons.how_to_reg_outlined), label: const Text('Confirm registration'))],
    ));
    if (accepted == true && mounted) {
      setState(() => _saving = true);
      try {
        final registrationRef = FirebaseFirestore.instance.collection('eventRegistrations').doc('${user.uid}_${widget.event.id}');
        await registrationRef.set({
          'ownerUid': user.uid,
          'eventId': widget.event.id,
          'eventTitle': widget.event.title,
          'eventDate': widget.event.dateLabel,
          'eventTime': widget.event.time,
          'eventLocation': widget.event.location,
          'studentName': name.text.trim(),
          'studentId': studentId.text.trim(),
          'email': email.text.trim(),
          'phone': phone.text.trim(),
          'status': 'registered',
          'registeredAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        await FirebaseFirestore.instance.collection('myEvents').doc('${user.uid}_${widget.event.id}').set({
          'ownerUid': user.uid, 'eventId': widget.event.id, 'title': widget.event.title,
          'dateLabel': widget.event.dateLabel, 'time': widget.event.time, 'location': widget.event.location,
          'category': widget.event.category, 'description': widget.event.description,
          'registrationId': registrationRef.id, 'createdAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
        if (mounted) {
          await showDialog<void>(
            context: context,
            builder: (ctx) => AlertDialog(
              icon: const Icon(Icons.check_circle_outline, color: Color(0xFF238454), size: 42),
              title: const Text('Registration confirmed'),
              content: Text('You are registered for ${widget.event.title}. The event is now saved in My Events.'),
              actions: [FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Done'))],
            ),
          );
        }
      } on FirebaseException catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Registration could not be saved (${e.code}). Check Firestore rules for eventRegistrations.')));
      } finally { if (mounted) setState(() => _saving = false); }
    }
    name.dispose(); studentId.dispose(); email.dispose(); phone.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final event = widget.event;
    return RoutePageFrame(
      title: event.title,
      subtitle: event.category,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        ClipRRect(borderRadius: BorderRadius.circular(22), child: SizedBox(height: 330, width: double.infinity, child: Stack(fit: StackFit.expand, children: [
          Image.network(_eventImage(event.category), fit: BoxFit.cover, errorBuilder: (_, error, stack) => Container(color: AppTheme.navy, child: Icon(event.icon, size: 52, color: Colors.white))),
          const DecoratedBox(decoration: BoxDecoration(gradient: LinearGradient(begin: Alignment.topCenter, end: Alignment.bottomCenter, colors: [Colors.transparent, Color(0xCC151515)]))),
          Positioned(left: 24, right: 24, bottom: 24, child: Text(event.title, style: const TextStyle(color: Colors.white, fontSize: 32, fontWeight: FontWeight.w800))),
        ]))),
        const SizedBox(height: 18),
        Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(width: 58, height: 58, decoration: BoxDecoration(color: AppTheme.paleRed, borderRadius: BorderRadius.circular(14)), child: Icon(event.icon, color: AppTheme.red, size: 30)),
        const SizedBox(height: 18),
        Text(event.title, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.ink)),
        const SizedBox(height: 12),
        Text(event.description, style: const TextStyle(fontSize: 13, color: AppTheme.muted, height: 1.5)),
        const SizedBox(height: 18),
        DetailRow(icon: Icons.calendar_today_outlined, label: 'Date', value: event.dateLabel),
        DetailRow(icon: Icons.schedule_outlined, label: 'Time', value: event.time),
        DetailRow(icon: Icons.location_on_outlined, label: 'Location', value: event.location),
        const SizedBox(height: 16),
        Wrap(spacing: 10, runSpacing: 10, children: [
          FilledButton.icon(onPressed: _saving ? null : _registerForEvent, icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.how_to_reg_outlined), label: Text(_saving ? 'Registering…' : 'Register for Event')),
          OutlinedButton.icon(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back to Events')),
        ]),
      ]))),
      ]),
    );
  }

  String _eventImage(String category) {
    final value = category.toLowerCase();
    if (value.contains('career')) return 'https://images.unsplash.com/photo-1521737711867-e3b97375f902?auto=format&fit=crop&w=1400&q=85';
    if (value.contains('sport')) return 'https://images.unsplash.com/photo-1517649763962-0c623066013b?auto=format&fit=crop&w=1400&q=85';
    if (value.contains('workshop') || value.contains('technology')) return 'https://images.unsplash.com/photo-1516321318423-f06f85e504b3?auto=format&fit=crop&w=1400&q=85';
    return 'https://images.unsplash.com/photo-1540575467063-178a50c2df87?auto=format&fit=crop&w=1400&q=85';
  }

}
