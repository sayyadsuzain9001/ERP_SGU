import 'package:flutter/material.dart';

import '../../data/mock_data.dart';
import '../../models/models.dart';
import '../../widgets/common.dart';
import '../../widgets/assignment_card.dart';
import '../shared/assignment_details.dart';

class StudentAssignmentsPage extends StatefulWidget {
  const StudentAssignmentsPage({super.key});

  @override
  State<StudentAssignmentsPage> createState() => _StudentAssignmentsPageState();
}

class _StudentAssignmentsPageState extends State<StudentAssignmentsPage> {
  String _status = 'All';
  String _course = 'All courses';

  @override
  Widget build(BuildContext context) {
    final assignments = MockData.i.assignments.where((assignment) {
      final statusMatches =
          _status == 'All' ||
          switch (_status) {
            'Pending' => assignment.status == RecordStatus.pending,
            'Submitted' => assignment.status == RecordStatus.submitted,
            'Graded' => assignment.status == RecordStatus.graded,
            'Overdue' => assignment.status == RecordStatus.overdue,
            _ => true,
          };
      final courseMatches =
          _course == 'All courses' ||
          MockData.i.course(assignment.courseId).name == _course;
      return statusMatches && courseMatches;
    }).toList();

    return PageContainer(
      title: 'Assignments',
      subtitle: 'Track upcoming, submitted and graded work.',
      child: Column(
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              for (final status in const [
                'All',
                'Pending',
                'Submitted',
                'Graded',
                'Overdue',
              ])
                ChoiceChip(
                  label: Text(status),
                  selected: _status == status,
                  onSelected: (_) => setState(() => _status = status),
                ),
              PopupMenuButton<String>(
                tooltip: 'Filter by course',
                onSelected: (course) => setState(() => _course = course),
                itemBuilder: (context) => [
                  const PopupMenuItem(
                    value: 'All courses',
                    child: Text('All courses'),
                  ),
                  for (final course in MockData.i.courses)
                    PopupMenuItem(value: course.name, child: Text(course.name)),
                ],
                child: OutlinedButton.icon(
                  onPressed: null,
                  icon: const Icon(Icons.filter_list),
                  label: Text(
                    _course == 'All courses' ? 'Filter by course' : _course,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (assignments.isEmpty)
            const Card(
              child: Padding(
                padding: EdgeInsets.all(24),
                child: Center(
                  child: Text('No assignments match these filters.'),
                ),
              ),
            )
          else
            for (final assignment in assignments)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: AssignmentCard(
                  assignment: assignment,
                  courseName: MockData.i.course(assignment.courseId).name,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => AssignmentDetailsPage(
                        assignment: assignment,
                        courseName: MockData.i.course(assignment.courseId).name,
                        title: assignment.title,
                        marks: '${assignment.marks} marks',
                        dueDate:
                            '${assignment.due.day} ${_month(assignment.due.month)}',
                      ),
                    ),
                  ),
                ),
              ),
        ],
      ),
    );
  }
}

String _month(int month) => const [
  '',
  'Jan',
  'Feb',
  'Mar',
  'Apr',
  'May',
  'Jun',
  'Jul',
  'Aug',
  'Sep',
  'Oct',
  'Nov',
  'Dec',
][month];
