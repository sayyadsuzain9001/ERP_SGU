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
  String _searchBy = 'Student ID';
  DateTime? _fromDate;
  DateTime? _toDate;

  String _searchField(Map<String, dynamic> data, String id) =>
      switch (_searchBy) {
        'Student ID' => (data['studentId'] ?? '').toString(),
        'Student name' => (data['studentName'] ?? '').toString(),
        'Email' => (data['email'] ?? '').toString(),
        'Subject' => (data['subject'] ?? '').toString(),
        _ => id,
      };

  Future<void> _chooseDate({required bool from}) async {
    final today = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: (from ? _fromDate : _toDate) ?? today,
      firstDate: DateTime(2020),
      lastDate: DateTime(today.year + 10),
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (from) {
        _fromDate = DateTime(picked.year, picked.month, picked.day);
      } else {
        _toDate = DateTime(picked.year, picked.month, picked.day, 23, 59, 59);
      }
    });
  }

  String _dateLabel(DateTime? date, String empty) => date == null
      ? empty
      : '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';

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
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy,
                          ),
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
                  const Text(
                    'Search records',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: AppTheme.navy,
                    ),
                  ),
                  const SizedBox(height: 12),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final twoColumns = constraints.maxWidth >= 650;
                      final width = twoColumns
                          ? (constraints.maxWidth - 12) / 2
                          : constraints.maxWidth;
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          SizedBox(
                            width: width,
                            child: DropdownButtonFormField<String>(
                              initialValue: _searchBy,
                              decoration: const InputDecoration(
                                labelText: 'Search by',
                              ),
                              items:
                                  const [
                                        'Student ID',
                                        'Student name',
                                        'Email',
                                        'Subject',
                                      ]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(v),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => _searchBy = v ?? 'Student ID'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: TextField(
                              controller: _search,
                              onChanged: (_) => setState(() {}),
                              decoration: InputDecoration(
                                labelText: 'Search value',
                                hintText: 'Enter ${_searchBy.toLowerCase()}',
                                prefixIcon: const Icon(Icons.search),
                                suffixIcon: _search.text.isEmpty
                                    ? null
                                    : IconButton(
                                        icon: const Icon(Icons.clear),
                                        onPressed: () {
                                          _search.clear();
                                          setState(() {});
                                        },
                                      ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: OutlinedButton.icon(
                              onPressed: () => _chooseDate(from: true),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'From date: ${_dateLabel(_fromDate, 'Select start date')}',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: OutlinedButton.icon(
                              onPressed: () => _chooseDate(from: false),
                              icon: const Icon(Icons.calendar_month_outlined),
                              label: Align(
                                alignment: Alignment.centerLeft,
                                child: Text(
                                  'To date: ${_dateLabel(_toDate, 'Select end date')}',
                                ),
                              ),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 18,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: DropdownButtonFormField<String>(
                              initialValue: _status,
                              decoration: const InputDecoration(
                                labelText: 'Status',
                              ),
                              items:
                                  const [
                                        'All',
                                        'submitted',
                                        'in_review',
                                        'resolved',
                                        'rejected',
                                      ]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(
                                            v == 'All'
                                                ? 'All statuses'
                                                : v
                                                      .replaceAll('_', ' ')
                                                      .toUpperCase(),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => _status = v ?? 'All'),
                            ),
                          ),
                          SizedBox(
                            width: width,
                            child: DropdownButtonFormField<String>(
                              initialValue: _category,
                              decoration: const InputDecoration(
                                labelText: 'Service category',
                              ),
                              items:
                                  const [
                                        'All',
                                        'Accommodation',
                                        'IT Helpdesk',
                                        'Library Services',
                                        'Student Counselling',
                                        'Career Services',
                                      ]
                                      .map(
                                        (v) => DropdownMenuItem(
                                          value: v,
                                          child: Text(
                                            v == 'All' ? 'All categories' : v,
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (v) =>
                                  setState(() => _category = v ?? 'All'),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: OutlinedButton.icon(
                      onPressed: () => setState(() {
                        _search.clear();
                        _searchBy = 'Student ID';
                        _fromDate = null;
                        _toDate = null;
                        _status = 'All';
                        _category = 'All';
                      }),
                      icon: const Icon(Icons.restart_alt),
                      label: const Text('Reset filters'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
          StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
            stream: FirebaseFirestore.instance
                .collection('campusRequests')
                .orderBy('createdAt', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (snapshot.hasError) {
                return _state(
                  Icons.lock_outline,
                  'Unable to retrieve records. Verify that the signed-in user has the trusted admin role and that Firestore rules allow admin list access.',
                );
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Card(
                  child: Padding(
                    padding: EdgeInsets.all(32),
                    child: Center(child: CircularProgressIndicator()),
                  ),
                );
              }
              final docs = snapshot.data?.docs ?? [];
              final query = _search.text.trim().toLowerCase();
              final records = docs.where((doc) {
                final data = doc.data();
                final value = _searchField(data, doc.id).toLowerCase();
                final matchesSearch = query.isEmpty || value.contains(query);
                final matchesStatus =
                    _status == 'All' || data['status'] == _status;
                final matchesCategory =
                    _category == 'All' || data['serviceCategory'] == _category;
                final created = data['createdAt'];
                final createdDate = created is Timestamp
                    ? created.toDate()
                    : created is DateTime
                    ? created
                    : null;
                final matchesFrom =
                    _fromDate == null ||
                    (createdDate != null && !createdDate.isBefore(_fromDate!));
                final matchesTo =
                    _toDate == null ||
                    (createdDate != null && !createdDate.isAfter(_toDate!));
                return matchesSearch &&
                    matchesStatus &&
                    matchesCategory &&
                    matchesFrom &&
                    matchesTo;
              }).toList();

              final pending = docs
                  .where(
                    (doc) =>
                        (doc.data()['status'] ?? 'submitted') == 'submitted',
                  )
                  .length;
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
                          _metric(
                            'Total records',
                            docs.length.toString(),
                            Icons.storage_outlined,
                          ),
                          _metric(
                            'Awaiting review',
                            pending.toString(),
                            Icons.pending_actions_outlined,
                          ),
                          _metric(
                            'Filtered results',
                            records.length.toString(),
                            Icons.filter_alt_outlined,
                          ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  if (records.isEmpty)
                    _state(
                      Icons.inbox_outlined,
                      docs.isEmpty
                          ? 'No campus requests have been submitted yet.'
                          : 'No records match these search filters.',
                    )
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
      child: Row(
        children: [
          Icon(icon, color: AppTheme.red, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(color: AppTheme.muted, fontSize: 12),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    color: AppTheme.navy,
                    fontWeight: FontWeight.w900,
                    fontSize: 24,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ),
  );

  Widget _recordCard(String id, Map<String, dynamic> data) {
    final created = data['createdAt'];
    final createdLabel = created is Timestamp
        ? created.toDate().toLocal().toString().substring(0, 16)
        : 'Timestamp pending';
    final status = (data['status'] ?? 'submitted').toString();
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: ExpansionTile(
        leading: CircleAvatar(
          backgroundColor: AppTheme.red.withValues(alpha: .08),
          child: const Icon(Icons.assignment_outlined, color: AppTheme.red),
        ),
        title: Text(
          (data['studentName'] ?? 'Unknown student').toString(),
          style: const TextStyle(
            fontWeight: FontWeight.w800,
            color: AppTheme.navy,
          ),
        ),
        subtitle: Text(
          '${data['studentId'] ?? 'No student ID'} • ${data['subject'] ?? 'No subject'}',
        ),
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
          _detail(
            'Declaration accepted',
            data['declaration'] == true ? 'Yes' : 'No',
          ),
          _detail('Submitted at', createdLabel),
          if (data['adminNote'] != null)
            _detail('Admin note', data['adminNote']),
          Align(
            alignment: Alignment.centerRight,
            child: Wrap(
              spacing: 8,
              children: [
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
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _date(dynamic value) {
    if (value is Timestamp) {
      return value.toDate().toLocal().toString().split(' ').first;
    }

    return value?.toString() ?? 'Not provided';
  }

  Widget _detail(String label, dynamic value) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 5),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 165,
          child: Text(
            label,
            style: const TextStyle(
              color: AppTheme.muted,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        Expanded(child: SelectableText(value?.toString() ?? '—')),
      ],
    ),
  );

  Widget _state(IconData icon, String message) => Card(
    child: Padding(
      padding: const EdgeInsets.all(28),
      child: Column(
        children: [
          Icon(icon, size: 36, color: AppTheme.muted),
          const SizedBox(height: 12),
          Text(message, textAlign: TextAlign.center),
        ],
      ),
    ),
  );

  Future<void> _updateStatus(String id, String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('campusRequests')
          .doc(id)
          .update({
            'status': status,
            'updatedAt': FieldValue.serverTimestamp(),
          });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Request marked ${status.replaceAll('_', ' ')}.'),
          ),
        );
      }
    } on FirebaseException catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Could not update status (${error.code}). Check admin permissions and Firestore rules.',
            ),
          ),
        );
      }
    }
  }
}
