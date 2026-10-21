import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/form_submission_repository.dart';
import '../services/module_form_schema.dart';
import '../theme/app_theme.dart';

/// Reusable, validated form + live Firestore list for module pages.
/// Screen-specific fields can be added later without changing persistence rules.
class FirestoreModuleRecords extends StatefulWidget {
  const FirestoreModuleRecords({super.key, required this.module, required this.role});
  final String module;
  final UserRole role;

  @override
  State<FirestoreModuleRecords> createState() => _FirestoreModuleRecordsState();
}

class _FirestoreModuleRecordsState extends State<FirestoreModuleRecords> {
  final _repository = FormSubmissionRepository();
  final _formKey = GlobalKey<FormState>();
  final _title = TextEditingController();
  final _description = TextEditingController();
  final Map<String, TextEditingController> _fieldControllers = {};
  final Map<String, String?> _fieldChoices = {};
  bool _saving = false;

  @override
  void dispose() {
    _title.dispose();
    _description.dispose();
    for (final controller in _fieldControllers.values) { controller.dispose(); }
    super.dispose();
  }

  Future<void> _openForm({QueryDocumentSnapshot<Map<String, dynamic>>? existing}) async {
    _title.text = (existing?.data()['title'] ?? '').toString();
    _description.text = (existing?.data()['description'] ?? '').toString();
    final existingFields = Map<String, dynamic>.from(existing?.data()['fields'] is Map ? existing!.data()['fields'] as Map : const {});
    for (final spec in fieldsForModule(widget.module)) {
      final value = (existingFields[spec.key] ?? '').toString();
      if (spec.isChoice) {
        _fieldChoices[spec.key] = spec.options.contains(value) ? value : null;
      } else {
        _fieldControllers.putIfAbsent(spec.key, TextEditingController.new).text = value;
      }
    }
    final accepted = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(22),
            side: const BorderSide(color: AppTheme.border),
          ),
          title: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 46, height: 46,
                decoration: BoxDecoration(color: AppTheme.red.withValues(alpha: .09), borderRadius: BorderRadius.circular(14)),
                child: const Icon(Icons.support_agent_rounded, color: AppTheme.red, size: 26),
              ),
              const SizedBox(width: 12),
              Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Text(existing == null ? (widget.module == 'Requests' ? 'New service request' : 'New ${widget.module} submission') : 'Edit ${widget.module} submission', style: const TextStyle(fontWeight: FontWeight.w800, color: AppTheme.navy, fontSize: 20)),
                const SizedBox(height: 4),
                const Text('Complete the details below. Required fields are marked with *.', style: TextStyle(fontSize: 12, height: 1.35, color: AppTheme.muted, fontWeight: FontWeight.normal)),
              ])),
            ],
          ),
          content: SizedBox(
            width: 520,
            child: Form(
              key: _formKey,
              child: SingleChildScrollView(
                child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                  if (widget.module == 'Requests') ...[
                    _formSectionHeading(Icons.person_outline_rounded, 'Request details', 'Tell us what you need help with.'),
                    const SizedBox(height: 10),
                  ],
                  TextFormField(
                    controller: _title,
                    textInputAction: TextInputAction.next,
                    maxLength: 120,
                    decoration: InputDecoration(labelText: widget.module == 'Requests' ? 'Request subject *' : 'Title *', hintText: widget.module == 'Requests' ? 'e.g. Need help with course registration' : 'Enter a clear title', prefixIcon: const Icon(Icons.title_rounded)),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 3) {
                        return 'Enter at least 3 characters.';
                      }
                      if (text.length > 120) {
                        return 'Keep the title under 120 characters.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  if (widget.module == 'Requests') ...[
                    _formSectionHeading(Icons.notes_rounded, 'Description', 'Explain the issue or service you are requesting.'),
                    const SizedBox(height: 10),
                  ],
                  TextFormField(
                    controller: _description,
                    minLines: 3,
                    maxLines: 6,
                    maxLength: 2000,
                    decoration: InputDecoration(labelText: widget.module == 'Requests' ? 'Describe your request *' : 'Details *', alignLabelWithHint: true, hintText: widget.module == 'Requests' ? 'Include relevant details so the university team can help you.' : 'Provide the details needed to process this submission', prefixIcon: const Icon(Icons.notes_rounded)),
                    validator: (value) {
                      final text = value?.trim() ?? '';
                      if (text.length < 10) {
                        return 'Enter at least 10 characters.';
                      }
                      if (text.length > 2000) {
                        return 'Keep details under 2000 characters.';
                      }
                      return null;
                    },
                  ),
                  if (widget.module == 'Requests') ...[
                    const SizedBox(height: 8),
                    _formSectionHeading(Icons.tune_rounded, 'Service preferences', 'Choose the category and priority for this request.'),
                  ],
                  for (final spec in fieldsForModule(widget.module)) ...[
                    const SizedBox(height: 10),
                    if (spec.isChoice)
                      DropdownButtonFormField<String>(
                        initialValue: spec.options.contains(_fieldChoices[spec.key]) ? _fieldChoices[spec.key] : null,
                        decoration: InputDecoration(labelText: '${spec.label}${spec.required ? ' *' : ''}'),
                        items: spec.options.map((option) => DropdownMenuItem(value: option, child: Text(option))).toList(),
                        validator: spec.required ? (value) => value == null || value.isEmpty ? 'Select ${spec.label.toLowerCase()}.' : null : null,
                        onChanged: (value) => setDialogState(() => _fieldChoices[spec.key] = value),
                      )
                    else
                      TextFormField(
                        controller: _fieldControllers.putIfAbsent(spec.key, TextEditingController.new),
                        decoration: InputDecoration(labelText: '${spec.label}${spec.required ? ' *' : ''}'),
                        maxLength: 160,
                        validator: spec.required ? (value) => (value?.trim().isEmpty ?? true) ? 'Enter ${spec.label.toLowerCase()}.' : null : null,
                      ),
                  ],
                  const SizedBox(height: 8),
                  Align(alignment: Alignment.centerLeft, child: Text(widget.module == 'Requests' ? 'Your request will be saved securely in Firebase. The service team will update its status.' : 'Your submission will be saved to Firebase Firestore.', style: const TextStyle(color: AppTheme.muted, fontSize: 12))),
                ]),
              ),
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(dialogContext, false), child: const Text('Cancel')),
            FilledButton.icon(
              onPressed: () {
                if (_formKey.currentState?.validate() ?? false) {
                  Navigator.pop(dialogContext, true);
                } else {
                  setDialogState(() {});
                }
              },
              icon: const Icon(Icons.send_outlined), label: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
    if (accepted != true || !mounted) {
      return;
    }
    setState(() => _saving = true);
    try {
      final id = existing == null
          ? await _repository.submit(
              module: widget.module, title: _title.text,
              description: _description.text, fields: _collectFields(),
            )
          : existing.id;
      if (existing != null) {
        await _repository.update(id: existing.id, changes: {
          'title': _title.text.trim(), 'description': _description.text.trim(), 'fields': _collectFields(),
        });
      }
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(existing == null ? 'Saved to Firebase. Reference: ${id.substring(0, 8)}' : 'Changes saved to Firebase.')));
    } on FirebaseException catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Firebase could not save this submission (${error.code}). Check sign-in and Firestore rules.')));
    } catch (error) {
      if (!mounted) {
        return;
      }
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Submission failed: $error')));
    } finally {
      if (mounted) {
        setState(() => _saving = false);
      }
    }
  }

  Map<String, dynamic> _collectFields() => {
    'submittedFrom': widget.module,
    for (final spec in fieldsForModule(widget.module))
      spec.key: spec.isChoice ? (_fieldChoices[spec.key] ?? '') : (_fieldControllers[spec.key]?.text.trim() ?? ''),
  };

  @override
  Widget build(BuildContext context) => Card(
    child: Padding(
      padding: const EdgeInsets.all(18),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.cloud_done_outlined, color: AppTheme.red),
          const SizedBox(width: 10),
          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Text('${widget.module} forms', style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.navy)),
            const SizedBox(height: 3),
            Text('Submissions are persisted in Firebase Firestore. Portal preview: ${widget.role.name}; permissions are enforced by Firebase claims.', style: const TextStyle(fontSize: 12, color: AppTheme.muted)),
          ])),
          FilledButton.icon(onPressed: _saving ? null : _openForm, icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2)) : const Icon(Icons.add), label: Text(_saving ? 'Saving' : 'New form')),
        ]),
        const SizedBox(height: 14),
        StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
          stream: _repository.watchMine(module: widget.module),
          builder: (context, snapshot) {
            if (snapshot.hasError) {
              return _message(Icons.lock_outline, 'Could not load submissions. Check Firebase Authentication and Firestore rules.');
            }
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Padding(padding: EdgeInsets.all(18), child: Center(child: CircularProgressIndicator()));
            }
            final docs = (snapshot.data?.docs ?? []).where((doc) => doc.data()['module'] == widget.module).toList()
              ..sort((a, b) {
                final av = a.data()['createdAt'];
                final bv = b.data()['createdAt'];
                final ad = av is Timestamp ? av.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                final bd = bv is Timestamp ? bv.toDate() : DateTime.fromMillisecondsSinceEpoch(0);
                return bd.compareTo(ad);
              });
            if (docs.isEmpty) {
              return _message(Icons.inbox_outlined, 'No submissions yet. Use “New form” to create the first one.');
            }
            return Column(
              children: docs.map((doc) {
                final data = doc.data();
                final createdAt = data['createdAt'];
                final dateLabel = createdAt is Timestamp
                    ? createdAt.toDate().toLocal().toString().substring(0, 16)
                    : 'Just submitted';
                return ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const CircleAvatar(child: Icon(Icons.description_outlined)),
                  title: Text(
                    (data['title'] ?? 'Untitled submission').toString(),
                    style: const TextStyle(fontWeight: FontWeight.w700),
                  ),
                  subtitle: Text(
                    '${data['status'] ?? 'submitted'} • $dateLabel\n${(data['description'] ?? '').toString()}',
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),
                  isThreeLine: true,
                  trailing: PopupMenuButton<String>(
                    tooltip: 'Submission actions',
                    onSelected: (action) async {
                      if (action == 'edit') {
                        await _openForm(existing: doc);
                        return;
                      }
                      if (action != 'delete') {
                        return;
                      }
                      final confirmed = await showDialog<bool>(
                        context: context,
                        builder: (dialogContext) => AlertDialog(
                          title: const Text('Delete submission?'),
                          content: const Text('This removes this submission from Firebase Firestore.'),
                          actions: [
                            TextButton(
                              onPressed: () => Navigator.pop(dialogContext, false),
                              child: const Text('Cancel'),
                            ),
                            FilledButton(
                              onPressed: () => Navigator.pop(dialogContext, true),
                              child: const Text('Delete'),
                            ),
                          ],
                        ),
                      );
                      if (confirmed != true || !context.mounted) {
                        return;
                      }
                      try {
                        await _repository.delete(id: doc.id);
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Submission deleted from Firebase.')),
                          );
                        }
                      } catch (error) {
                        if (context.mounted) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text('Delete failed: $error')),
                          );
                        }
                      }
                    },
                    itemBuilder: (context) => const [
                      PopupMenuItem(value: 'edit', child: Text('Edit')),
                      PopupMenuItem(value: 'delete', child: Text('Delete')),
                    ],
                  ),
                );
              }).toList(),
            );
          },
        ),
      ]),
    ),
  );

  Widget _formSectionHeading(
    IconData icon,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(top: 16, bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: AppTheme.red.withValues(alpha: 0.10),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.red, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.navy,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  subtitle,
                  style: const TextStyle(
                    fontSize: 12,
                    color: AppTheme.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _message(IconData icon, String text) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 18),
    child: Row(children: [Icon(icon, color: AppTheme.muted), const SizedBox(width: 10), Expanded(child: Text(text, style: const TextStyle(color: AppTheme.muted))) ]),
  );
}
