import 'package:flutter/material.dart';

import '../../models/models.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/firestore_module_records.dart';

/// Shared Firestore-backed workspace for modules that do not yet have a
/// dedicated domain screen. It intentionally avoids displaying fake metrics.
/// All records created here are stored in Cloud Firestore by
/// [FirestoreModuleRecords].
class GenericModulePage extends StatelessWidget {
  final String title;
  final UserRole role;

  const GenericModulePage({super.key, required this.title, required this.role});

  @override
  Widget build(BuildContext context) => PageContainer(
        title: title,
        subtitle: _subtitle,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _workspaceNotice(),
            const SizedBox(height: 18),
            FirestoreModuleRecords(module: title, role: role),
          ],
        ),
      );

  String get _subtitle => switch (title) {
        'Timetable' => 'View and manage academic schedule records.',
        'Academic Progress' => 'Review academic progress records saved in Firebase.',
        'Results' => 'Manage result records saved in Firebase.',
        'Finance' || 'Fee Summary' || 'Payment History' || 'Receipts' =>
          'Manage finance records saved in Firebase.',
        'Notifications' => 'Manage university updates saved in Firebase.',
        'Messages' => 'Manage communication records saved in Firebase.',
        'Requests' => 'Submit and track university service requests.',
        _ => 'Manage $title records from the university portal.',
      };

  Widget _workspaceNotice() => Card(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Icon(Icons.cloud_done_outlined,
                  color: AppTheme.info, size: 24),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('$title workspace',
                        style: const TextStyle(
                            fontWeight: FontWeight.w800,
                            color: AppTheme.navy)),
                    const SizedBox(height: 5),
                    const Text(
                      'Create a validated record below. Records are saved in Firebase Cloud Firestore and shown in the saved-record list. No sample academic, finance, or grade values are presented as real data.',
                      style: TextStyle(color: AppTheme.muted, height: 1.45),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
}
