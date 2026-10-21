import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

class CalendarPage extends StatefulWidget {
  const CalendarPage({super.key});
  @override
  State<CalendarPage> createState() => _CalendarPageState();
}

class _CalendarPageState extends State<CalendarPage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  bool _saving = false;

  Future<String> _ensureUser() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final result = await _auth.signInAnonymously();
    if (result.user == null) throw StateError('Firebase Authentication did not return a user.');
    return result.user!.uid;
  }

  Future<void> _addEvent() async {
    final key = GlobalKey<FormState>();
    final title = TextEditingController();
    final location = TextEditingController();
    final description = TextEditingController();
    DateTime selectedDate = DateTime.now();
    String category = 'Academic';
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => StatefulBuilder(builder: (context, setDialogState) => AlertDialog(
      title: const Text('Add calendar event'),
      content: SizedBox(width: 480, child: Form(key: key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: title, decoration: const InputDecoration(labelText: 'Event title *'), validator: (v) => (v?.trim().length ?? 0) < 3 ? 'Enter at least 3 characters.' : null),
        const SizedBox(height: 10),
        TextFormField(controller: location, decoration: const InputDecoration(labelText: 'Location'), validator: (v) => (v?.trim().length ?? 0) > 120 ? 'Keep location under 120 characters.' : null),
        const SizedBox(height: 10),
        TextFormField(controller: description, maxLines: 3, decoration: const InputDecoration(labelText: 'Details *'), validator: (v) => (v?.trim().length ?? 0) < 10 ? 'Enter at least 10 characters.' : null),
        const SizedBox(height: 12),
        DropdownButtonFormField<String>(initialValue: category, decoration: const InputDecoration(labelText: 'Category'), items: const ['Academic', 'Exam', 'Club', 'Campus', 'Deadline'].map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(), onChanged: (v) { if (v != null) setDialogState(() => category = v); }),
        const SizedBox(height: 12),
        OutlinedButton.icon(onPressed: () async { final picked = await showDatePicker(context: context, initialDate: selectedDate, firstDate: DateTime(2020), lastDate: DateTime(2100)); if (picked != null) setDialogState(() => selectedDate = picked); }, icon: const Icon(Icons.calendar_month_outlined), label: Text('Date: ${selectedDate.year}-${selectedDate.month.toString().padLeft(2, '0')}-${selectedDate.day.toString().padLeft(2, '0')}')),
        const SizedBox(height: 8),
        const Text('This event will be stored in Firebase Cloud Firestore.', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () { if (key.currentState?.validate() ?? false) Navigator.pop(dialogContext, true); }, child: const Text('Save event'))],
    )));
    if (accepted != true || !mounted) { title.dispose(); location.dispose(); description.dispose(); return; }
    setState(() => _saving = true);
    try {
      final uid = await _ensureUser();
      await _firestore.collection('calendarEvents').add({
        'ownerUid': uid, 'title': title.text.trim(), 'location': location.text.trim(),
        'description': description.text.trim(), 'category': category,
        'eventDate': Timestamp.fromDate(DateTime(selectedDate.year, selectedDate.month, selectedDate.day)),
        'createdAt': FieldValue.serverTimestamp(), 'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event saved to Firebase.')));
    } catch (error) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save event: $error')));
    } finally {
      title.dispose(); location.dispose(); description.dispose();
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    backgroundColor: AppTheme.bg,
    appBar: AppBar(title: const Text('Calendar'), leading: IconButton(tooltip: 'Back', icon: const Icon(Icons.arrow_back), onPressed: () => Navigator.of(context).maybePop()), actions: [IconButton(tooltip: 'Home', icon: const Icon(Icons.home_outlined), onPressed: () => Navigator.of(context).popUntil((route) => route.isFirst))]),
    body: Center(child: ConstrainedBox(constraints: const BoxConstraints(maxWidth: 1000), child: Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      Row(children: [const Expanded(child: Text('Campus events', style: TextStyle(fontSize: 24, fontWeight: FontWeight.w800, color: AppTheme.navy)),), FilledButton.icon(onPressed: _saving ? null : _addEvent, icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(_saving ? 'Saving…' : 'Add Event'))]),
      const SizedBox(height: 14),
      Expanded(child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _firestore.collection('calendarEvents').orderBy('eventDate').snapshots(), builder: (context, snapshot) {
        if (snapshot.hasError) return Center(child: Text('Could not load Firebase events: ${snapshot.error}'));
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: CircularProgressIndicator());
        final docs = snapshot.data?.docs ?? [];
        if (docs.isEmpty) return const Center(child: Text('No calendar events yet. Add an event to save it to Firebase.'));
        return ListView.separated(itemCount: docs.length, separatorBuilder: (context, index) => const SizedBox(height: 8), itemBuilder: (context, index) {
          final doc = docs[index]; final data = doc.data(); final date = data['eventDate'];
          final dateText = date is Timestamp ? date.toDate().toLocal().toString().substring(0, 10) : 'Date pending';
          return Card(child: ListTile(leading: const CircleAvatar(child: Icon(Icons.event_outlined)), title: Text((data['title'] ?? 'Event').toString(), style: const TextStyle(fontWeight: FontWeight.w700)), subtitle: Text('$dateText • ${(data['category'] ?? 'Campus')}\n${(data['location'] ?? '').toString()}\n${(data['description'] ?? '').toString()}'), isThreeLine: true, trailing: IconButton(tooltip: 'Delete event', icon: const Icon(Icons.delete_outline), onPressed: () async { final uid = await _ensureUser(); if (data['ownerUid'] != uid) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Only the event creator can delete this event.'))); return; } await doc.reference.delete(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Event deleted from Firebase.'))); })));
        });
      })),
    ])))),
  );
}
