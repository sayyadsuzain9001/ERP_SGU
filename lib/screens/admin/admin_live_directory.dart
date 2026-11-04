import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

/// Live directory for real Firebase records, rather than the generic form UI.
class AdminLiveDirectoryPage extends StatefulWidget {
  const AdminLiveDirectoryPage({super.key, required this.title, required this.kind});
  final String title;
  final String kind; // students, teachers, courses
  @override
  State<AdminLiveDirectoryPage> createState() => _AdminLiveDirectoryPageState();
}

class _AdminLiveDirectoryPageState extends State<AdminLiveDirectoryPage> {
  final _search = TextEditingController();
  @override
  void dispose() { _search.dispose(); super.dispose(); }

  Stream<QuerySnapshot<Map<String, dynamic>>> _stream() {
    if (widget.kind == 'courses') {
      return FirebaseFirestore.instance.collection('formSubmissions').where('module', isEqualTo: 'Courses').snapshots();
    }
    return FirebaseFirestore.instance.collection('users').snapshots();
  }

  bool _matches(Map<String, dynamic> data) {
    if (widget.kind == 'courses') return true;
    final role = (data['accountType'] ?? data['requestedRole'] ?? '').toString().toLowerCase();
    return role == (widget.kind == 'students' ? 'student' : 'teacher');
  }

  @override
  Widget build(BuildContext context) => PageContainer(
    title: widget.title,
    subtitle: switch (widget.kind) {
      'students' => 'Live student accounts from Firebase Authentication profiles.',
      'teachers' => 'Live teacher accounts and requested teacher profiles from Firestore.',
      _ => 'Course submissions saved in Firestore.',
    },
    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
      TextField(controller: _search, onChanged: (_) => setState(() {}), decoration: InputDecoration(prefixIcon: const Icon(Icons.search), labelText: 'Search ${widget.title.toLowerCase()}', hintText: 'Search name, email, ID or title', suffixIcon: IconButton(tooltip: 'Clear search', onPressed: () { _search.clear(); setState(() {}); }, icon: const Icon(Icons.close)))),
      const SizedBox(height: 14),
      StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(stream: _stream(), builder: (context, snapshot) {
        if (snapshot.hasError) return _state(Icons.cloud_off_outlined, 'Could not load ${widget.title.toLowerCase()}. Check Firestore rules and connection.');
        if (snapshot.connectionState == ConnectionState.waiting) return const Padding(padding: EdgeInsets.all(30), child: Center(child: CircularProgressIndicator()));
        final docs = (snapshot.data?.docs ?? []).where((doc) {
          final data = doc.data();
          if (!_matches(data)) return false;
          final q = _search.text.trim().toLowerCase();
          if (q.isEmpty) return true;
          final values = widget.kind == 'courses'
            ? [data['title'], data['description'], data['fields']]
            : [data['name'], data['email'], data['studentId'], data['staffId'], data['programme'], data['department']];
          return values.any((value) => value != null && value.toString().toLowerCase().contains(q));
        }).toList()..sort((a, b) => ((a.data()['name'] ?? a.data()['title'] ?? '').toString()).compareTo((b.data()['name'] ?? b.data()['title'] ?? '').toString()));
        if (docs.isEmpty) return _state(Icons.people_outline, _search.text.isEmpty ? 'No ${widget.title.toLowerCase()} records found in Firestore yet.' : 'No records match your search.');
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text('${docs.length} record${docs.length == 1 ? '' : 's'}', style: const TextStyle(color: AppTheme.muted, fontWeight: FontWeight.w700)),
          const SizedBox(height: 10),
          ...docs.map((doc) {
            final d = doc.data();
            final title = (widget.kind == 'courses' ? d['title'] : d['name'])?.toString().trim();
            final displayTitle = title == null || title.isEmpty ? (widget.kind == 'courses' ? 'Untitled course record' : 'Unnamed account') : title;
            final detail = widget.kind == 'courses'
              ? (d['description'] ?? '').toString()
              : [d['email'], widget.kind == 'students' ? d['studentId'] : d['staffId'], d['programme'] ?? d['department']].where((v) => v != null && v.toString().trim().isNotEmpty).join(' • ');
            return Card(margin: const EdgeInsets.only(bottom: 8), child: ListTile(
              leading: CircleAvatar(backgroundColor: AppTheme.paleRed, child: Icon(widget.kind == 'students' ? Icons.person_outline : widget.kind == 'teachers' ? Icons.badge_outlined : Icons.school_outlined, color: AppTheme.red)),
              title: Text(displayTitle, style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy)),
              subtitle: Text(detail.isEmpty ? 'Record ID: ${doc.id}' : detail),
              isThreeLine: false,
              trailing: const Icon(Icons.chevron_right, color: AppTheme.muted),
              onTap: () => showDialog<void>(context: context, builder: (dialogContext) => AlertDialog(title: Text(displayTitle), content: SizedBox(width: 480, child: SingleChildScrollView(child: SelectableText(d.entries.map((e) => '${e.key}: ${e.value}').join('\n')))), actions: [TextButton(onPressed: () => Navigator.pop(dialogContext), child: const Text('Close'))])),
            ));
          }),
        ]);
      }),
    ]),
  );

  Widget _state(IconData icon, String message) => Card(child: Padding(padding: const EdgeInsets.all(28), child: Column(children: [Icon(icon, size: 38, color: AppTheme.muted), const SizedBox(height: 10), Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppTheme.muted))])));
}
