import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class StudentEventsPage extends StatelessWidget {
  const StudentEventsPage({super.key});

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    return PageContainer(
      title: 'My Events',
      subtitle: 'Events you saved are synced with Firebase Firestore.',
      actions: [FilledButton.icon(onPressed: () => Navigator.pushNamed(context, AppRoutes.events), icon: const Icon(Icons.explore_outlined), label: const Text('Browse Campus Events'))],
      child: user == null
          ? const Card(child: Padding(padding: EdgeInsets.all(20), child: Text('Sign in to view your saved events.')))
          : StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance.collection('myEvents').where('ownerUid', isEqualTo: user.uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) return Card(child: Padding(padding: const EdgeInsets.all(20), child: Text('Could not load saved events from Firebase: ${snapshot.error}')));
                if (snapshot.connectionState == ConnectionState.waiting) return const Center(child: Padding(padding: EdgeInsets.all(24), child: CircularProgressIndicator()));
                final docs = snapshot.data?.docs ?? [];
                if (docs.isEmpty) return Card(child: Padding(padding: const EdgeInsets.all(24), child: Column(children: [const Icon(Icons.event_available_outlined, size: 42, color: AppTheme.muted), const SizedBox(height: 10), const Text('No saved events yet.', style: TextStyle(fontWeight: FontWeight.w800)), const SizedBox(height: 6), const Text('Browse campus events and use “Add to My Events” to save one here.', textAlign: TextAlign.center, style: TextStyle(color: AppTheme.muted)), const SizedBox(height: 14), FilledButton(onPressed: () => Navigator.pushNamed(context, AppRoutes.events), child: const Text('Browse events'))])));
                return Column(children: docs.map((doc) {
                  final data = doc.data();
                  return Card(margin: const EdgeInsets.only(bottom: 10), child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.event_outlined)),
                    title: Text((data['title'] ?? 'Campus event').toString(), style: const TextStyle(fontWeight: FontWeight.w800)),
                    subtitle: Text('${data['dateLabel'] ?? 'Date pending'} • ${data['time'] ?? 'Time pending'}\n${data['location'] ?? ''}\n${data['category'] ?? ''}', maxLines: 3, overflow: TextOverflow.ellipsis),
                    isThreeLine: true,
                    trailing: IconButton(tooltip: 'Remove saved event', icon: const Icon(Icons.delete_outline), onPressed: () async { try { await doc.reference.delete(); if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Removed from My Events.'))); } catch (e) { if (context.mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not remove event: $e'))); } }),
                  ));
                }).toList());
              },
            ),
    );
  }
}
