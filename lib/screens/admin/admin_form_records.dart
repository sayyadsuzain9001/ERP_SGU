import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Admin-only live view of campus service requests stored in Firestore.
class AdminFormRecordsPage extends StatefulWidget {
  const AdminFormRecordsPage({super.key});

  @override
  State<AdminFormRecordsPage> createState() => _AdminFormRecordsPageState();
}

class _AdminFormRecordsPageState extends State<AdminFormRecordsPage> {
  final _search = TextEditingController();
  String _status = 'All';
  String _category = 'All';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PageContainer(
      title: 'Form Submission Records',
      subtitle: 'Live records retrieved from the campusRequests collection in Firebase Firestore.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Card(
            child: Padding(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.cloud_done_outlined, color: AppTheme.red),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Firebase records',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppTheme.navy),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'This page reads actual submitted records. It does not generate demo student data.',
                    style: TextStyle(color: AppTheme.muted),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _search,
                    onChanged: (_) => setState(() {}),
                    decoration: const InputDecoration(
                      labelText: 'Search student, student ID, subject or email',
                      prefixIcon: Icon(Icons.search),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 12,
                    runSpacing: 10,
                    children: [
                      SizedBox(
                        width: 220,
                        child: DropdownButtonFormField<String>(
                          initialValue: _status,
                          decoration: const InputDecoration(labelText: 'Status'),
                          items: const ['All', 'submitted', 'in_review', 'resolved', 'rejected']
                              .map((value) => DropdownMenuItem(value: value, child: Text(value == 'All' ? value : value.replaceAll('_', ' ').toUpperCase())))
                              .toList(),
                          onChanged: (value) => setState(() => _status = value ?? 'All'),
                        ),
                      ),
                      SizedBox(
                        width: 260,
                        child: DropdownButtonFormField<String>(
                          initialValue: _category,
                          decoration: const InputDecoration(labelText: 'Service category'),
                          items: const [
                            'All', 'Accommodation', 'IT Helpdesk', 'Library Services',
                            'Student Counselling', 'Career Services',
                          ].map((value) => DropdownMenuItem(value: value, child: Text(value))).toList(),
                          onChanged: (value) => setState(() => _category = value ?? 'All'),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance.collection('campusRequests').orderBy('createdAt', descending: true).snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _state(Icons.lock_outline, 'Unable to retrieve records. Verify that the signed-in user has the trusted admin role and that Firestore rules allow admin list access.');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(child: Padding(padding: EdgeInsets.all(32), child: Center(child: CircularProgressIndicator())));
              }
              final docs = snapshot.data?.docs ?? [];
              final query = _search.text.trim().toLowerCase();
              final records = docs.where((doc) {
                final data = doc.data();
                final values = [
                  data['studentName'], data['studentId'], data['email'],
                  data['subject'], data['serviceCategory'], doc.id,
                ].map((value) => (value ?? '').toString().toLowerCase());
                final matchesSearch = query.isEmpty || values.any((value) => value.contains(query));
                final matchesStatus = _status == 'All' || data['status'] == _status;
                final matchesCategory = _category == 'All' || data['serviceCategory'] == _category;
                return matchesSearch && matchesStatus && matchesCategory;
              }).toList();

              final pending = docs.where((doc) => (doc.data()['status'] ?? 'submitted') == 'submitted').length;
              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final columns = constraints.maxWidth >= 800 ? 3 : 1;
                      return GridView.count(
                        crossAxisCount: columns,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        mainAxisSpacing: 10,
                        crossAxisSpacing: 10,
                        childAspectRatio: columns == 1 ? 4.4 : 3.2,
                        children: [
                          _metric('Total records', docs.length.toString(), Icons.storage_outlined),
                          _metric('Awaiting review', pending.toString(), Icons.pending_actions_outlined),
                          _metric('Filtered results', records.length.toString(), Icons.filter_alt_outlined),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    _state(Icons.inbox_outlined, docs.isEmpty ? 'No campus requests have been submitted yet.' : 'No records match these search filters.')
                  else
                    ...records.map((doc) => _recordCard(doc.id, doc.data())),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _metric(String title, String value, IconData icon) => Card(
    child: Padding(
      padding: const EdgeInsets.all(16),
      child: Row(children: [
        Icon(icon, color: AppTheme.red, size: 28),
        const SizedBox(width: 12),
        Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
          const SizedBox(height: 4),
          Text(value, style: const TextStyle(color: AppTheme.navy, fontWeight: FontWeight.w900, fontSize: 24)),
        ])),
      ]),
    ),
  );

  Widget _recordCard(String id, Map<String, dynamic> data) {
    final created = data['createdAt'];
    final createdLabel = created is Timestamp ? created.toDate().toLocal().toString().substring(0, 16) : 'Timestamp pending';
    final status = (data['status'] ?? 'submitted').toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(backgroundColor: AppTheme.red.withValues(alpha: .08), child: const Icon(Icons.assignment_outlined, color: AppTheme.red)),
        title: Text((data['studentName'] ?? 'Unknown student').toString(), style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
        subtitle: Text('${data['studentId'] ?? 'No student ID'} • ${data['subject'] ?? 'No subject'}'),
        trailing: Chip(label: Text(status.replaceAll('_', ' '))),
        childrenPadding: const EdgeInsets.fromLTRB(18, 0, 18, 18),
        children: [
          const Divider(),
          _detail('Request reference', id),
          _detail('Student name', data['studentName']),
          _detail('Student ID', data['studentId']),
          _detail('Email', data['email']),
          _detail('Phone', data['phone']),
          _detail('Service category', data['serviceCategory']),
          _detail('Subject', data['subject']),
          _detail('Description', data['description']),
          _detail('Urgency', data['urgency']),
          _detail('Preferred contact', data['preferredContact']),
          _detail('Preferred date', _date(data['preferredDate'])),
          _detail('Declaration accepted', data['declaration'] == true ? 'Yes' : 'No'),
          _detail('Submitted at', createdLabel),
          if (data['adminNote'] != null) _detail('Admin note', data['adminNote']),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(spacing: 8, children: [
              OutlinedButton.icon(
                onPressed: () => _updateStatus(id, 'in_review'),
                icon: const Icon(Icons.visibility_outlined),
                label: const Text('Mark in review'),
              ),
              FilledButton.icon(
                onPressed: () => _updateStatus(id, 'resolved'),
                icon: const Icon(Icons.check_circle_outline),
                label: const Text('Resolve'),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  String _date(dynamic value) {
    if (value is Timestamp) return value.toDate().toLocal().toString().split(' ').first;
    return value?.toString() ?? 'Not provided';
  }

  Widget _detail(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 165, child: Text(label, style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w600))),
      Expanded(child: SelectableText(value?.toString() ?? '—')),
    ]),
  );

  Widget _state(IconData icon, String message) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(children: [Icon(icon, size: 36, color: AppTheme.muted), const SizedBox(height: 12), Text(message, textAlign: TextAlign.center)]),
    ),
  );

  Future<void> _updateStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance.collection('campusRequests').doc(id).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Request marked ${status.replaceAll('_', ' ')}.')));
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not update status (${error.code}). Check admin permissions and Firestore rules.')));
      }
    }
  }
}
