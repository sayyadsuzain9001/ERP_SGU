import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Admin dashboard backed by Firestore snapshots. Counts update when records
/// are created, changed or removed in Firebase; no invented metrics are shown.
class AdminDashboardPage extends StatelessWidget {
  const AdminDashboardPage({super.key, required this.onNavigate});

  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => PageContainer(
    title: 'University Administration',
    subtitle: 'Live overview of academic and campus service records.',
    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      LayoutBuilder(builder: (context, constraints) => GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: constraints.maxWidth > 1000 ? 4 : (constraints.maxWidth > 560 ? 2 : 1),
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: constraints.maxWidth > 560 ? 2.1 : 3.1,
        children: [
          _LiveCountCard(title: 'Students', icon: Icons.people_outline, stream: FirebaseFirestore.instance.collection('users').snapshots(), count: (docs) => docs.where((d) { final x = d.data(); return (x['accountType'] ?? x['requestedRole'] ?? '').toString().toLowerCase() == 'student'; }).length, onTap: () => onNavigate('Students')),
          _LiveCountCard(title: 'Teachers', icon: Icons.co_present_outlined, stream: FirebaseFirestore.instance.collection('users').snapshots(), count: (docs) => docs.where((d) { final x = d.data(); return (x['accountType'] ?? x['requestedRole'] ?? '').toString().toLowerCase() == 'teacher'; }).length, onTap: () => onNavigate('Teachers')),
          _LiveCountCard(title: 'Courses', icon: Icons.school_outlined, stream: FirebaseFirestore.instance.collection('formSubmissions').where('module', isEqualTo: 'Courses').snapshots(), count: (docs) => docs.length, onTap: () => onNavigate('Courses')),
          _LiveCountCard(title: 'Requests', icon: Icons.support_agent_outlined, stream: FirebaseFirestore.instance.collection('campusRequests').snapshots(), count: (docs) => docs.length, onTap: () => onNavigate('Form Records')),
        ],
      )),
      const SizedBox(height: 20),
      LayoutBuilder(builder: (context, constraints) => constraints.maxWidth > 850
        ? Row(crossAxisAlignment: CrossAxisAlignment.start, children: [Expanded(child: _LiveActivity(onNavigate: onNavigate)), const SizedBox(width: 14), Expanded(child: _AdminActions(onNavigate: onNavigate))])
        : Column(children: [_LiveActivity(onNavigate: onNavigate), const SizedBox(height: 14), _AdminActions(onNavigate: onNavigate)])),
    ]),
  );
}

class _LiveCountCard extends StatelessWidget {
  const _LiveCountCard({required this.title, required this.icon, required this.stream, required this.count, required this.onTap});
  final String title;
  final IconData icon;
  final Stream<QuerySnapshot<Map<String, dynamic>>> stream;
  final int Function(List<QueryDocumentSnapshot<Map<String, dynamic>>>) count;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Card(child: InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(12),
    child: Padding(padding: const EdgeInsets.all(16), child: Row(children: [
      Icon(icon, color: AppTheme.red), const SizedBox(width: 12),
      Expanded(child: Text(title, style: const TextStyle(color: AppTheme.muted))),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: stream, builder: (context, snapshot) {
        final label = snapshot.hasError ? 'Unavailable' : snapshot.connectionState == ConnectionState.waiting ? '…' : count(snapshot.data?.docs ?? const [] ).toString();
        return Flexible(child: Text(label, textAlign: TextAlign.end, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy)));
      }),
    ])),
  ));
}

class _LiveActivity extends StatelessWidget {
  const _LiveActivity({required this.onNavigate});
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeader('University Activity'), const SizedBox(height: 8),
    Card(child: Column(children: [
      ListTile(leading: const Icon(Icons.person_outline, color: AppTheme.info), title: const Text('Student directory'), subtitle: const Text('Open current student accounts'), onTap: () => onNavigate('Students')),
      ListTile(leading: const Icon(Icons.school_outlined, color: AppTheme.warning), title: const Text('Course records'), subtitle: const Text('Open course records saved in Firestore'), onTap: () => onNavigate('Courses')),
      ListTile(leading: const Icon(Icons.event_outlined, color: AppTheme.success), title: const Text('Campus calendar'), subtitle: const Text('Review published campus events'), onTap: () => onNavigate('Events')),
    ])),
  ]);
}

class _AdminActions extends StatelessWidget {
  const _AdminActions({required this.onNavigate});
  final ValueChanged<String> onNavigate;

  @override
  Widget build(BuildContext context) => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const SectionHeader('Action Required'), const SizedBox(height: 8),
    EmptyActionCard(icon: Icons.approval_outlined, title: 'Service requests', subtitle: 'Open and review submitted campus service requests.', onTap: () => onNavigate('Form Records')),
    const SizedBox(height: 10),
    EmptyActionCard(icon: Icons.event_available_outlined, title: 'Facility bookings', subtitle: 'Review facility reservations.', onTap: () => onNavigate('Facilities')),
    const SizedBox(height: 10),
    EmptyActionCard(icon: Icons.history_outlined, title: 'Audit review', subtitle: 'Review recent administrative changes.', onTap: () => onNavigate('Audit Logs')),
  ]);
}
