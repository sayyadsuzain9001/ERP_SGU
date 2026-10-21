import 'package:flutter/material.dart';
import '../models/models.dart';
import '../theme/app_theme.dart';
import 'common.dart';

class AssignmentCard extends StatelessWidget {
  final Assignment assignment;
  final String courseName;
  final VoidCallback? onTap;
  const AssignmentCard({super.key, required this.assignment, required this.courseName, this.onTap});

  String get statusLabel => switch (assignment.status) { RecordStatus.pending => 'Pending', RecordStatus.submitted => 'Submitted', RecordStatus.graded => 'Graded', RecordStatus.overdue => 'Overdue' };
  Color get statusColor => switch (assignment.status) { RecordStatus.pending => AppTheme.warning, RecordStatus.submitted => AppTheme.info, RecordStatus.graded => AppTheme.success, RecordStatus.overdue => AppTheme.red };

  @override
  Widget build(BuildContext context) => Card(
        child: ListTile(
          onTap: onTap,
          contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          leading: Container(width: 42, height: 42, decoration: BoxDecoration(color: statusColor.withValues(alpha: .10), borderRadius: BorderRadius.circular(10)), child: Icon(Icons.assignment_outlined, color: statusColor)),
          title: Text(assignment.title, style: const TextStyle(fontWeight: FontWeight.w800)),
          subtitle: Text('$courseName • Due ${assignment.due.day} ${_month(assignment.due.month)} • ${assignment.marks} marks'),
          trailing: StatusChip(statusLabel, color: statusColor),
        ),
      );

  String _month(int month) => const ['','Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'][month];
}
