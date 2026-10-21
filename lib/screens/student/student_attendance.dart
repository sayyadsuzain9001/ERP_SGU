import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/attendance_card.dart';

class StudentAttendancePage extends StatelessWidget {
  const StudentAttendancePage({super.key});
  @override
  Widget build(BuildContext context) => PageContainer(title: 'Attendance', subtitle: 'Monitor attendance across your enrolled courses.', child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        LayoutBuilder(builder: (_, constraints) => GridView.count(shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), crossAxisCount: constraints.maxWidth > 800 ? 3 : 1, crossAxisSpacing: 12, mainAxisSpacing: 12, childAspectRatio: 2.7, children: [
          _summary('Overall Attendance', '82%', AppTheme.success), _summary('Classes Attended', '83', AppTheme.info), _summary('Classes Missed', '18', AppTheme.red),
        ])),
        const SizedBox(height: 20), const SectionHeader('Attendance Trend'), const SizedBox(height: 8), const _AttendanceGraph(),
        const SizedBox(height: 20), const SectionHeader('By Course'), const SizedBox(height: 8),
        for (final course in MockData.i.courses) Padding(padding: const EdgeInsets.only(bottom: 10), child: AttendanceCard(course: course)),
      ]));

  Widget _summary(String label, String value, Color color) => Card(child: Padding(padding: const EdgeInsets.all(18), child: Row(children: [Container(width: 10, height: 10, decoration: BoxDecoration(color: color, shape: BoxShape.circle)), const SizedBox(width: 10), Expanded(child: Text(label, style: const TextStyle(color: AppTheme.muted))), Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color))])));
}

class _AttendanceGraph extends StatelessWidget {
  const _AttendanceGraph();
  @override
  Widget build(BuildContext context) => Card(child: SizedBox(height: 220, child: Padding(padding: const EdgeInsets.fromLTRB(18, 20, 18, 14), child: CustomPaint(painter: _GraphPainter(), child: const SizedBox.expand()))));
}

class _GraphPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final grid = Paint()..color = AppTheme.border..strokeWidth = 1;
    final line = Paint()..color = AppTheme.red..strokeWidth = 3..style = PaintingStyle.stroke..strokeCap = StrokeCap.round;
    for (var i = 1; i < 5; i++) { canvas.drawLine(Offset(0, size.height * i / 5), Offset(size.width, size.height * i / 5), grid); }
    final values = MockData.i.attendanceTrend.map((e) => e.value).toList();
    final path = Path();
    for (var i = 0; i < values.length; i++) {
      final x = i * size.width / (values.length - 1);
      final y = size.height - ((values[i] - .74) / .12 * size.height);
      if (i == 0) { path.moveTo(x, y); } else { path.lineTo(x, y); }
      canvas.drawCircle(Offset(x, y), 4, Paint()..color = AppTheme.red);
    }
    canvas.drawPath(path, line);
  }
  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
