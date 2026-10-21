import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../models/models.dart';

class AttendanceCard extends StatelessWidget {
  final Course course;
  const AttendanceCard({super.key, required this.course});

  @override
  Widget build(BuildContext context) => Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(children: [
            SizedBox(width: 62, height: 62, child: Stack(alignment: Alignment.center, children: [
              CircularProgressIndicator(value: course.attendance / 100, color: course.attendance < 75 ? AppTheme.red : AppTheme.success, backgroundColor: AppTheme.border, strokeWidth: 6),
              Text('${course.attendance}%', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
            ])),
            const SizedBox(width: 16),
            Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(course.name, style: const TextStyle(fontWeight: FontWeight.w800)),
              const SizedBox(height: 5),
              Text('${course.code} • ${course.instructor}', style: const TextStyle(color: AppTheme.muted, fontSize: 12)),
              const SizedBox(height: 8),
              LinearProgressIndicator(value: course.attendance / 100, minHeight: 5, backgroundColor: AppTheme.border, color: course.attendance < 75 ? AppTheme.red : AppTheme.success),
            ])),
          ]),
        ),
      );
}
