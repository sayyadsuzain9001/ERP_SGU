import 'package:flutter/material.dart';
import '../data/mock_data.dart';
import '../theme/app_theme.dart';

class MiniCalendar extends StatelessWidget {
  final bool compact;
  const MiniCalendar({super.key, this.compact = false});

  @override
  Widget build(BuildContext context) {
    const days = ['S','M','T','W','T','F','S'];
    const numbers = [30,31,1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,1,2,3];
    return Card(child: Padding(padding: EdgeInsets.all(compact ? 10 : 14), child: Column(children: [
      Row(children: [const Text('September 2026', style: TextStyle(fontWeight: FontWeight.w800)), const Spacer(), const Icon(Icons.chevron_right, size: 18)]),
      const SizedBox(height: 10),
      GridView.builder(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: 42, gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, childAspectRatio: 1.35), itemBuilder: (_, index) {
        if (index < 7) return Center(child: Text(days[index], style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppTheme.muted)));
        final n = numbers[index - 7];
        final selected = n == 24 && index < 35;
        return Center(child: Container(width: 22, height: 22, alignment: Alignment.center, decoration: BoxDecoration(color: selected ? AppTheme.red : Colors.transparent, shape: BoxShape.circle), child: Text('$n', style: TextStyle(fontSize: 9, color: selected ? Colors.white : AppTheme.navy, fontWeight: selected ? FontWeight.w800 : FontWeight.w500))));
      }),
    ])));
  }
}

class UpcomingEvents extends StatelessWidget {
  const UpcomingEvents({super.key});
  @override
  Widget build(BuildContext context) => Card(child: Padding(padding: const EdgeInsets.all(16), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
    const Text('Upcoming Events', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w800, color: AppTheme.navy)),
    const SizedBox(height: 12),
    for (final event in MockData.i.events) Padding(padding: const EdgeInsets.only(bottom: 12), child: Row(children: [Container(width: 3, height: 38, color: event.category == 'Deadlines' ? AppTheme.red : event.category == 'Classes' ? AppTheme.info : AppTheme.warning), const SizedBox(width: 10), Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(event.title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)), const SizedBox(height: 3), Text('${event.date.day} Sep • ${event.time}', style: const TextStyle(fontSize: 10, color: AppTheme.muted))]))])),
  ])));
}
