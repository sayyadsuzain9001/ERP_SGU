import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../routes/app_routes.dart';
import '../../theme/app_theme.dart';
import 'route_widgets.dart';

class TimetableScreen extends StatelessWidget {
  const TimetableScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = MockData.i.timetableEntries;
    return RoutePageFrame(
      title: 'Timetable',
      subtitle: 'Your weekly classes with day, time, module, instructor and room.',
      actions: [
        IconButton(
          tooltip: 'Dashboard',
          onPressed: () => Navigator.pushNamed(context, AppRoutes.dashboard),
          icon: const Icon(Icons.home_outlined),
        ),
      ],
      child: LayoutBuilder(
        builder: (context, constraints) {
          final desktop = constraints.maxWidth >= 850;
          final grouped = <String, List<TimetableEntry>>{};
          for (final entry in entries) {
            grouped.putIfAbsent(entry.day, () => []).add(entry);
          }
          return Column(
            children: [
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          color: AppTheme.red.withValues(alpha: .08),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.schedule_outlined, color: AppTheme.red),
                      ),
                      const SizedBox(width: 12),
                      const Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Semester 6 • Current Week', style: TextStyle(fontWeight: FontWeight.w800)),
                            SizedBox(height: 4),
                            Text('5 scheduled sessions', style: TextStyle(color: AppTheme.muted, fontSize: 12)),
                          ],
                        ),
                      ),
                      if (desktop) const Text('Today: Monday', style: TextStyle(fontSize: 12, color: AppTheme.muted)),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 14),
              if (desktop)
                _desktopTable(entries)
              else
                ...grouped.entries.map(
                  (group) => Padding(
                    padding: const EdgeInsets.only(bottom: 14),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(group.key, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
                        const SizedBox(height: 7),
                        for (final entry in group.value) _mobileEntry(entry),
                      ],
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  Widget _desktopTable(List<TimetableEntry> entries) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: DataTable(
        headingRowColor: WidgetStatePropertyAll(AppTheme.red.withValues(alpha: .06)),
        columns: const [
          DataColumn(label: Text('Day')),
          DataColumn(label: Text('Module')),
          DataColumn(label: Text('Time')),
          DataColumn(label: Text('Room')),
          DataColumn(label: Text('Instructor')),
        ],
        rows: entries
            .map(
              (entry) => DataRow(cells: [
                DataCell(Text(entry.day)),
                DataCell(Text(entry.subject, style: const TextStyle(fontWeight: FontWeight.w700))),
                DataCell(Text(entry.time)),
                DataCell(Text(entry.room)),
                DataCell(Text(entry.instructor)),
              ]),
            )
            .toList(),
      ),
    );
  }

  Widget _mobileEntry(TimetableEntry entry) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: const Icon(Icons.menu_book_outlined, color: AppTheme.info),
        title: Text(entry.subject, style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${entry.time}\n${entry.room} • ${entry.instructor}'),
        isThreeLine: true,
      ),
    );
  }
}
