import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class AdminEventsPage extends StatelessWidget {
  const AdminEventsPage({super.key});
  @override
  Widget build(BuildContext context) => PageContainer(
    title: 'Events',
    subtitle: 'Live campus calendar events saved in Firebase Firestore.',
    child: StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance.collection('calendarEvents').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) return _state(Icons.cloud_off_outlined, 'Could not load campus events. Check Firestore permissions.');
        if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(28), child: CircularProgressIndicator()));
        final docs = (snapshot.data?.docs ?? []).toList()..sort((a, b) {
          final av = a.data()['eventDate']; final bv = b.data()['eventDate'];
          final ad = av is Timestamp ? av.toDate() : DateTime(2100);
          final bd = bv is Timestamp ? bv.toDate() : DateTime(2100);
          return ad.compareTo(bd);
        });
        if (docs.isEmpty) return _state(Icons.event_busy_outlined, 'No campus events have been published yet. Add an event in the shared Calendar screen to show it here and on the student dashboard.');
        return Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
          Text('${docs.length} event${docs.length == 1 ? '' : 's'}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...docs.map((doc) {
            final d = doc.data(); final dateValue = d['eventDate'];
            final date = dateValue is Timestamp ? dateValue.toDate().toLocal() : null;
            final dateText = date == null ? 'Date not set' : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
            return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
              leading: const CircleAvatar(backgroundColor: AppTheme.paleRed, child: Icon(Icons.event_outlined, color: AppTheme.red)),
              title: Text((d['title'] ?? 'Campus event').toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
              subtitle: Text('$dateText • ${(d['category'] ?? 'Campus').toString()}\n${(d['location'] ?? 'Location not set').toString()}\n${(d['description'] ?? '').toString()}', maxLines: 3, overflow: TextOverflow.ellipsis),
              isThreeLine: true,
            ));
          }),
        ]);
      },
    ),
  );
  Widget _state(IconData icon, String text) => Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(icon, size: 40, color: AppTheme.muted), const SizedBox(height: 10), Text(text, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted))])));
}
