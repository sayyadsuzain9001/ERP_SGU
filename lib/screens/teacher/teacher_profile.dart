import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';

class TeacherProfilePage extends StatefulWidget {
  const TeacherProfilePage({super.key});
  @override
  State<TeacherProfilePage> createState() => _TeacherProfilePageState();
}

class _TeacherProfilePageState extends State<TeacherProfilePage> {
  final _firestore = FirebaseFirestore.instance;
  final _auth = FirebaseAuth.instance;
  final _name = TextEditingController();
  final _staffId = TextEditingController();
  final _department = TextEditingController();
  final _phone = TextEditingController();
  bool _saving = false;

  @override
  void dispose() { _name.dispose(); _staffId.dispose(); _department.dispose(); _phone.dispose(); super.dispose(); }

  Future<void> _edit(Map<String, dynamic> data) async {
    _name.text = (data['name'] ?? '').toString();
    _staffId.text = (data['staffId'] ?? '').toString();
    _department.text = (data['department'] ?? '').toString();
    _phone.text = (data['phone'] ?? '').toString();
    final key = GlobalKey<FormState>();
    final accepted = await showDialog<bool>(context: context, builder: (dialogContext) => AlertDialog(
      title: const Text('Edit staff profile'),
      content: SizedBox(width: 460, child: Form(key: key, child: SingleChildScrollView(child: Column(mainAxisSize: MainAxisSize.min, children: [
        TextFormField(controller: _name, decoration: const InputDecoration(labelText: 'Full name *'), validator: (v) => (v?.trim().length ?? 0) < 3 ? 'Enter your full name.' : null),
        const SizedBox(height: 10), TextFormField(controller: _staffId, decoration: const InputDecoration(labelText: 'Staff ID *'), validator: (v) => (v?.trim().length ?? 0) < 3 ? 'Enter a valid staff ID.' : null),
        const SizedBox(height: 10), TextFormField(controller: _department, decoration: const InputDecoration(labelText: 'Department *'), validator: (v) => (v?.trim().length ?? 0) < 2 ? 'Enter your department.' : null),
        const SizedBox(height: 10), TextFormField(controller: _phone, keyboardType: TextInputType.phone, decoration: const InputDecoration(labelText: 'Phone number')),
      ])))),
      actions: [TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')), FilledButton(onPressed: () { if (key.currentState?.validate() ?? false) Navigator.pop(dialogContext, true); }, child: const Text('Save'))],
    ));
    if (accepted != true || !mounted) return;
    final user = _auth.currentUser;
    if (user == null) return;
    setState(() => _saving = true);
    try {
      final ref = _firestore.collection('users').doc(user.uid);
      final exists = (await ref.get()).exists;
      await ref.set({'uid': user.uid, 'name': _name.text.trim(), 'staffId': _staffId.text.trim(), 'department': _department.text.trim(), 'phone': _phone.text.trim(), 'email': user.email ?? '', 'updatedAt': FieldValue.serverTimestamp(), if (!exists) 'createdAt': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Staff profile saved to Firebase.')));
    } on FirebaseException catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Could not save profile (${e.code}). Check Firestore rules.')));
    } finally { if (mounted) setState(() => _saving = false); }
  }

  @override
  Widget build(BuildContext context) {
    final user = _auth.currentUser;
    if (user == null) {
      return const PageContainer(
        title: 'Staff Profile',
        child: Text('Sign in to view your profile.'),
      );
    }
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _firestore.collection('users').doc(user.uid).snapshots(),
      builder: (context, snapshot) {
        final data = snapshot.data?.data() ?? const <String, dynamic>{};
        final name = (data['name'] ?? 'Staff member').toString();
        final staffId = (data['staffId'] ?? 'Not added').toString();
        final department = (data['department'] ?? 'Not added').toString();
        return PageContainer(
          title: 'Staff Profile',
          subtitle: 'Your staff information is stored in Firebase Firestore.',
          actions: [
            FilledButton.icon(
              onPressed: _saving ? null : () => _edit(data),
              icon: const Icon(Icons.edit_outlined),
              label: Text(_saving ? 'Saving…' : 'Edit Profile'),
            ),
          ],
          child: Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Row(
                    children: [
                      const CircleAvatar(radius: 34, child: Icon(Icons.person_outline, size: 30)),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(name, style: const TextStyle(fontSize: 21, fontWeight: FontWeight.w800, color: AppTheme.navy)),
                            Text(user.email ?? 'No email', style: const TextStyle(color: AppTheme.muted)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Card(
                child: Column(
                  children: [
                    ListTile(leading: const Icon(Icons.badge_outlined), title: const Text('Staff ID'), subtitle: Text(staffId)),
                    ListTile(leading: const Icon(Icons.account_tree_outlined), title: const Text('Department'), subtitle: Text(department)),
                    ListTile(leading: const Icon(Icons.phone_outlined), title: const Text('Phone'), subtitle: Text((data['phone'] ?? 'Not added').toString())),
                  ],
                ),
              ),
              if (snapshot.hasError)
                Text('Could not load profile: ${snapshot.error}', style: const TextStyle(color: AppTheme.red)),
            ],
          ),
        );
      },
    );
  }
}
