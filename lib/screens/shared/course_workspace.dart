import 'package:flutter/material.dart';
import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import 'module_pages.dart';

class ExpandedIfCourse extends StatelessWidget {
  final bool expand; final Widget child;
  const ExpandedIfCourse({super.key, required this.expand, required this.child});
  @override Widget build(BuildContext context) => expand ? Expanded(child: child) : child;
}

class CourseWorkspacePage extends StatefulWidget {
  final String courseId;
  const CourseWorkspacePage({super.key, required this.courseId});
  @override State<CourseWorkspacePage> createState() => _CourseWorkspacePageState();
}
class _CourseWorkspacePageState extends State<CourseWorkspacePage> {
  String tab = 'Overview';
  final List<String> tabs = const ['Overview','Syllabus','Announcements','Modules','Assignments','Quizzes & Exams','Discussions','Grades','Attendance','People','Files','Calendar'];
  @override Widget build(BuildContext context) {
    final course = MockData.i.course(widget.courseId);
    return PageContainer(title: course.name, subtitle: '${course.code} • ${course.instructor} • ${course.room}', actions: [OutlinedButton.icon(onPressed: () => Navigator.maybePop(context), icon: const Icon(Icons.arrow_back), label: const Text('Back to Courses'))], child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Card(child: SingleChildScrollView(scrollDirection: Axis.horizontal, padding: const EdgeInsets.all(8), child: Row(children: [for (final item in tabs) Padding(padding: const EdgeInsets.only(right: 6), child: ChoiceChip(label: Text(item), selected: tab == item, onSelected: (_) => setState(() => tab = item)))]))),
      const SizedBox(height: 14), _body(course),
    ]));
  }
  Widget _body(Course course) => switch(tab) {
    'Overview' => Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Container(width: double.infinity, padding: const EdgeInsets.all(22), decoration: BoxDecoration(color: Colors.white, border: Border.all(color: const Color(0xFFE2E7EF)), borderRadius: BorderRadius.circular(20)), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(course.name, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800)), const SizedBox(height: 6), Text('${course.code} · ${course.instructor} · ${course.room}', style: const TextStyle(color: Color(0xFF78859B))), const SizedBox(height: 18), ClipRRect(borderRadius: BorderRadius.circular(20), child: LinearProgressIndicator(value: course.progress, minHeight: 9)), const SizedBox(height: 8), Text('${course.completed} of ${course.total} learning items completed', style: const TextStyle(fontSize: 12, color: Color(0xFF78859B))), const SizedBox(height: 16), Wrap(spacing: 10, runSpacing: 10, children: [OutlinedButton.icon(onPressed: () => setState(() => tab = 'Syllabus'), icon: const Icon(Icons.menu_book_outlined), label: const Text('View syllabus')), OutlinedButton.icon(onPressed: () => setState(() => tab = 'Assignments'), icon: const Icon(Icons.assignment_outlined), label: const Text('Open assignments')), OutlinedButton.icon(onPressed: () => setState(() => tab = 'Attendance'), icon: const Icon(Icons.fact_check_outlined), label: const Text('Attendance'))])])), const SizedBox(height: 12), LayoutBuilder(builder: (context, box) { final stacked = box.maxWidth < 650; final cards = [const EmptyActionCard(icon: Icons.assignment_outlined,title:'Assignments',subtitle:'View tasks, due dates and submission status.'), const EmptyActionCard(icon: Icons.fact_check_outlined,title:'Attendance',subtitle:'Review your course attendance record.')]; return Flex(direction: stacked ? Axis.vertical : Axis.horizontal, crossAxisAlignment: CrossAxisAlignment.stretch, children: [ExpandedIfCourse(expand: !stacked, child: cards[0]), if (!stacked) const SizedBox(width: 12) else const SizedBox(height: 12), ExpandedIfCourse(expand: !stacked, child: cards[1])]); })]),
    'Attendance' => const GenericModulePage(title:'Course Attendance',role:UserRole.student),
    'Grades' => const GenericModulePage(title:'Course Grades',role:UserRole.student),
    _ => GenericModulePage(title:tab, role:UserRole.student),
  };
}
